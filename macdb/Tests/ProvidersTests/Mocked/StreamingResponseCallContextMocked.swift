import GRPC
import Mocked
import NIO
import SwiftProtobuf

final class StreamingResponseCallContextMocked<ResponseMessage: Message>
: StreamingResponseCallContext<ResponseMessage>, Mocked {
    
    var mock = Mock()
    
    override func sendResponse(_ message: ResponseMessage) -> EventLoopFuture<Void> {
        return mocked(args: message)
    }
    
}
