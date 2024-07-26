// Copyright © 2024 Ben Morrison. All rights reserved.

import OSLog

struct Logging {
    private let log: Logger
    
    init(type: Any.Type) {
        self.log = Logger(subsystem: "IntervalTimer", category: String(describing: type.self))
    }
    
    @inlinable
    func shouldLog() -> Bool { IntervalTimer.loggingEnabled }
    
    @inlinable
    func debug(_ message: @escaping @autoclosure () -> String) {
        guard shouldLog() else { return }
        log.debug("\(message())")
    }
}
