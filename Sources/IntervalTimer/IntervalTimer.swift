// Copyright © 2024 Ben Morrison. All rights reserved.

import Foundation
import Combine

/// An `IntervalTimer` timer is a special class that allows you to create a timer that fires at specific time intervals
/// that you'd expect them to not be the same each fire.
/// Example Times: Fire in 5 seconds, 3 seconds, 1 second, and 0.3 seconds.
public final class IntervalTimer {
    /// Allows timer logging to be enabled when true.
    public static var loggingEnabled: Bool = false
    private var worker: Worker
    /// An array of TimeIntervals that were created at initialisation that the `IntervalTimer` will use for its iterations.
    public var intervals: Intervals { worker.intervals }
    /// The max number of iterations the timer should iterate.
    /// If it is nil, the timer will iterate using the last iteration until stopped.
    public var maxIterations: Int? { worker.maxIterations }
    /// A flag representing if the timer is currently running or not.
    @Published var stopped: Bool = true
    private var cancellables: [Cancellable] = []
    
    /// Creates an `IntervalTimer` that uses the specified parameters.
    /// - Parameters:
    ///   - intervals: The intervals that should be used for this timer.
    ///   - maxIterations: The max iterations to perform. When nil the timer goes indefinitely. Note: If max is beyond the
    ///                    the number of iterations, the last interval is used for timing.
    ///   - action: The action to perform at each iterations.
    public init(intervals: Intervals, maxIterations: Int?, action: @escaping @Sendable () -> Void) {
        worker = .init(intervals: intervals, maxIterations: maxIterations, action: action)
    }
    
    /// Starts the timer immediately, and the action will fire after the first interval passes.
    /// - Parameter priority: The priority the actions should take place on.
    public func start(priority: TaskPriority? = nil) {
        Task {
            cancellables.append(await worker.stopped.sink {
                self.stopped = $0
            })
            await worker.start(priority: priority)
        }
    }
    
    /// Stops the timer and _resets_ it back to first iteration position to run again.
    public func stop() {
        Task(priority: .high) {
            await worker.stop()
        }
    }
}

extension IntervalTimer {
    /// Creates an `IntervalTimer` with the defined parameters and immediately starts the timer.
    /// - Parameters:
    ///   - priority: The priority the actions should take place on.
    ///   - intervals: The intervals that should be used for this timer.
    ///   - maxIterations: The max iterations to perform. When nil the timer goes indefinitely. Note: If max is beyond the
    ///                    the number of iterations, the last interval is used for timing.
    ///   - action: The action to perform at each iterations.
    /// - Returns: A running `IntervalTimer`
    public static func scheduleTimer(
        priority: TaskPriority? = nil,
        intervals: Intervals,
        maxIterations: Int?,
        action: @escaping @Sendable () -> Void
    ) -> Self {
        let timer = self.init(intervals: intervals, maxIterations: maxIterations, action: action)
        timer.start()
        return timer
    }
}
