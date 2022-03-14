//
//  SplitView.swift
//  ComplexSplitScreen
//
//  Created by Amisha I on 12/03/22.
//

import SwiftUI
import UIPilot

enum FacebookAppRoute: Equatable {
    case Home
    case Detail
}

enum TwitterAppRoute: Equatable {
    case Home
    case Detail
}

struct SplitView: View {
    
    @EnvironmentObject var pilot: UIPilot<AppRoute>
    @StateObject var fbPilot = UIPilot(initial: FacebookAppRoute.Home)
    @StateObject var twitterPilot = UIPilot(initial: TwitterAppRoute.Home)
    
    var body: some View {
        VStack {
            UIPilotHost(fbPilot)  { route in
                switch route {
                case .Home: return AnyView(FBHome())
                case .Detail: return AnyView(FBDetail())
                }
            }

            Button("Go back") {
                pilot.pop()
            }.foregroundColor(.black)

            // We can add more than 1 route in single app to create split screen
            UIPilotHost(twitterPilot)  { route in
                switch route {
                case .Home: return AnyView(TwitterHome())
                case .Detail: return AnyView(TwitterDetail())
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarTitle("Apps", displayMode: .inline)
    }
}
