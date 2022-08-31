//
//  StringRoutesApp.swift
//  StringRoutes
//
//  Created by Amisha I on 11/03/22.
//

import SwiftUI
import UIPilot

@main
struct StringRoutes: App {

    @StateObject var pilot = UIPilot(initial: "/start")

    var body: some Scene {
        WindowGroup {
            UIPilotHost(pilot)  { route in
                switch route {
                case "/start": StartPage()
                case "/home": HomePage()
                case "/profile": ProfilePage()
                default: EmptyView()
                }
            }
        }
    }
}
