import Foundation
import GRPC
import MacDBModel
import NIO

guard case .some(let port) = CommandLine.arguments.dropFirst(1).first.flatMap(Int.init) else {
  print("Usage: \(CommandLine.arguments[0]) PORT")
  exit(1)
}

let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
defer {
  try? group.syncShutdownGracefully()
}

let configuration = ClientConnection.Configuration(
  target: .hostAndPort("localhost", port),
  eventLoopGroup: group
)

let connection = ClientConnection(configuration: configuration)

let client = MacDB_WindowServiceClient(connection: connection)
defer {
    try? client.connection.close().wait()
}

let call = client.capture { windowCapture in
    print(windowCapture.image)
}

call.status.whenSuccess { status in
    print(status)
}

call.status.whenFailure { error in
    print(error)
}

let windoInfo: MacDB_WindowInfo = .with {
    $0.name = "iPhone 11 Pro Max — 13.2.2"
}
_ = call.sendMessage(windoInfo)

DispatchQueue.main.asyncAfter(wallDeadline: .now() + 5) {
    call.sendEnd()
}

RunLoop.main.run()
