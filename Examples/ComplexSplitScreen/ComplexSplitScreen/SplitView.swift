//
//  SplitView.swift
//  ComplexSplitScreen
//
//  Created by Amisha I on 12/03/22.
//

import SwiftUI
import UIPilot
import WebKit


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
            UIPilotHost(twitterPilot)  { route in
                switch route {
                case .Home: return AnyView(TwitterHome())
                case .Detail: return AnyView(TwitterDetail())
                }
            }
        }
        .navigationBarTitle("Apps", displayMode: .inline)
    }
}

struct WebView: UIViewRepresentable {
    
    var url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
