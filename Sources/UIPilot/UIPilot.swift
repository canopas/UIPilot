import SwiftUI
import Combine

public class UIPilot<T: Equatable>: ObservableObject {

    private let logger: Logger
    
    @Published var paths: [UIPilotPath<T>] = []

    public var stack: [T] {
        return paths.map { $0.route }
    }

    public init(initial: T, debug: Bool = false) {
        logger = debug ? DebugLog() : EmptyLog()
        logger.log("UIPilot - Pilot Initialized.")

        push(initial)
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

struct UIPilotPath<T: Equatable>: Equatable, Hashable {
    let route: T
    let id: String = UUID().uuidString

    static func == (lhs: UIPilotPath, rhs: UIPilotPath) -> Bool {
        return lhs.route == rhs.route && lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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
        NavigationView {
            viewGenerator.build(pilot.paths, routeMap)
        }
#if !os(macOS)
        .navigationViewStyle(.stack)
#endif
        .environmentObject(pilot)
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

protocol Logger {
    func log(_ value: String)
}
