//
//  FBHome.swift
//  ComplexSplitScreen
//
//  Created by Amisha I on 12/03/22.
//

import SwiftUI
import UIPilot

struct FBHome: View {
    @EnvironmentObject var pilot: UIPilot<FacebookAppRoute>

    var body: some View {
        VStack {
            Button("Open FB post") {
                pilot.push(.Detail)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mint)
        .navigationTitle("Facebook Home")
    }
}

struct FBDetail: View {
    @EnvironmentObject var appPilot: UIPilot<AppRoute>

    var body: some View {
        VStack {
            Button("Open in browser") {
                appPilot.push(.Browser("https://facebook.com"))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mint)
        .navigationTitle("Facebook Post")
    }
}
