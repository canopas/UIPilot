# UIPilot

[![Swift](https://img.shields.io/badge/Swift-5.5-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.5-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS-yellowgreen?style=flat-square)](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS-Green?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)

<img src="assets/intro-image.jpg?raw=true" height="350" />

## Why another SwiftUI navigation library?
- UIPilot is not a replacement of the SwiftUI's `NavigationView`, it's rather a wrapper around it that you would have likely written. Thus all standard `NavigationView` features like title, swipe gesture, topbar etc. are available by default.
- APIs are inspired by the android, flutter and web based routers - Very simple and easy to use.
- Typesafe navigation - Routing to wrong path will fail at compile time rather than runtime.
- Typesafe parameters - Routing with wrong parameters will fail at compile time rather than runtime.
- Very tiny library - it's barely 200 lines of code.


## How to use?

### Simple route by enum

```swift
// Define routes of the app
enum AppRoute: Equatable {
    case Home
    case Detail(id: Int)  // Typesafe parameters
    case NestedDetail
}


// Add UIPilotHost and map views with routes. That's it, you're ready to go.
struct ContentView: View {
    @StateObject var pilot = UIPilot(initial: AppRoute.Home)
    
    var body: some View {
        UIPilotHost(pilot)  { route in
            switch route {
                case .Home: HomeView()
                case .Detail(let id): DetailView(id: id)
                case .NestedDetail: NestedDetail()
            }
        }
    }
}


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
```

### Enum route with callback

```swift
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
struct CallbackUseCaseApp: App {
    @StateObject var pilot = UIPilot(initial: AppRoute.Start)

    var body: some Scene {
        WindowGroup {
            UIPilotHost(pilot)  { route in
                switch route {
                case .Start: StartView()
                case .Home: HomeView()
                case .SignIn: SignInView()
                case .Profile(let callback): ProfileView(onSignOut: callback) // Pass callback closure
                }
            }
        }
    }
}

struct StartView: View {
    @EnvironmentObject var pilot: UIPilot<AppRoute>

    var body: some View {
        VStack {
            Button("Let's Start") {
                pilot.push(.Home)
            }
        }.navigationTitle("Start")
    }
}

struct HomeView: View {
    @EnvironmentObject var pilot: UIPilot<AppRoute>

    var body: some View {
        VStack {
            Button("Sign In") {
                pilot.push(.SignIn)
            }
        }.navigationTitle("Home")
    }
}

struct SignInView: View {
    @EnvironmentObject var pilot: UIPilot<AppRoute>

    var body: some View {
        VStack {
            Button("See your profile") {
                pilot.push(.Profile(callBack: { // Peform callback action
                    self.pilot.popTo(.Home)     // Pop from current screen to home route
                }))
            }
        }.navigationTitle("Sign In")
    }
}

struct ProfileView: View {
    @EnvironmentObject var pilot: UIPilot<AppRoute>
    let onSignOut: (() -> Void)

    var body: some View {
        VStack {
            Button("Sign out")  {
                onSignOut()   // Call closure
            }
        }.navigationTitle("Profile")
    }
}
```

## Complex use cases
The library is designed to meet simple use cases as well as complex ones. You can also have nested `UIPilot` as many as you like!

For example, it's very easy to achieve split screen like behavior.

<img src="assets/complex-routing.gif?raw=true" height="500" />

```swift

enum AppRoute: Equatable {
    case Home
    case Split
    case Browser(_ url: String)
}

@main
struct ComplexSplitScreen: App {
    @StateObject var pilot = UIPilot(initial: AppRoute.Home)

    var body: some Scene {
        WindowGroup {
            UIPilotHost(pilot)  { route in
                switch route {
                case .Home: HomeView()
                case .Split: SplitView()
                case .Browser(let url): WebView(url: URL(string: url)!)
                }
            }
        }
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

struct HomeView: View {
    @EnvironmentObject var pilot: UIPilot<AppRoute>

    var body: some View {
        VStack {
            Button("Go to split screen") {
               pilot.push(.Split)
            }.foregroundColor(.white)
        }.navigationTitle("Home")
    }
}

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
                case .Home: FBHome()
                case .Detail: FBDetail()
                }
            }
            // We can add more than 1 route in single app to create split screen
            UIPilotHost(twitterPilot)  { route in
                switch route {
                case .Home: TwitterHome()
                case .Detail: TwitterDetail()
                }
            }
        }.navigationBarTitle("Apps", displayMode: .inline)
    }
}

struct FBHome: View {
    @EnvironmentObject var pilot: UIPilot<FacebookAppRoute>

    var body: some View {
        VStack {
            Button("Open FB post") {
                pilot.push(.Detail)
            }
        }.navigationTitle("Facebook Home")
    }
}

struct FBDetail: View {
    @EnvironmentObject var appPilot: UIPilot<AppRoute>

    var body: some View {
        VStack {
            Button("Open in browser") {
                appPilot.push(.Browser("https://facebook.com"))
            }
        }.navigationTitle("Facebook Post")
    }
}
```

## Examples

Please have a look at the [article](https://blog.canopas.com/swiftui-complex-navigation-made-easier-with-uipilot-5b33279f3476) and the [examples](https://github.com/canopas/UIPilot/tree/main/Examples) to know more about different use cases of UIPilot.

## Installation

Version 1.x - Uses SwiftUI NavigationView underneath.

Version 2.x - Uses UIKit UINavigationController underneath (recommended).


### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. 

Once you have your Swift package set up, adding UIPilot as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/canopas/UIPilot.git", .upToNextMajor(from: "2.0.2"))
]
```

### CocoaPods

[CocoaPods][] is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate UIPilot into your Xcode project using CocoaPods, specify it in your Podfile:

    target 'YourAppName' do
        pod 'UIPilot', '~> 2.0.2'
    end

[CocoaPods]: https://cocoapods.org

# Bugs and Feedback
For bugs, questions and discussions please use the [Github Issues](https://github.com/canopas/UIPilot/issues).

# Credits

UIPilot is owned and maintained by the [Canopas](https://canopas.com/) team. You can follow them on Twitter at [@canopassoftware](https://twitter.com/canopassoftware) for project updates and releases.
