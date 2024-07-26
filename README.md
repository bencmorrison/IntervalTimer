# IntervalTimer

This small package is a cute little interval timer that allows you to easily create a time that fires at various
intervals that are not identical.

## Usage

```swift
// Creates an interval calculator which in this case is the provided calculator
// It will create up to 10 intervals. The intervals will be no longer than 10 seconds
// and they will be no shorter than 1 second.
// There will be at least 1 interval, and at most 10, but could be less.
let intervalCalculator = StandardIntervalCalculator(
    minimumInterval: .seconds(1.0),
    maximumInterval: .seconds(10.0),
    minNumberIntervals: 1,
    maxNumberIntervals: 10
)
// Creates the intervals for the timer to use.
let timerIntervals = Intervals(timeIntervals: intervalCalculator.intervals())
// Creates the timer with the intervals and a max number of iterations the timer should run.
let timer = IntervalTimer(intervals: timerIntervals, maxIterations: 10) {
    print("Timer has fired!")
}
// Starts the timer.
timer.start()
```

This will create a timer with 10 intervals between 10 and 1, they will progressively get smaller and smaller.