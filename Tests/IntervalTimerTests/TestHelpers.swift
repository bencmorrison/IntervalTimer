// Copyright © 2024 Ben Morrison. All rights reserved.

import XCTest
import IntervalTimer

func XCTAssertEqualWithMargin<T: Collection>(
    _ expression1: @autoclosure () throws -> T,
    _ expression2: @autoclosure () throws -> T,
    _ margin: @autoclosure () -> Double,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) where T.Element == Intervals.Interval {
    XCTAssertEqual(try expression1().count, try expression2().count, message(), file: file, line: line)
    for (lhs, rhs) in zip(try! expression1(), try! expression2()) {
        let lhsValue = Int64(duration: lhs)
        let rhsValue = Int64(duration: rhs)
        let percentageDifference = (Double(abs(lhsValue - rhsValue)) / average(lhsValue, rhsValue))
        XCTAssertTrue(
            percentageDifference <= min(max(0.0, margin()), 1.0),
            "\(message()) numbers: [\(lhs), \(rhs)]",
            file: file,
            line: line
        )
    }
}

@inlinable
func average<T: BinaryInteger>(_ numbers: T...) -> Double {
    Double(numbers.reduce(0, +)) / Double(numbers.count)
}

extension Int64 {
    init(duration: Duration) {
        self.init(duration.components.seconds + duration.components.attoseconds)
    }
}
