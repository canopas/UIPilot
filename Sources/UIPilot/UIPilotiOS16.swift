//
//  UIPilotiOS16.swift
//
//
//  Created by Divyesh Vekariya on 06/10/23.
//

import SwiftUI

@available(iOS 16.0, *)
public class UIPilotiOS16<T: Equatable>: ObservableObject {
    private let logger: Logger
    
    @Published var _routes: [UIPilotPath<T>] = []
    @Published var root: UIPilotPath<T>? = nil
    
    public var routes: [T] {
        return _routes.map({ $0.route })
    }
    
    public init(initial: T? = nil, debug: Bool = false) {
        logger = debug ? DebugLog() : EmptyLog()
        logger.log("UIPilot - Pilot Initialized.")
        
        self.root = initial != nil ? .init(route: initial!) : nil
    }
    
    public func push(_ route: T) {
        logger.log("UIPilot - Pushing \(route) route.")
        _routes.append(.init(route: route))
    }
    
    public func popToRoot() {
        logger.log("UIPilot - Popping to root.")
        self._routes.removeAll()
        logger.log("UIPilot - Popped to root.")
    }
    
    public func pop(animated: Bool = true) {
        if !self._routes.isEmpty, let popped = self._routes.popLast() {
            logger.log("UIPilot - \(popped) route popped.")
        }
    }
    
    public func popTo(_ route: T, inclusive: Bool = false, animated: Bool = false) {
        logger.log("UIPilot: Popping route \(route).")
        if animated {
            if self._routes.last?.route != route {
                self._routes.removeLast()
                popTo(route)
            }
        } else {
            if _routes.isEmpty {
                logger.log("UIPilot - Path is empty.")
                return
            }
            
            guard var found = _routes.lastIndex(where: { $0.route == route }) else {
                logger.log("UIPilot - Route not found.")
                return
            }
            
            if !inclusive {
                found += 1
            }
            
            let numToPop = (found..<_routes.endIndex).count
            logger.log("UIPilot - Popping \(numToPop) _routes")
            _routes.removeLast(numToPop)
        }
    }
    
    @available(iOS 16.0, *)
    public func updateRoot(with route: T) {
        root = .init(route: route)
        logger.log("UIPilot: Updated root with \(route).")
    }
}
