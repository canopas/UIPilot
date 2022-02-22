import SwiftUI
import Combine

public class UIPilot<T: Hashable>: ObservableObject {
    @Published var paths: [Path<T>] = [] {
        didSet { state.onPathsChanged(paths: paths) }
    }

    var state: UIPilotViewState<T>!
    
    public init(_ initialRoute: T, _ routeMap: @escaping (T) -> AnyView) {
        state = UIPilotViewState(routeMap: routeMap, onPop: { [weak self] in
            self?.pop()
        })
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
    
    private let content: AnyView

    @ObservedObject var state: PathViewState

    public init(_ content: AnyView, state: PathViewState) {
        self.content = content
        self.state = state
    }

    var body: some View {
        VStack {
            NavigationLink(destination: self.state.next, isActive: self.$state.isActive) {
                EmptyView()
            }.isDetailLink(false)
            content
        }
    }
}

class PathViewState: ObservableObject {
    @Published
    var isActive: Bool = false {
        didSet {
            if !isActive && next != nil {
                onPop()
            }
        }
    }
    
    @Published
    var next: PathView? = nil {
        didSet {
            isActive = next != nil
        }
    }
    
    var onPop: () -> Void
    
    init(next: PathView? = nil, onPop: @escaping () -> Void = {}) {
        self.next = next
        self.onPop = onPop
    }
}

class UIPilotViewState<T: Hashable>: ObservableObject {
    
    private let routeMap: (T) -> AnyView
    private let onPop: () -> Void
    
    private var pathViews = [Path<T>: PathView]()
    
    @Published var content: PathView? = nil
    
    init(routeMap: @escaping (T) -> AnyView, onPop: @escaping () -> Void) {
        self.routeMap = routeMap
        self.onPop = onPop
    }
    
    func onPathsChanged(paths: [Path<T>]) {
        content = getView(paths)
    }
        
    func getView(_ paths: [Path<T>]) -> PathView? {
        recycleViews(paths)

        var current: PathView? = nil
        for path in paths.reversed() {
            var content = pathViews[path]
            
            if content == nil {
                pathViews[path] = PathView(routeMap(path.route), state: PathViewState())
                content = pathViews[path]
            }
            
            content?.state.next = current
            content?.state.onPop = current == nil ? {} : { [weak self] in
                if let self = self, !paths.isEmpty,
                    paths.last != path {
                    self.onPop()
                }
            }

            current = content
        }
        
        return current
    }
    
    private func recycleViews(_ paths: [Path<T>]) {
        for key in pathViews.keys {
            if !paths.contains(key) {
                pathViews.removeValue(forKey: key)
            }
        }
    }
}

public struct UIPilotHost<T: Hashable> : View {

    private let pilot: UIPilot<T>
    
    public init(_ pilot: UIPilot<T>) {
        self.pilot = pilot
    }

    public var body: some View {
        NavigationView {
            pilot.state.content
        }
        .environmentObject(pilot)
    }
}
