import Foundation

class WatchWindowToken {
    
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

func watchWindow(windowID: CGWindowID,
                 timeInterval: TimeInterval,
                 onCreateImage: @escaping (CGImage?) -> Void) -> WatchWindowToken {
    let timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { _ in
        onCreateImage(CGWindowListCreateImage(.null, .optionIncludingWindow, windowID, .boundsIgnoreFraming))
    }
    return WatchWindowToken(timer: timer)
}

extension CGImage {
    
    // Attribution: https://github.com/facebookarchive/ios-snapshot-test-case (FBSnapshotTestCase/Categories/UIImage+Compare.m)
    func isSimilar(to other: CGImage, tolerance: CGFloat) -> Bool {
        guard other.width == width,
            other.height == height else {
                return false
        }
        
        let minBytesPerRow = min(other.bytesPerRow, bytesPerRow)
        let imageSizeBytes = height * minBytesPerRow
        let imagePixels = calloc(1, imageSizeBytes)
        let otherImagePixels = calloc(1, imageSizeBytes)
        guard imagePixels != nil,
            otherImagePixels != nil,
            let colorSpace = colorSpace,
            let otherImageColorSpace = other.colorSpace else {
                free(imagePixels)
                free(otherImagePixels)
                return false
        }
        
        let imageContext = CGContext(data: imagePixels,
                                     width: width,
                                     height: height,
                                     bitsPerComponent: bitsPerComponent,
                                     bytesPerRow: minBytesPerRow,
                                     space: colorSpace,
                                     bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        let otherImageContext = CGContext(data: otherImagePixels,
                                          width: other.width,
                                          height: other.height,
                                          bitsPerComponent: other.bitsPerComponent,
                                          bytesPerRow: minBytesPerRow,
                                          space: otherImageColorSpace,
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard imageContext != nil,
            otherImageContext != nil else {
                free(imagePixels)
                free(otherImagePixels)
                return false
        }
        
        imageContext?.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        otherImageContext?.draw(other, in: CGRect(x: 0, y: 0, width: other.width, height: other.height))
        
        var isEqual = true
        if tolerance == .zero {
            isEqual = memcmp(imagePixels!, otherImagePixels!, imageSizeBytes) == 0
        } else {
            let pixelCount = width * height
            var p1 = imagePixels!.assumingMemoryBound(to: UInt32.self)
            var p2 = otherImagePixels!.assumingMemoryBound(to: UInt32.self)
            var numDiffPixels = 0
            for _ in 0..<pixelCount {
                if p1.pointee != p2.pointee {
                    numDiffPixels += 1
                    let percent = CGFloat(numDiffPixels) / CGFloat(pixelCount)
                    if percent > tolerance {
                        isEqual = false
                        break
                    }
                }
                p1 += 1
                p2 += 1
            }
        }
        
        free(imagePixels)
        free(otherImagePixels)
        return isEqual
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
