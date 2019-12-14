import GRPC
import Model
import NIO
import Providers

let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
defer {
  try! group.syncShutdownGracefully()
}

let configuration = Server.Configuration(
  target: .hostAndPort("0.0.0.0", 9090),
  eventLoopGroup: group,
  serviceProviders: [WindowProvider()]
)

let server = Server.start(configuration: configuration)
server.map {
  $0.channel.localAddress
}.whenSuccess { address in
  print("server started on port \(address!.port!)")
}

_ = try server.flatMap {
  $0.onClose
}.wait()
