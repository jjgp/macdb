import Core
import Foundation
import GRPC
import MacDBModel
import NIO

class WindowProvider: MacDB_WindowProvider {
    
    // TODO: instead use RepeatedTask
    static var previousImage: CGImage?
    static var token: CaptureWindowToken?
    
    // TODO: more meaningfull GRPCStatus Errors
    func capture(
        context: StreamingResponseCallContext<MacDB_WindowCapture>
    ) -> EventLoopFuture<(StreamEvent<MacDB_WindowInfo>) -> Void> {
        func sendImage(image: CGImage?) {
            // TODO: handle nil image
            defer {
                WindowProvider.previousImage = image
            }
            // TODO: tolerance should come out of configuration
            guard WindowProvider.previousImage == nil || image?.isSimilar(to: WindowProvider.previousImage!, tolerance: 0.001) == false else {
                return
            }
            
            let mutableData = NSMutableData()
            let dest = CGImageDestinationCreateWithData(mutableData, kUTTypeJPEG, 1, nil)
            CGImageDestinationAddImage(dest!, image!, nil)
            if CGImageDestinationFinalize(dest!) {
                _ = context.sendResponse(
                    .with {
                        $0.image = mutableData.base64EncodedString()
                    }
                )
            }
        }
        
        return context.eventLoop.makeSucceededFuture({ event in
            WindowProvider.token?.cancel()
            switch event {
            case .message(let windowInfo):
                // TODO: documnenting comment on these guards!
                guard let windowInfoList = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[CFString: Any]],
                    windowInfoList.count > 0 else {
                        context.statusPromise.fail(GRPCStatus.processingError)
                        return
                }
                
                guard windowInfoList.first!.keys.contains(kCGWindowName) else {
                    context.statusPromise.fail(GRPCStatus.processingError)
                    return
                }
                
                guard let windowID = windowInfoList
                    .first(where: { $0[kCGWindowName] as? String == windowInfo.name })
                    .flatMap({ $0[kCGWindowNumber] as? CGWindowID }) else {
                        context.statusPromise.fail(GRPCStatus.processingError)
                        return
                }
                
                // TODO: timeInterval should come out of configuration
                DispatchQueue.main.async {                
                    WindowProvider.token = captureWindow(windowID: windowID,
                                                         timeInterval: 1 / 5,
                                                         onCreateImage: sendImage)
                }
            case .end:
                context.statusPromise.succeed(.ok)
            }
        })
    }
    
}
