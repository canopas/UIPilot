//
//  ContentView.swift
//  SimpleEnumApp
//
//  Created by Amisha I on 11/03/22.
//

import SwiftUI
import UIPilot

// UIPilot is available as an EnvironmetObject. Push and pop routes as ususal.
struct HomeView: View {
    @EnvironmentObject var pilot: UIPilot<AppRoute>

    var body: some View {
        VStack {
            Button("Go to detail", action: {
                pilot.push(.Detail(id: 11))    // Pass arguments
            })
        }.navigationTitle("Home")  // Set title using standard NavigationView APIs
    }
}

// Popping current route
struct DetailView: View {
    @EnvironmentObject var pilot: UIPilot<AppRoute>
    let id: Int

    var body: some View {
        VStack {
            Text("Passed id \(id)").padding()
            Button("Go to nested detail", action: {
                pilot.push(.NestedDetail)
            })
            Button("Go back", action: {
                pilot.pop() // Pop current route
            })
        }.navigationTitle("Detail")
    }
}

// Popping multiple routes
struct NestedDetail: View {
    @EnvironmentObject var pilot: UIPilot<AppRoute>

    var body: some View {
        VStack {
            Button("Go to home", action: {
                pilot.popTo(.Home)   // Pop to home
            })
        }.navigationTitle("Nested detail")
    }
}
