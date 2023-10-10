import SwiftUI
import Combine

public class UIPilot<T: Equatable>: ObservableObject {
    
    private let logger: Logger
    
    @Published var pathsiOS16: [UIPilotPath<T>] = []
    
    @Published var paths: [UIPilotPath<T>] = [] {
        didSet {
            if paths.isEmpty {
                pathsiOS16 = []
            } else {
                pathsiOS16 = Array(paths.dropFirst())
            }
        }
    }
    
    public var stack: [T] {
        return paths.map { $0.route }
    }
    
    public init(_ initial: T? = nil, debug: Bool = false) {
        logger = debug ? DebugLog() : EmptyLog()
        logger.log("UIPilot - Pilot Initialized.")
        if let initial = initial {
            push(initial)
        }
    }
    
    public func push(_ route: T) {
        logger.log("UIPilot - Pushing \(route) route.")
        self.paths.append(UIPilotPath(route: route))
    }
    
    public func pop() {
        if !self.paths.isEmpty {
            logger.log("UIPilot - Route popped.")
            self.paths.removeLast()
        }
    }
    
    public func popTo(_ route: T, inclusive: Bool = false) {
        logger.log("UIPilot: Popping route \(route).")
        
        if paths.isEmpty {
            logger.log("UIPilot - Path is empty.")
            return
        }
        
        guard var found = paths.firstIndex(where: { $0.route == route }) else {
            logger.log("UIPilot - Route not found.")
            return
        }
        
        if !inclusive {
            found += 1
        }
        
        let numToPop = (found..<paths.endIndex).count
        logger.log("UIPilot - Popping \(numToPop) routes")
        paths.removeLast(numToPop)
    }
    
    func systemPop(path: UIPilotPath<T>) {
        if paths.count > 1
            && path.id == self.paths[self.paths.count - 2].id {
            self.pop()
        }
    }
    
}

struct PathView<Screen: View>: View {
    private let content: Screen
    @ObservedObject var state: PathViewState<Screen>
    
    public init(_ content: Screen, state: PathViewState<Screen>) {
        self.content = content
        self.state = state
    }
    
    var body: some View {
        VStack {
            if #available(iOS 16.0, *) {
                content
                    .navigationDestination(isPresented: $state.isActive) {
                        state.next
                    }
            } else {
                NavigationLink(destination: self.state.next, isActive: self.$state.isActive) {
                    EmptyView()
                }
#if os(iOS)
                .isDetailLink(false)
#endif
                content
            }
        }
    }
}

class PathViewState<Screen: View>: ObservableObject {
    @Published
    var isActive: Bool = false {
        didSet {
            if !isActive && next != nil {
                onPop()
            }
        }
    }
    
    @Published
    var next: PathView<Screen>? {
        didSet {
            isActive = next != nil
        }
    }
    
    var onPop: () -> Void
    
    init(next: PathView<Screen>? = nil, onPop: @escaping () -> Void = {}) {
        self.next = next
        self.onPop = onPop
    }
}

public struct UIPilotHost<T: Equatable, Screen: View>: View {
    
    @ObservedObject
    private var pilot: UIPilot<T>
    @ViewBuilder
    private let routeMap: (T) -> Screen
    
    @State
    private var viewGenerator = ViewGenerator<T, Screen>()
    
    public init(_ pilot: UIPilot<T>, @ViewBuilder _ routeMap: @escaping (T) -> Screen) {
        self.pilot = pilot
        self.routeMap = routeMap
        self.viewGenerator.onPop = { path in
            pilot.systemPop(path: path)
        }
    }
    
    public var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                viewGenerator.build(pilot.paths, routeMap)
            }
            .environmentObject(pilot)
        } else {
            NavigationView {
                viewGenerator.build(pilot.paths, routeMap)
            }
#if !os(macOS)
            .navigationViewStyle(.stack)
#endif
            .environmentObject(pilot)
        }
    }
    
    @ViewBuilder func getiOS16Root() -> some View {
        if pilot.paths.isEmpty {
            EmptyView()
        } else {
            routeMap(pilot.paths.first!.route)
        }
    }
}

class ViewGenerator<T: Equatable, Screen: View>: ObservableObject {
    var onPop: ((UIPilotPath<T>) -> Void)? = nil
    
    private var pathViews = [UIPilotPath<T>: Screen]()
    
    func build(
        _ paths: [UIPilotPath<T>],
        @ViewBuilder _  routeMap: (T) -> Screen) -> PathView<Screen>? {
            
            recycleViews(paths)
            
            var current: PathView<Screen>?
            for path in paths.reversed() {
                let view = pathViews[path] ?? routeMap(path.route)
                pathViews[path] = view
                
                let content = PathView(view, state: PathViewState())
                
                content.state.next = current
                content.state.onPop = current == nil ? {} : { [weak self] in
                    if let self = self {
                        self.onPop?(path)
                    }
                }
                current = content
            }
            return current
        }
    
    private func recycleViews(_ paths: [UIPilotPath<T>]){
        var pathViews = self.pathViews
        for key in pathViews.keys {
            if !paths.contains(key) {
                pathViews.removeValue(forKey: key)
            }
        }
        self.pathViews = pathViews
    }
}
