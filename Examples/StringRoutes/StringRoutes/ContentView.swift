//
//  ContentView.swift
//  StringRoutes
//
//  Created by Amisha I on 11/03/22.
//

import SwiftUI
import UIPilot

struct StartPage: View {
    @EnvironmentObject var pilot: UIPilot<String>

    var body: some View {
        Button {
            pilot.push("/home")
        } label: {
            Text("Let's Start")
                .padding()
                .foregroundColor(.white)
        }
        .background(.blue)
    }
}

struct HomePage: View {
    @EnvironmentObject var pilot: UIPilot<String>

    var body: some View {
        VStack {
            Button {
                pilot.push("/profile")
            } label: {
                Text("Show my profile")
                    .padding()
                    .foregroundColor(.white)
            }
            .background(.blue)

            Button {
                pilot.pop()
            } label: {
                Text("Go back")
                    .padding()
                    .foregroundColor(.white)
            }
            .background(.yellow)
        }.navigationTitle("home")
    }
}

struct ProfilePage: View {
    @EnvironmentObject var pilot: UIPilot<String>

    var body: some View {
        VStack {
            Button {
                pilot.popTo("/start")
            } label: {
                Text("Go to start")
                    .padding()
                    .foregroundColor(.white)
            }
            .background(.blue)

            Button {
                pilot.pop()
            } label: {
                Text("Go back")
                    .padding()
                    .foregroundColor(.white)
            }
            .background(.yellow)
        }.navigationTitle("Profile")
    }
}

