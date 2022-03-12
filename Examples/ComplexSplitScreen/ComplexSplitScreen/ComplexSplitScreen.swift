//
//  ComplexSplitScreen.swift
//  ComplexSplitScreen
//
//  Created by Amisha I on 12/03/22.
//

import SwiftUI
import UIPilot

enum AppRoute: Equatable {
    case Home
    case Split
    case Browser(_ url: String)
}

@main
struct ComplexSplitScreen: App {
    
    @StateObject var pilot = UIPilot(initial: AppRoute.Home)

    var body: some Scene {
        WindowGroup {
            UIPilotHost(pilot)  { route in
                switch route {
                case .Home: return AnyView(HomeView())
                case .Split: return AnyView(SplitView())
                case .Browser(let url): return AnyView(WebView(url: URL(string: url)!))
                }
            }
        }
    }
}
