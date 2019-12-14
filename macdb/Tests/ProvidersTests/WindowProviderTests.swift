import Foundation
import GRPC
import Mocked
import XCTest
import Model
@testable import Providers

final class WindowProviderTests: XCTestCase {}

extension WindowProviderTests {
    
    func testExample() throws {
        let mockedEventLoop = EventLoopMocked()
        let mockedContext = StreamingResponseCallContextMocked<MacDB_WindowCapture>(
            eventLoop: mockedEventLoop,
            request: .init(version: .init(major: 0, minor: 0), method: .GET, uri: "uri"),
            logger: .init(label: "label")
        )
        
        let subject = WindowProvider()
        _ = subject.capture(request: .init(),
                            context: mockedContext)
    }
    
}

extension WindowProviderTests {
    
    static var allTests = [
        ("testExample", testExample),
    ]
    
}

extension StreamingResponseCallContextMocked where ResponseMessage == MacDB_WindowCapture {}
