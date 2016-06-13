//
//  NSTimer+AutoRelease.swift
//  XBCycleView
//
//  Created by xiabob on 16/6/13.
//  Copyright © 2016年 xiabob. All rights reserved.
//

import Foundation

public typealias executeTimerClosure = ()->()

//将closure封装成一个对象
class closureObject<T> {
    let closure: T?
    init (closure: T?) {
        self.closure = closure
    }
}

public extension NSTimer {
    public class func xb_scheduledTimerWithTimeInterval(timeInterval: NSTimeInterval,
                                                        isRepeat: Bool,
                                                        closure: executeTimerClosure?) -> NSTimer {
        let block = closureObject<executeTimerClosure>(closure: closure)
        let timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval,
                                                           target: self,
                                                           selector: #selector(xb_executeTimerBlock),
                                                           userInfo: block,
                                                           repeats: isRepeat);
        return timer
    }
    
    public class func xb_scheduledTimerWithTimeInterval(timeInterval: NSTimeInterval,
                                                        closure: executeTimerClosure?) -> NSTimer {
        return xb_scheduledTimerWithTimeInterval(timeInterval,
                                                 isRepeat: false,
                                                 closure: closure)
    }
    
    class func xb_executeTimerBlock(timer: NSTimer) {
        if let block = timer.userInfo as? closureObject<executeTimerClosure> {
            if let closure = block.closure {
                closure()
            }
        }
    }
}