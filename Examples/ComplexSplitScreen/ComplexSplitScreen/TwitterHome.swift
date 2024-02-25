//
//  TwitterHome.swift
//  ComplexSplitScreen
//
//  Created by Amisha I on 12/03/22.
//

import SwiftUI
//import UIPilot

struct TwitterHome: View {
    @EnvironmentObject var pilot: UIPilot<TwitterAppRoute>

    var body: some View {
        VStack {
            Button("Open Twitter post") {
                pilot.push(.Detail)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.yellow)
        .navigationTitle("Twitter Home")
    }
}

struct TwitterDetail: View {
    @EnvironmentObject var appPilot: UIPilot<AppRoute>

    var body: some View {
        VStack {
            Button("Open in browser") {
                appPilot.push(.Browser("https://twitter.com/home"))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.yellow)
        .navigationTitle("Twitter Post")
    }
}
