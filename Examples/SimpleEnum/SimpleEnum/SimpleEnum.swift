//
//  SimpleEnum.swift
//  SimpleEnumApp
//
//  Created by Amisha I on 11/03/22.
//

import SwiftUI
import UIPilot

// Define routes of the app
enum AppRoute: Equatable {
    case Home
    case Detail(id: Int)  // Typesafe parameters
    case NestedDetail
}


// Add UIPilotHost and map views with routes. That's it, you're ready to go.
@main
struct SimpleEnum: App {
    @StateObject var pilot = UIPilot(initial: AppRoute.Home)

    var body: some Scene {
        WindowGroup {
            UIPilotHost(pilot)  { route in
                switch route {
                    case .Home: return AnyView(HomeView())
                    case .Detail(let id): return AnyView(DetailView(id: id))
                    case .NestedDetail: return AnyView(NestedDetail())
                }
            }
        }
    }
}
