//
//  ContentView.swift
//  CallbackUseCase
//

//  Created by Amisha I on 12/03/22.
//

import SwiftUI
import UIPilot

struct StartView: View {
    @EnvironmentObject var pilot: UIPilot<AppRoute>

    var body: some View {
        VStack {
            Button("Let's Start") {
                pilot.push(.Home)
            }
            .padding()
            .background(.cyan)
        }
        .navigationTitle("Start")
    }
}

struct HomeView: View {
    @EnvironmentObject var pilot: UIPilot<AppRoute>

    var body: some View {
        VStack {
            Button("Sign In") {
                pilot.push(.SignIn)
            }
            .padding()
            .background(.green)
        }
        .navigationTitle("Home")
    }
}

struct SignInView: View {
    @EnvironmentObject var pilot: UIPilot<AppRoute>

    var body: some View {
        VStack {
            Button("See your profile") {
                pilot.push(.Profile(callBack: { // Peform callback action
                    self.pilot.popTo(.Home) // Pop from current screen to home route
                }))
            }
            .padding()
            .background(.yellow)
        }
        .navigationTitle("Sign In")
    }
}

struct ProfileView: View {

    @EnvironmentObject var pilot: UIPilot<AppRoute>
    let onSignOut: (() -> Void)

    var body: some View {
        VStack {
            Button("Sign out")  {
                onSignOut() // Call closure
            }
            .padding()
            .background(.red)
        }
        .navigationTitle("Profile")
    }
}
