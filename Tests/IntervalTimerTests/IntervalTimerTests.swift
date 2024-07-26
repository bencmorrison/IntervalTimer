// Copyright © 2024 Ben Morrison. All rights reserved.

import XCTest
import Combine
@testable import IntervalTimer

final class IntervalTimerTests: XCTestCase {
    var timers: [IntervalTimer?] = []
    var cancellables: [Cancellable] = []
    
    override func tearDown() async throws {
        timers.forEach { $0?.stop() }
        cancellables.forEach { $0.cancel() }
    }
    
    func testCallsOnlyFiveTimes() throws {
        let maxIterations: Int = 5
        lazy var intervals: Intervals = .testIntervals(maxNumberIntervals: maxIterations)
        
        nonisolated(unsafe) var fireCount: Int = 0
        let sut = IntervalTimer(intervals: intervals, maxIterations: maxIterations) {
            fireCount += 1
        }
        timers.append(sut)
        
        let expectation = self.expectation(description: "Timer will only fire 5 times")
        cancellables.append(sut.$stopped.sink {
            guard $0 && fireCount == maxIterations else { return }
            expectation.fulfill()
        })
        
        sut.start()
        
        waitForExpectations(timeout: intervals.estimatedTotalTime()) { error in
            XCTAssertEqual(fireCount, 5, "Timer did not run 5 times.")
            XCTAssertTrue(sut.stopped, "Timer should be stopped but is not stopped.")
            XCTAssertNil(error, "Timer ran out of time.")
        }
    }
    
    func testEndTimerEarly() throws {
        let maxIterations: Int = 5
        let stopAtIteration: Int = 3
        lazy var intervals: Intervals = .testIntervals(maxNumberIntervals: maxIterations)
        
        nonisolated(unsafe) let fireCount: CurrentValueSubject<Int, Never> = .init(0)
        let sut = IntervalTimer(intervals: intervals, maxIterations: maxIterations) {
            fireCount.send(fireCount.value + 1)
        }
        
        timers.append(sut)
        
        let expectation = self.expectation(description: "Timer will only fire \(stopAtIteration) times")
        cancellables.append(sut.$stopped.sink {
            guard $0 && fireCount.value == stopAtIteration else { return }
            expectation.fulfill()
        })
        
        cancellables.append(fireCount.sink {
            if $0 >= stopAtIteration { sut.stop() }
        })
        
        sut.start()
        
        waitForExpectations(timeout: intervals.estimatedTotalTime()) { error in
            XCTAssertEqual(fireCount.value, stopAtIteration, "Timer did not run only \(stopAtIteration) times.")
            XCTAssertTrue(sut.stopped, "Timer should be stopped but is not stopped.")
            XCTAssertNil(error, "Timer ran out of time.")
        }
    }
    
    func timer() {
        let intervalCalculator = StandardIntervalCalculator(
            minimumInterval: .seconds(1.0),
            maximumInterval: .seconds(10.0),
            minNumberIntervals: 1,
            maxNumberIntervals: 10
        )
        let timerIntervals = Intervals(timeIntervals: intervalCalculator.intervals())
        let timer = IntervalTimer(intervals: timerIntervals, maxIterations: 10) {
            print("Timer has fired!")
        }
    }
}

private extension Intervals {
    static func testIntervals(minNumberIntervals: Int = 1, maxNumberIntervals: Int) -> Intervals {
        .init(
            using: StandardIntervalCalculator(
                minimumInterval: .milliseconds(500),
                maximumInterval: .seconds(2),
                minNumberIntervals: minNumberIntervals,
                maxNumberIntervals: maxNumberIntervals
            )
        )
    }
    
    func estimatedTotalTime(fudge: Duration = .milliseconds(200)) -> TimeInterval {
        let duration = fudge + timeIntervals.reduce(Duration.zero, +)
        return Double(duration.components.seconds) + Double(duration.components.attoseconds) * 1e-18
    }
}
