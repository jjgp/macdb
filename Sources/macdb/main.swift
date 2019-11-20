import Foundation

let windowList = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[String : Any]]
let simulatorWindowInfo = windowList?.first { $0[String(kCGWindowOwnerName)] as? String == "Simulator" }
let simulatorWindowID = simulatorWindowInfo?[String(kCGWindowNumber)] as? CGWindowID
let windowImageRef = simulatorWindowID.map {
    CGWindowListCreateImage(.null, .optionIncludingWindow, $0, .boundsIgnoreFraming)
}

signal(SIGINT) { _ in
    exit(0)
}

autoreleasepool {
    RunLoop.main.run()
}
