//
//  UIPilotHost.swift
//  NavigationStackDemo
//
//  Created by Divyesh Vekariya on 06/10/23.
//

import SwiftUI

@available(iOS 16.0, *)
public struct UIPilotHostiOS16<T: Equatable, Screen: View>: View {
    @Environment(\.dismiss) var mode
    
    @ObservedObject private var pilot: UIPilotiOS16<T>
    
    private var destination: (T) -> Screen
    
    public init(_ pilot: UIPilotiOS16<T>, @ViewBuilder destination: @escaping (T) -> Screen) {
        self.pilot = pilot
        self.destination = destination
    }
    
    @ViewBuilder
    public var body: some View {
        NavigationStack(path: $pilot._routes) {
            getRootView()
                .navigationDestination(for: UIPilotPath<T>.self) { path in
                    destination(path.route)
                }
        }
        #if !os(macOS)
        .navigationViewStyle(.stack)
        #endif
        .environmentObject(pilot)
    }
    
    @ViewBuilder
    private func getRootView() -> some View {
        if let root = pilot.root {
            destination(root.route)
        } else {
            EmptyView()
        }
    }
}
