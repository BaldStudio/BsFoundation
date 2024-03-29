//
//  DispatchQueue.swift
//  BsSwiftX
//
//  Created by crzorz on 2021/7/16.
//  Copyright © 2021 BaldStudio. All rights reserved.
//

import Foundation

public extension SwiftX where T: DispatchQueue {
        
    // MARK: - delay
    @inlinable
    func delay(_ delay: TimeInterval, action: @escaping Block) {
        let when = DispatchTime.now() + delay
        this.asyncAfter(deadline: when) {
            action()
        }
    }
    
    // MARK: - debounce

    // https://gist.github.com/simme/b78d10f0b29325743a18c905c5512788
    //
    func debounce(interval: TimeInterval = 1.0,
                  action: @escaping Block) -> Block {
        var worker: DispatchWorkItem?
        return {
            worker?.cancel()
            worker = DispatchWorkItem { action() }
            this.asyncAfter(deadline: .now() + interval, execute: worker!)
        }
    }
    
    // MARK: - throttle
    
    func throttle(interval: TimeInterval = 1.0,
                  action: @escaping Block) -> Block {
        var worker: DispatchWorkItem?
        
        var lastFire = DispatchTime.now()
        let deadline = { lastFire + interval }
        
        return {
            guard worker == nil else { return }
            
            worker = DispatchWorkItem {
                action()
                lastFire = DispatchTime.now()
                worker = nil
            }
            
            if DispatchTime.now() > deadline() {
                this.async(execute: worker!)
                return
            }

            this.asyncAfter(deadline: .now() + interval, execute: worker!)
        }
    }
    
    @inlinable
    static func asyncMain(execute work: @escaping Block) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }

}

// MARK: - once

private extension DispatchQueue {
    static var pocket: [String] = []
}

// https://gist.github.com/nil-biribiri/67f158c8a93ff0a5d8c99ff41d8fe3bd

public extension SwiftX where T: DispatchQueue {

    /**
     Executes a block of code, associated with a auto generate unique token by file name + fuction name + line of code, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
    */
    static func once(file: String = #file,
                     function: String = #function,
                     line: Int = #line,
                     action: Block) {
        let token = "\(file):\(function):\(line)"
        once(token: token, action: action)
    }

    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    static func once(token: String, action: Block) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        guard !T.pocket.contains(token) else { return }

        T.pocket.append(token)
        action()
    }

}
