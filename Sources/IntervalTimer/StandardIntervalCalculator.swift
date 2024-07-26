// Copyright © 2024 Ben Morrison. All rights reserved.

import Foundation

/// A provided 'standard' calculator for intervals, it is just a random equation that I made up.
/// The idea is for it to start of 'slow' feeling on firing, and then it gets faster and faster.
///
/// This calculator will always have a minimum of 1 iteration unless minNumberIntervals has been explicitly set to zero.
public struct StandardIntervalCalculator: IntervalCalculator {
    public let minimumInterval: Intervals.Interval
    public let maximumInterval: Intervals.Interval
    public let minNumberIntervals: Int?
    public let maxNumberIntervals: Int?
    
    public init(minimumInterval: Intervals.Interval, maximumInterval: Intervals.Interval, minNumberIntervals: Int?, maxNumberIntervals: Int?) {
        self.minimumInterval = minimumInterval
        self.maximumInterval = maximumInterval
        self.minNumberIntervals = minNumberIntervals
        self.maxNumberIntervals = maxNumberIntervals
    }
    
    /// Runs the following calculations for the time intervals.
    /// If maximumInterval is larger than minimumInterval, an empty array is returned.
    /// From 0 to maxNumberIntervals - 1, where index starts at zero do
    /// T = index / (maxNumberIntervals - 1)
    /// Interval = maximumInterval * pow(minimumInterval / maximumInterval, T)
    /// if the interval is below minimumInterval do nothing, else ad dit to the list of intervals.
    /// - Returns: The time intervals for this calculator.
    public func intervals() -> Intervals.TimeIntervals {
        guard minimumInterval < maximumInterval else { return [] }
        
        var intervals: Intervals.TimeIntervals = []
        
        let minCount = minNumberIntervals ?? 1
        let maxCount = maxNumberIntervals ?? .max
        
        for i in (0..<maxCount) {
            let t = Double(i) / Double(maxCount - 1)
            let interval = maximumInterval * pow(minimumInterval / maximumInterval, t)
            guard interval >= minimumInterval else { break }
            intervals.append(interval)
        }
        
        guard intervals.count >= minCount else { return [minimumInterval] }
        return intervals
    }
}
