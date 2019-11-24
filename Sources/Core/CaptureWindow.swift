import Foundation

public class CaptureWindowToken {
    
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

public func captureWindow(windowID: CGWindowID,
                          timeInterval: TimeInterval,
                          onCreateImage: @escaping (CGImage?) -> Void) -> CaptureWindowToken {
    let timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { _ in
        onCreateImage(CGWindowListCreateImage(.null, .optionIncludingWindow, windowID, .boundsIgnoreFraming))
    }
    return CaptureWindowToken(timer: timer)
}
