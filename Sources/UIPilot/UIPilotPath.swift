//
//  UIPilotPath.swift
//  
//
//  Created by Divyesh Vekariya on 09/10/23.
//

import Foundation

struct UIPilotPath<T: Equatable>: Equatable, Hashable {
    let id: String = UUID().uuidString
    let route: T
    
    static func == (lhs: UIPilotPath, rhs: UIPilotPath) -> Bool {
        return lhs.route == rhs.route && lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
