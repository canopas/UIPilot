import SwiftUI
import XCTest
@testable import UIPilot

final class UIPilotTests: XCTestCase {
    
    enum PageName {
        case first, second, third
    }
    
    func testPaths() throws {
        let pilot = UIPilot<PageName>(initial: .first)

        let _ = UIPilotHost(pilot) { route in
            switch route {
            case .first: return AnyView(Text("First Page"))
            case .second: return AnyView(Text("Second Page"))
            case .third: return AnyView(Text("Third Page"))
            }
        }
        
        XCTAssertNotNil(pilot.routeMap?(.first))
        XCTAssertNotNil(pilot.routeMap?(.second))
        XCTAssertNotNil(pilot.routeMap?(.third))

        XCTAssertEqual(pilot.paths.count, 1)
        XCTAssertEqual(pilot.paths[0].route, .first)
        
        pilot.push(.second)
        XCTAssertEqual(pilot.paths.count, 2)
        XCTAssertEqual(pilot.paths[0].route, .first)
        XCTAssertEqual(pilot.paths[1].route, .second)
        
        pilot.push(.third)
        XCTAssertEqual(pilot.paths.count, 3)
        XCTAssertEqual(pilot.paths[0].route, .first)
        XCTAssertEqual(pilot.paths[1].route, .second)
        XCTAssertEqual(pilot.paths[2].route, .third)
        
        pilot.pop()
        XCTAssertEqual(pilot.paths.count, 2)
        XCTAssertEqual(pilot.paths[0].route, .first)
        XCTAssertEqual(pilot.paths[1].route, .second)
        
        pilot.push(.third)
        pilot.popTo(.first)
        XCTAssertEqual(pilot.paths.count, 1)
        XCTAssertEqual(pilot.paths[0].route, .first)
        
        pilot.popTo(.second)
        XCTAssertEqual(pilot.paths.count, 1)
        XCTAssertEqual(pilot.paths[0].route, .first)
        
        pilot.pop()
        XCTAssertEqual(pilot.paths.count, 0)
        
        pilot.popTo(.first)
    }
}
