// Copyright © 2024 Ben Morrison. All rights reserved.

import Combine
import OSLog

/// This does the work for the `IntervalTimer`
/// It is responsible for managing the state and when to fire the action.
actor Worker {
    /// The intervals that this worker will use.
    nonisolated let intervals: Intervals
    /// The max number of iterations that should be run, if nil, it goes infinitely.
    nonisolated let maxIterations: Int?
    /// The action to be performed when the iteration is ready to go.
    let action: @Sendable () -> Void
    
    /// When the worker isn't doing work, this is true, when it is working, it is false.
    private(set) var stopped: CurrentValueSubject<Bool, Never> = .init(true)
    
    /// The current iteration we are on.
    private var currentIteration: Intervals.Index = .zero
    /// Defines the Task type we are using in the worker.
    private typealias WorkerTask = Task<(), any Error>
    /// The current Task that is in flight.
    private var currentWorker: WorkerTask?
    /// If the worker should keep going, this will be true.
    /// When false, the worker should stop.
    private var shouldContinueIterating: Bool {
        guard let maxIterations else { return true }
        return currentIteration < maxIterations
    }
    
    private let log: Logging
    
    /// Creates a worker for the `IntervalTimer`
    /// - Parameters:
    ///   - intervals: The intervals that should be used.
    ///   - maxIterations: The max number of iterations that should be run, if nil, it goes infinitely.
    ///   - action: The action to be performed for the iteration.
    init(intervals: Intervals, maxIterations: Int?, action: @escaping @Sendable () -> Void) {
        self.intervals = intervals
        self.maxIterations = maxIterations
        self.action = action
        self.log = Logging(type: Self.self)
    }
    
    /// Triggers the `Worker` to start doing the work.
    /// - Parameter priority: The priority the Tasks should take place.
    func start(priority: TaskPriority?) {
        guard stopped.value else { log.debug("Start called on a started timer."); return }
        stopped.send(false)
        performNextIteration(priority: priority)
    }
    
    /// Tells the `Worker` to stop doing work.
    func stop() {
        stopIterating()?.cancel()
    }
    
    
    /// For each iteration it will create the Task, sleep the task till it should fire the action.
    /// Then it will increment to the next iteration, if it should.
    /// - Parameter priority: The priority the Tasks should take place.
    private func performNextIteration(priority: TaskPriority?) {
        let currentInterval = intervals.timeIntervals[currentIteration]
        log.debug("Creating a task for current iteration: \(self.currentIteration)")
        currentWorker = Task(priority: priority) {
            log.debug("Sleeping Iteration for: \(currentInterval)")
            try await Task.sleep(for: currentInterval)
            action()
            currentIteration += 1
            guard shouldContinueIterating else { log.debug("Timer iterations should finish."); stopIterating(); return }
            performNextIteration(priority: priority)
        }
    }
    
    /// Makes the worker stop working.
    /// Should only be called in the `performNextIteration(priority:)` function. That way cancel isn't called on the
    /// worker and causes it to finish early.
    /// - Returns: A `WorkerTask` that can be canceled.
    @discardableResult
    private func stopIterating() -> WorkerTask? {
        log.debug("Stopping the timer and resetting the details.")
        stopped.send(true)
        currentIteration = .zero
        guard let currentWorker else { return nil }
        self.currentWorker = nil
        return currentWorker
    }
}
