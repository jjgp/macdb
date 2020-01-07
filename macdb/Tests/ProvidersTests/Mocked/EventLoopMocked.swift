import Foundation
import Mocked
import NIO

final class EventLoopMocked: EventLoop, Mocked {
    
    var inEventLoop: Bool = true
    var mock = Mock()
    
    func execute(_ task: @escaping () -> Void) {
        mocked(args: task)
    }
    
    func scheduleTask<T>(deadline: NIODeadline, _ task: @escaping () throws -> T) -> Scheduled<T> {
        return mocked(args: deadline, task)
    }
    
    func scheduleTask<T>(in: TimeAmount, _ task: @escaping () throws -> T) -> Scheduled<T> {
        return mocked(args: `in`, task)
    }
    
    func shutdownGracefully(queue: DispatchQueue, _ callback: @escaping (Error?) -> Void) {
        mocked(args: queue, callback)
    }
    
}
