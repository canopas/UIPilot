//
//  CallbackUseCaseApp.swift
//  CallbackUseCase
//
//  Created by Amisha I on 12/03/22.
//

import SwiftUI
import UIPilot

// Define routes of the app
enum AppRoute: Equatable {

    // As swift not able to identify type of closure by default
    static func == (lhs: AppRoute, rhs: AppRoute) -> Bool {
        return lhs.key == rhs.key
    }

    case Start
    case Home
    case SignIn
    case Profile(callBack: (() -> Void))  // Nonescaping Closure

    var key: String {
        switch self {
        case .Start:
            return "Start"
        case .Home:
            return "Home"
        case .SignIn:
            return "SignIn"
        case .Profile:
            return "Profile"
        }
    }
}

@main
struct CallbackUseCase: App {

    @StateObject var pilot = UIPilot(initial: AppRoute.Start)

    var body: some Scene {
        WindowGroup {
            UIPilotHost(pilot)  { route in
                switch route {
                case .Start: return AnyView(StartView())
                case .Home: return AnyView(HomeView())
                case .SignIn: return AnyView(SignInView())
                case .Profile(let callback): return AnyView(ProfileView(onSignOut: callback)) // Pass callback closure
                }
            }
        }
    }
}
