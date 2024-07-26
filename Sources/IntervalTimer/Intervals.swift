// Copyright © 2024 Ben Morrison. All rights reserved.

import Foundation

/// Defines the types and creates the time intervals that an `IntervalTimer` can use.
public struct Intervals: Sendable {
    /// Defines a single interval for the timer.
    public typealias Interval = Duration
    /// Defines a list of intervals for the timer.
    public typealias TimeIntervals = [Interval]
    /// Defines the index type for the `TimeIntervals`
    public typealias Index = TimeIntervals.Index
    /// The intervals for a timer to use.
    public let timeIntervals: TimeIntervals
    /// The number of intervals
    public var count: Int { timeIntervals.count }
    
    /// Allows you to create an `Intervals` from a current array of `TimeIntervals`
    /// - Parameter timeIntervals: The array of `TimeIntervals` you'd like to use.
    public init(timeIntervals: TimeIntervals) {
        self.timeIntervals = timeIntervals
    }
    
    /// Allows you to create an `Intervals` using an `IntervalCalculator`
    /// - Parameter calculator: The calculator thats should be used.
    public init(using calculator: any IntervalCalculator) {
        self.timeIntervals = calculator.intervals()
    }
    
    /// Reverses the `Intervals` for the timer.
    /// - Returns: A new instance of `Intervals` with reversed intervals.
    public func reversed() -> Self {
        Self.init(timeIntervals: timeIntervals.reversed())
    }
    
    subscript(index: Index) -> Interval {
        get {
            guard index < count else { return timeIntervals.last! }
            return timeIntervals[index]
        }
    }
}
