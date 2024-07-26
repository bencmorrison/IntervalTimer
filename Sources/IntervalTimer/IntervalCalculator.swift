// Copyright © 2024 Ben Morrison. All rights reserved.

import Foundation

/// Conformance to this protocol allows you to easily create custom
public protocol IntervalCalculator {
    /// The minimum length any interval should be.
    var minimumInterval: Intervals.Interval { get }
    /// The maximum length any interval should be.
    var maximumInterval: Intervals.Interval { get }
    /// The minimum number of intervals that should be created.
    /// If not set, it is up to you to decide what that means.
    var minNumberIntervals: Int? { get }
    /// The maximum number of intervals that should be created.
    /// If not set, it is up to you to decide what that means.
    var maxNumberIntervals: Int? { get }
    
    /// Create a new instance of your `IntervalCalculator`.
    /// - Parameters:
    ///   - minimumInterval: The minimum length any interval should be.
    ///   - maximumInterval: The maximum length any interval should be.
    ///   - minNumberIntervals: The minimum number of intervals that should be created. If nil, you decide.
    ///   - maxNumberIntervals: The maximum number of intervals that should be created. If nil, you decide.
    init(minimumInterval: Intervals.Interval, maximumInterval: Intervals.Interval, minNumberIntervals: Int?, maxNumberIntervals: Int?)
    
    /// Called when the intervals are required for the timer.
    /// Returns: An array of `Intervals.TimeIntervals`
    func intervals() -> Intervals.TimeIntervals
}


