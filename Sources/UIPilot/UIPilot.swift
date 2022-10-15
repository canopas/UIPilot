import SwiftUI
import Combine

public class UIPilot<T: Hashable>: ObservableObject {

    private let logger: Logger
        
    private var _routes: [T] = []
    
    var routes: [T] {
        return _routes
    }
    
    var onPush: ((T) -> Void)?
    var onPopLast: ((Int, Bool) -> Void)?


    public init(initial: T? = nil, debug: Bool = false) {
        logger = debug ? DebugLog() : EmptyLog()
        logger.log("UIPilot - Pilot Initialized.")

        
        if let initial = initial {
            push(initial)
        }
    }

    public func push(_ route: T) {
        logger.log("UIPilot - Pushing \(route) route.")
        self._routes.append(route)
        self.onPush?(route)
    }

    public func pop(animated: Bool = true) {
        if !self._routes.isEmpty {
            let popped = self._routes.removeLast()
            logger.log("UIPilot - \(popped) route popped.")
            onPopLast?(1, animated)
        }
    }

    public func popTo(_ route: T, inclusive: Bool = false, animated: Bool = true) {
        logger.log("UIPilot: Popping route \(route).")

        if _routes.isEmpty {
            logger.log("UIPilot - Path is empty.")
            return
        }

        guard var found = _routes.lastIndex(where: { $0 == route }) else {
            logger.log("UIPilot - Route not found.")
            return
        }

        if !inclusive {
            found += 1
        }

        let numToPop = (found..<_routes.endIndex).count
        logger.log("UIPilot - Popping \(numToPop) routes")
        _routes.removeLast(numToPop)
        onPopLast?(numToPop, animated)
    }
    
    public func onSystemPop() {
        if !self._routes.isEmpty {
            let popped = self._routes.removeLast()
            logger.log("UIPilot - \(popped) route popped by system")
        }
    }

}

public struct UIPilotHost<T: Hashable, Screen: View>: View {

    @ObservedObject
    var pilot: UIPilot<T>
    @ViewBuilder
    var routeMap: (T) -> Screen
    
    public init(_ pilot: UIPilot<T>, @ViewBuilder _ routeMap: @escaping (T) -> Screen) {
        self.pilot = pilot
        self.routeMap = routeMap
    }

    public var body: some View {
        NavigationControllerHost(uipilot: pilot, routeMap: routeMap)
            .environmentObject(pilot)
    }
}

struct NavigationControllerHost<T: Hashable, Screen: View>: UIViewControllerRepresentable {
    let uipilot: UIPilot<T>
    @ViewBuilder
    let routeMap: (T) -> Screen

    func makeUIViewController(context: Context) -> UINavigationController {
        let navigation = PopAwareUINavigationController()
        navigation.popHandler = {
            uipilot.onSystemPop()
        }
        
        for path in uipilot.routes {
            navigation.pushViewController(
                UIHostingController(rootView: routeMap(path)), animated: false)
        }
        
        uipilot.onPush = { route in
            navigation.pushViewController(
                UIHostingController(rootView: routeMap(route)), animated: true)
        }
        
        uipilot.onPopLast = { numToPop, animated in
            if numToPop == navigation.viewControllers.count {
                navigation.viewControllers = []
            } else {
                let popTo = navigation.viewControllers[navigation.viewControllers.count - numToPop - 1]
                navigation.popToViewController(popTo, animated: animated)
            }
        }
        
        return navigation
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        
    }
        
    typealias UIViewControllerType = UINavigationController
}

class PopAwareUINavigationController: UINavigationController
{
    var popHandler: (() -> Void)?

    override func popViewController(animated: Bool) -> UIViewController?
    {
        popHandler?()
        return super.popViewController(animated: animated)
    }
}

protocol Logger {
    func log(_ value: String)
}
