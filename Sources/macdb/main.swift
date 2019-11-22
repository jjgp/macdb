import Core
import Foundation

// TODO: eventually this will be replaced by arguments coming in over grpc. It will also be expanded to request per PID
// as well
let windowName = "iPhone 11 — 13.2.2"

typealias CGWindowInfo = [CFString: Any]

guard let windowInfoList = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [CGWindowInfo],
    windowInfoList.count > 0 else {
        exit(1)
}

guard windowInfoList.first!.keys.contains(kCGWindowName) else {
    exit(1)
}

guard let windowID = windowInfoList
    .first(where: { $0[kCGWindowName] as? String == windowName })
    .flatMap({ $0[kCGWindowNumber] as? CGWindowID }) else {
        exit(1)
}

var previousImage: CGImage?
let token = watchWindow(windowID: windowID, timeInterval: 1.0 / 5.0) { image in
    guard previousImage == nil || image?.isSimilar(to: previousImage!, tolerance: 0.001) == false else {
        return
    }
    
    let mutableData = NSMutableData()
    let dest = CGImageDestinationCreateWithData(mutableData, kUTTypeJPEG, 1, nil)
    CGImageDestinationAddImage(dest!, image!, nil)
    if CGImageDestinationFinalize(dest!) {
        print("Successfully converted to JPEG")
    }
    mutableData.write(toFile: "/Users/jjgp/Downloads/\(DispatchWallTime.now().rawValue).jpg", atomically: true)
    
    previousImage = image
}

signal(SIGINT) { _ in
    token.cancel()
    exit(0)
}

autoreleasepool {
    RunLoop.main.run()
}
