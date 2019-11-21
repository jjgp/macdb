import Cocoa

//class WindowWatcher {
//
//    init?(windowID: CGWindowID) {
//        guard let windowInfoList = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[CFString : Any]],
//            let windowInfo = windowInfoList.first { $0[kCGWindowNumber] as? Int == windowID } else {
//                return nil
//        }
//    }
//
//}

typealias CGWindowInfo = [CFString: Any]

func firstCGWindowInfo(where predicate: (CGWindowInfo) throws -> Bool) rethrows -> CGWindowInfo? {
    return try (CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [CGWindowInfo])
        .flatMap { try $0.first(where: predicate) }
}

func hasAllowedScreenRecording() -> Bool {
    // TODO: really shouldn't be false if there are no windows!
    return (CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [CGWindowInfo])?
        .first?
        .keys
        .contains(kCGWindowName)
        ?? false
}

guard hasAllowedScreenRecording(),
    let windowInfo = firstCGWindowInfo(where: { $0[kCGWindowName] as? String == "iPhone 11 — 13.2.2" }),
    let windowID = windowInfo[kCGWindowNumber] as? CGWindowID else {
        exit(1)
}

let windowImageRef = CGWindowListCreateImage(.null, .optionIncludingWindow, windowID, .boundsIgnoreFraming)

// TODO: need to do image comparison a la https://github.com/facebookarchive/ios-snapshot-test-case/blob/master/FBSnapshotTestCase/Categories/UIImage%2BCompare.m

let mutableData = NSMutableData()
let dest = CGImageDestinationCreateWithData(mutableData, kUTTypeJPEG, 1, nil)
CGImageDestinationAddImage(dest!, windowImageRef!, nil)
if CGImageDestinationFinalize(dest!) {
    print("Successfully converted to JPEG")
}
mutableData.write(toFile: "/Users/jjgp/Downloads/bar.jpg", atomically: true)

signal(SIGINT) { _ in
    exit(0)
}

autoreleasepool {
    RunLoop.main.run()
}
