//
//  Timer.swift
//  basketballDemo
//
//  Created by Brett Berry on 7/25/16.
//  Copyright © 2016 Brett Berry. All rights reserved.
//

import Foundation

class Timer {

    var timer: NSTimer!
    var startTime: NSDate!
    var seconds: NSTimeInterval
    var delegate: TimerDelegate
    
    init(seconds: NSTimeInterval, delegate: TimerDelegate) {
        self.delegate = delegate
        self.seconds = seconds
        timer = NSTimer(timeInterval: 0.1, target: self, selector: #selector(handleTimerUpdate), userInfo: nil, repeats: true)
    }
    
    @objc func handleTimerUpdate() {
        let difference = abs(startTime.timeIntervalSinceNow)
        if difference > seconds {
            timer.invalidate()
            delegate.timerDidComplete()
        }
        else {
            delegate.timerDidUpdate(withCurrentTime: seconds - difference)
        }
    }

    func start() {
        startTime = NSDate()
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }
}

protocol TimerDelegate {
    func timerDidUpdate(withCurrentTime time: NSTimeInterval)
    func timerDidComplete()
}
