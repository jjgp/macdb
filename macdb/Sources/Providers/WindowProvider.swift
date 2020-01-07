import Core
import Foundation
import GRPC
import Model
import NIO

public class WindowProvider: MacDB_WindowProvider {
    
    public init() {}
    
}

// MARK:- Capture

public extension WindowProvider {
    
    func capture(
        request: MacDB_WindowInfo,
        context: StreamingResponseCallContext<MacDB_WindowCapture>
    ) -> EventLoopFuture<GRPCStatus> {
        return context.startWindowCaptureTask(for: request)
    }
    
}

private extension StreamingResponseCallContext where ResponseMessage == MacDB_WindowCapture {
    
    // TODO: refactor out the acquisition of the window so that the x, y of the bounds may be used to send a tap event
    func startWindowCaptureTask(for windowInfo: MacDB_WindowInfo) -> EventLoopFuture<GRPCStatus> {
        // TODO: documnenting comment on these guards!
        guard let windowInfoList = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[CFString: Any]],
            windowInfoList.count > 0 else {
                return eventLoop.makeFailedFuture(GRPCStatus.processingError)
        }
        
        guard windowInfoList.first!.keys.contains(kCGWindowName) else {
            // TODO: Trigger prompt
            let firstID = windowInfoList.first![kCGWindowNumber] as? CGWindowID ?? 0
            CGWindowListCreateImage(.null, .optionIncludingWindow, firstID, [.boundsIgnoreFraming, .nominalResolution])
            return eventLoop.makeFailedFuture(GRPCStatus.processingError)
        }
        
        guard let windowID = windowInfoList
            .first(where: { $0[kCGWindowName] as? String == windowInfo.name })
            .flatMap({ $0[kCGWindowNumber] as? CGWindowID }) else {
                return eventLoop.makeFailedFuture(GRPCStatus.processingError)
        }
        
        return windowCaptureTask(for: windowID)
    }
    
    private func windowCaptureTask(for windowID: CGWindowID) -> EventLoopFuture<GRPCStatus> {
        var previousImage: CGImage?
        let promise: EventLoopPromise<GRPCStatus> = eventLoop.makePromise()
        
        func repeatedTask(_ task: RepeatedTask) {
            let image = CGWindowListCreateImage(.null, .optionIncludingWindow, windowID, [.boundsIgnoreFraming, .nominalResolution])
            defer {
                previousImage = image
            }
            // TODO: if it has been similar for a certain period of time fail out!
            guard previousImage == nil || image?.isSimilar(to: previousImage!) == false else {
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
                    
                    promise.fail(GRPCStatus.processingError)
                }
            }
        }
        
        eventLoop.scheduleRepeatedTask(initialDelay: .milliseconds(0),
                                       delay: .milliseconds(25),
                                       repeatedTask)

        return promise.futureResult
    }
    
}

// MARK:- Touch

public extension WindowProvider {
    
    func touch(
        request: MacDB_WindowPoint,
        context: StatusOnlyCallContext
    ) -> EventLoopFuture<MacDB_WindowTouch> {
        return context.eventLoop.makeSucceededFuture(.init())
    }
    
}
