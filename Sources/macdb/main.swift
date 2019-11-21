import Foundation

class WatchToken {
    
    private let timer: Timer
    
    init(timer: Timer) {
        self.timer = timer
    }
    
    deinit {
        timer.invalidate()
    }
    
    func cancel() {
        timer.invalidate()
    }
    
}

func watch(windowID: CGWindowID,
           timeInterval: TimeInterval,
           onCreateImage: @escaping (CGImage?) -> Void) -> WatchToken {
    let timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { _ in
        onCreateImage(CGWindowListCreateImage(.null, .optionIncludingWindow, windowID, .boundsIgnoreFraming))
    }
    return WatchToken(timer: timer)
}

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

// TODO: need to do image comparison a la https://github.com/facebookarchive/ios-snapshot-test-case/blob/master/FBSnapshotTestCase/Categories/UIImage%2BCompare.m
let token = watch(windowID: windowID, timeInterval: 1 / 5) { image in
    let mutableData = NSMutableData()
    let dest = CGImageDestinationCreateWithData(mutableData, kUTTypeJPEG, 1, nil)
    CGImageDestinationAddImage(dest!, image!, nil)
    if CGImageDestinationFinalize(dest!) {
        print("Successfully converted to JPEG")
    }
    mutableData.write(toFile: "/Users/jjgp/Downloads/\(DispatchWallTime.now().rawValue).jpg", atomically: true)
}

signal(SIGINT) { _ in
    token.cancel()
    exit(0)
}

autoreleasepool {
    RunLoop.main.run()
}
