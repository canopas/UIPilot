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
            if #available(iOS 16.0, *) {
                UIPilotHost(pilot)  { route in
                    switch route {
                    case .Home: HomeView()
                    case .Split: SplitView()
                    case .Browser(let url): WebView(url: URL(string: url)!)
                    }
                }
            } else {
                UIPilotHost(pilot)  { route in
                    switch route {
                    case .Home: HomeView()
                    case .Split: SplitView()
                    case .Browser(let url): WebView(url: URL(string: url)!)
                    }
                }
            }
        }
    }
}
