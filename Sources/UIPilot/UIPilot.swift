import SwiftUI
import Combine

public class UIPilot<T: Hashable>: ObservableObject {
    @Published var paths: [Path<T>] = []

    public init(_ initialRoute: T) {
        push(initialRoute)
    }
    
    public func push(_ route: T) {
        self.paths.append(Path(route: route))
    }
    
    public func pop() {
        if !self.paths.isEmpty {
            self.paths.removeLast()
        }
    }
    
    public func popTo(_ route: T, inclusive: Bool = false) {
        if paths.isEmpty {
            return
        }
        
        guard var found = paths.firstIndex(where: { $0.route == route }) else {
            return
        }
        
        if !inclusive {
            found += 1
        }
        
        for _ in found..<paths.count {
            pop()
        }
    }
}

struct Path<T: Hashable>: Hashable, Equatable {
    let route: T
    let id: String = UUID().uuidString
    
    static func == (lhs: Path, rhs: Path) -> Bool {
        return lhs.route == rhs.route && lhs.id == rhs.id
    }
}

struct PathView: View {
    
    @ObservedObject private var vm: PathViewVM

    private let content: AnyView

    public init(_ content: AnyView, next: PathView? = nil, onPop: @escaping () -> Void = { }) {
        self.content = content
        self.vm = PathViewVM(next: next, onPop: onPop)
    }

    var body: some View {
        VStack {
            NavigationLink(destination: self.vm.next, isActive: self.$vm.isActive) {
                EmptyView()
            }.isDetailLink(false)
            content
        }
    }
}

class PathViewVM: ObservableObject {
    @Published
    var isActive: Bool = false {
        didSet {
            if !isActive && next != nil {
                onPop()
            }
        }
    }
    
    let next: PathView?
    private let onPop: () -> Void
    
    init(next: PathView?, onPop: @escaping () -> Void) {
        self.next = next
        self.isActive = next != nil
        self.onPop = onPop
    }
}

class UIPilotHostVM<T: Hashable>: ObservableObject {
    
    private let pilot: UIPilot<T>
    private let routeMap: (T) -> AnyView
    
    private var pathViews = [Path<T>: AnyView]()
    private var cancellable: AnyCancellable? = nil
    
    @Published var content: PathView? = nil
    
    init(pilot: UIPilot<T>, routeMap: @escaping (T) -> AnyView) {
        self.pilot = pilot
        self.routeMap = routeMap
        cancellable = self.pilot.$paths.sink(receiveValue: { [weak self] path in
            self?.content = self?.getView()
        })
    }
        
    func getView() -> PathView {
        recycleViews()
        var current: PathView? = nil
        for path in pilot.paths.reversed() {
            var content = pathViews[path]
            
            if content == nil {
                pathViews[path] = routeMap(path.route)
                content = pathViews[path]
            }

            let routeView = PathView(content!, next: current == nil ? nil : current, onPop: { [weak self] in
                if let self = self, !self.pilot.paths.isEmpty,
                   self.pilot.paths.last != path {
                    self.pilot.pop()
                }
            })
            current = routeView
        }
        return current ?? PathView(AnyView(EmptyView()))
    }
    
    private func recycleViews() {
        for key in pathViews.keys {
            if !pilot.paths.contains(key) {
                pathViews.removeValue(forKey: key)
            }
        }
    }
}

public struct UIPilotHost<T: Hashable> : View {

    private let pilot: UIPilot<T>
    
    @ObservedObject private var vm: UIPilotHostVM<T>

    public init(_ pilot: UIPilot<T>, _ routeMap: @escaping (T) -> AnyView) {
        self.pilot = pilot
        self.vm = UIPilotHostVM(pilot: pilot, routeMap: routeMap)
    }

    public var body: some View {
        NavigationView {
            vm.content
        }
        .environmentObject(pilot)
    }
}
