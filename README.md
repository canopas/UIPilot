# UIPilot
The missing typesafe SwiftUI navigation library

[![Swift](https://img.shields.io/badge/Swift-5.5-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.5-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS-yellowgreen?style=flat-square)](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS-Green?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)

## Why another SwiftUI navigation library?
- UIPilot is not a replacement of the SwiftUI's `NavigationView`, it's rather a wrapper around it that you would have likely written. Thus all standard `NavigationView` features like title, swipe gesture, topbar etc. are available by default.
- APIs are inspired by the android, flutter and web based routers - Very simple and easy to use.
- Typesafe navigation - Routing to wrong path will fail at compile time rather than runtime.
- Typesafe parameters - Routing with wrong parameters will fail at compile time rather than runtime.
- Very tiny library - it's barely 100 lines of code.

## How to use?

```swift
// Define routes of the app
enum AppRoute: Hashable {
    case Home
    case Detail(id: Int)  // Typesafe parameters
    case NestedDetail
}


// Add UIPilotHost and map views with routes. That's it, you're ready to go.
struct ContentView: View {
    let pilot = UIPilot(AppRoute.Home)
    
    var body: some View {
        UIPilotHost(pilot) { route in
            switch route {
            case .Home: return AnyView(HomeView())
            case .Detail(let id): return AnyView(DetailView(id: id))
            case .NestedDetail: return AnyView(NestedDetail())
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
                pilot.push(AppRoute.Detail(id: 11))    // Pass arguments
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
                pilot.push(AppRoute.NestedDetail)
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

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. 

Once you have your Swift package set up, adding UIPilot as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/canopas/UIPilot.git", .upToNextMajor(from: "1.0.0"))
]
```

# Bugs and Feedback
For bugs, questions and discussions please use the [Github Issues](https://github.com/canopas/JetTapTarget/issues).

# Credits

UIPilot is owned and maintained by the [Canopas](https://canopas.com/) team. You can follow them on Twitter at [@canopassoftware](https://twitter.com/canopassoftware) for project updates and releases.

# Licence

```
Copyright 2022 Canopas Software LLP

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
