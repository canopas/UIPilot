import SwiftUI
import Combine

public class UIPilot<T: Equatable>: ObservableObject {

    let logger: Logger
    var state: UIPilotViewState<T>!

    var paths: [Path<T>] = [] {
        didSet { updateViewState() }
    }

    var routeMap: RouteMap<T>? {
        didSet { updateViewState() }
    }
    
    public var stack: [T] {
        return paths.map { $0.route }
    }
    
    public init(initial: T, debug: Bool = false) {
        logger = debug ? DebugLog() : EmptyLog()
        logger.log("UIPilot - Pilot Initialized.")

        state = UIPilotViewState(onPop: { [weak self] in
            self?.pop()
        })
        push(initial)
    }
    
    public func push(_ route: T) {
        logger.log("UIPilot - Pushing \(route) route.")
        self.paths.append(Path(route: route))
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
    
    private func updateViewState() {
        if let routeMap = routeMap {
            logger.log("UIPilot - Updating route state.")
            state.onPathsChanged(paths: paths, routeMap: routeMap)
        }
    }
}

struct Path<T: Equatable>: Equatable, Hashable {
    let route: T
    let id: String = UUID().uuidString
    
    static func == (lhs: Path, rhs: Path) -> Bool {
        return lhs.route == rhs.route && lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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
            }
#if os(iOS)
            .isDetailLink(false)
#endif
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

class UIPilotViewState<T: Equatable>: ObservableObject {
    
    private let onPop: () -> Void
    private var pathViews = [Path<T>: PathView]()

    @Published var content: PathView? = nil

    init(onPop: @escaping () -> Void) {
        self.onPop = onPop
    }
    
    func onPathsChanged(paths: [Path<T>], routeMap: RouteMap<T>) {
        content = getView(paths, routeMap)
    }

    func getView(_ paths: [Path<T>], _ routeMap: RouteMap<T>) -> PathView? {
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

public typealias RouteMap<T> = (T) -> AnyView

public struct UIPilotHost<T: Equatable>: View {

    private let pilot: UIPilot<T>

    @ObservedObject
    private var state: UIPilotViewState<T>

    public init(_ pilot: UIPilot<T>, _ routeMap: @escaping RouteMap<T>) {
        self.pilot = pilot
        self.state = pilot.state
        self.pilot.routeMap = routeMap
    }

    public var body: some View {
        NavigationView {
            state.content
        }
#if !os(macOS)
        .navigationViewStyle(.stack)
#endif
        .environmentObject(pilot)
    }
}

protocol Logger {
    func log(_ value: String)
}
