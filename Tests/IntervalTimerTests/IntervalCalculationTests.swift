// Copyright © 2024 Ben Morrison. All rights reserved.

import XCTest
@testable import IntervalTimer

final class IntervalCalculationTests: XCTestCase {
    func testStandardCalculation() throws {
        let calculator = StandardIntervalCalculator(minimumInterval: .seconds(1), maximumInterval: .seconds(10), minNumberIntervals: 1, maxNumberIntervals: 10)
        let intervals = calculator.intervals()
        print(intervals)
        let expected: Intervals.TimeIntervals = [
            .seconds(10),
            .seconds(7.742636826811271),
            .seconds(5.994842503189411),
            .seconds(4.641588833612779),
            .seconds(3.5938136638046276),
            .seconds(2.7825594022071245),
            .seconds(2.154434690031884),
            .seconds(1.6681005372000586),
            .seconds(1.291549665014884),
            .seconds(1.0)
        ]
        
        XCTAssertEqualWithMargin(intervals, expected, 0.01, "Intervals didn't match within margin.")
    }
    
    func testStandardCalculation_WrongSpanOrder() throws {
        let calculator = StandardIntervalCalculator(minimumInterval: .seconds(10), maximumInterval: .seconds(1), minNumberIntervals: 1, maxNumberIntervals: 10)
        let intervals = calculator.intervals()
        XCTAssertEqual(intervals, [], "Array should be empty when min is higher than max.")
    }
    
    func testStandardCalculation_ZeroCount() throws {
        let calculator = StandardIntervalCalculator(minimumInterval: .seconds(1), maximumInterval: .seconds(10), minNumberIntervals: 0, maxNumberIntervals: 0)
        let intervals = calculator.intervals()
        XCTAssertEqual(intervals, [], "Array should be empty when count is zero.")
    }
}
