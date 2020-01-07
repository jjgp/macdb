public class Mock {
    
    public struct Arguments {
        let args: [Any?]
        
        init(_ args: Any?...) {
            self.args = args
        }
    }
    
    public struct Call {
        
        public let callee: String
        public let args: Arguments
        
        init(callee: String, args: Any?...) {
            self.callee = callee
            self.args = Arguments(args)
        }
        
    }
    
    public struct Stub {
        
        public typealias Handler = (Arguments) -> Any?
        let onCall: Handler
        
    }
    
    var calls = [Call]()
    var stubs = [String: Stub]()
    
    public init() {}
    
}

