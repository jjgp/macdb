import Core
import Foundation
import GRPC
import MacDBModel
import NIO

class WindowProvider: MacDB_WindowProvider {
    
    var task: RepeatedTask?
    
    func capture(
        request: MacDB_WindowInfo,
        context: StreamingResponseCallContext<MacDB_WindowCapture>
    ) -> EventLoopFuture<GRPCStatus> {
        task?.cancel()
        let promise: EventLoopPromise<GRPCStatus> = context.eventLoop.makePromise()
        task = context.startWindowCaptureTask(for: request)
        return promise.futureResult
    }
    
}

private extension StreamingResponseCallContext where ResponseMessage == MacDB_WindowCapture {
    
    func startWindowCaptureTask(for windowInfo: MacDB_WindowInfo) -> RepeatedTask? {
        // TODO: documnenting comment on these guards!
        guard let windowInfoList = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[CFString: Any]],
            windowInfoList.count > 0 else {
                statusPromise.fail(GRPCStatus.processingError)
                return nil
        }
        
        guard windowInfoList.first!.keys.contains(kCGWindowName) else {
            statusPromise.fail(GRPCStatus.processingError)
            return nil
        }
        
        guard let windowID = windowInfoList
            .first(where: { $0[kCGWindowName] as? String == windowInfo.name })
            .flatMap({ $0[kCGWindowNumber] as? CGWindowID }) else {
                statusPromise.fail(GRPCStatus.processingError)
                return nil
        }
        
        return windowCaptureTask(for: windowID)
    }
    
    private func windowCaptureTask(for windowID: CGWindowID) -> RepeatedTask {
        var previousImage: CGImage?
        
        func repeatedTask(_ task: RepeatedTask) {
            let image = CGWindowListCreateImage(.null, .optionIncludingWindow, windowID, .boundsIgnoreFraming)
            defer {
                previousImage = image
            }
            // TODO: if it has been similar for a certain period of time fail out!
            guard previousImage == nil || image?.isSimilar(to: previousImage!, tolerance: 0.001) == false else {
                return
            }
            
            let mutableData = NSMutableData()
            let dest = CGImageDestinationCreateWithData(mutableData, kUTTypeJPEG, 1, nil)
            CGImageDestinationAddImage(dest!, image!, nil)
            if CGImageDestinationFinalize(dest!) {
                _ = sendResponse(
                    .with {
                        $0.image = mutableData.base64EncodedString()
                    }
                ).recover {
                    // TODO: hopefully this is can be replaced by error propagation in the StreamEvent type
                    if case ChannelError.ioOnClosedChannel = $0 {
                        task.cancel()
                    }
                }
            }
        }
        
        return eventLoop.scheduleRepeatedTask(initialDelay: .milliseconds(0),
                                              delay: .milliseconds(100),
                                              repeatedTask)
    }
    
}
