//
//  HomeView.swift
//  ComplexSplitScreen
//
//  Created by Amisha I on 12/03/22.
//

import SwiftUI
import UIPilot

struct HomeView: View {
    @EnvironmentObject var pilot: UIPilot<AppRoute>

    var body: some View {
        VStack {
            Button("Go to split screen") {
               pilot.push(.Split)
            }
        }
        .navigationTitle("Home")
    }
}
