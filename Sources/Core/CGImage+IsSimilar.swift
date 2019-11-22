import Foundation

extension CGImage {
    
    // Attribution: https://github.com/facebookarchive/ios-snapshot-test-case (FBSnapshotTestCase/Categories/UIImage+Compare.m)
    public func isSimilar(to other: CGImage, tolerance: CGFloat) -> Bool {
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
