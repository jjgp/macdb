import Foundation

class WindowWatcher {
    
    let windowID: CGWindowID
    
    init(windowID: CGWindowID) {
        self.windowID = windowID
    }
    
}

extension WindowWatcher {
    
    func recordImage() {
        let windowImage = CGWindowListCreateImage(.null, .optionIncludingWindow, windowID, .boundsIgnoreFraming)
        
        let mutableData = NSMutableData()
        let dest = CGImageDestinationCreateWithData(mutableData, kUTTypeJPEG, 1, nil)
        CGImageDestinationAddImage(dest!, windowImage!, nil)
        if CGImageDestinationFinalize(dest!) {
            print("Successfully converted to JPEG")
        }
        
        mutableData.write(toFile: "/Users/jjgp/Downloads/\(DispatchWallTime.now().rawValue).jpg", atomically: true)
    }
    
}

extension WindowWatcher {
    
    func startRecording() {
        recordImage()
    }
    
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

WindowWatcher(windowID: windowID)
    .startRecording()


signal(SIGINT) { _ in
    exit(0)
}

autoreleasepool {
    RunLoop.main.run()
}
