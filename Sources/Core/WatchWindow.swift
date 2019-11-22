import Foundation

public class WatchWindowToken {
    
    private let timer: Timer
    
    init(timer: Timer) {
        self.timer = timer
    }
    
    deinit {
        timer.invalidate()
    }
    
    public func cancel() {
        timer.invalidate()
    }
    
}

public func watchWindow(windowID: CGWindowID,
                        timeInterval: TimeInterval,
                        onCreateImage: @escaping (CGImage?) -> Void) -> WatchWindowToken {
    let timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { _ in
        onCreateImage(CGWindowListCreateImage(.null, .optionIncludingWindow, windowID, .boundsIgnoreFraming))
    }
    return WatchWindowToken(timer: timer)
}
