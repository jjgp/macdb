import Foundation

protocol WindowWatcherDelegate: AnyObject {
    
    func windowWatcher(_ watcher: WindowWatcher, didCreate image: CGImage)
    // TODO: updated following methods for error reason and other metadata
    func windowWatcherDidFailToCreateImage(_ watcher: WindowWatcher)
    
}

class WindowWatcher {
    
    let windowID: CGWindowID
    // http://www.russbishop.net/the-law
    private var isWatchinglock: UnsafeMutablePointer<os_unfair_lock>
    weak var delegate: WindowWatcherDelegate?
    
    init(windowID: CGWindowID) {
        self.windowID = windowID
        isWatchinglock = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
        isWatchinglock.initialize(to: os_unfair_lock())
    }
    
}

extension WindowWatcher {
    
    func startWatching(interval: TimeInterval, queue: DispatchQueue = .main) {
        guard let delegate = delegate else {
            return
        }
        
        if let windowImage = CGWindowListCreateImage(.null, .optionIncludingWindow, windowID, .boundsIgnoreFraming) {
            delegate.windowWatcher(self, didCreate: windowImage)
        } else {
            delegate.windowWatcherDidFailToCreateImage(self)
        }
        
        queue.asyncAfter(wallDeadline: .now() + interval) { [weak self] in
            self?.startWatching(interval: interval, queue: queue)
        }
    }
    
    func stopWatching() {
        
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

class WriteToFileDelegate: WindowWatcherDelegate {
    
    func windowWatcher(_ watcher: WindowWatcher, didCreate image: CGImage) {
        let mutableData = NSMutableData()
        let dest = CGImageDestinationCreateWithData(mutableData, kUTTypeJPEG, 1, nil)
        CGImageDestinationAddImage(dest!, image, nil)
        if CGImageDestinationFinalize(dest!) {
            print("Successfully converted to JPEG")
        }
        
        mutableData.write(toFile: "/Users/jjgp/Downloads/\(DispatchWallTime.now().rawValue).jpg", atomically: true)
    }
    
    func windowWatcherDidFailToCreateImage(_ watcher: WindowWatcher) {}
    
}

// TODO: need to do image comparison a la https://github.com/facebookarchive/ios-snapshot-test-case/blob/master/FBSnapshotTestCase/Categories/UIImage%2BCompare.m
let watcher = WindowWatcher(windowID: windowID)
let delegate = WriteToFileDelegate()
watcher.delegate = delegate
watcher.startWatching(interval: 1 / 5)


signal(SIGINT) { _ in
    exit(0)
}

autoreleasepool {
    RunLoop.main.run()
}
