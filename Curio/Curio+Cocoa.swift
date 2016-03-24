//
//  Curio+Cocoa.swift
//  Bric-à-brac
//
//  Created by Marc Prud'hommeaux on 7/20/15.
//  Copyright © 2015 io.glimpse. All rights reserved.
//

import Foundation

public extension Curio {
    public func emit(module: CodeModule, name: String, dir: String) throws {
        let locpath = (dir as NSString).stringByAppendingPathComponent(name)
        module.imports.append("BricBrac")

        let emitter = CodeEmitter(stream: "")
        module.emit(emitter)

        let code = emitter.stream
        let tmppath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(name)
        try code.writeToFile(tmppath, atomically: true, encoding: NSUTF8StringEncoding)

        let loccode: String
        do {
            loccode = try NSString(contentsOfFile: locpath, encoding: NSUTF8StringEncoding) as String
        } catch {
            loccode = ""
        }

        if loccode == code {
            return // contents are unchanged from local version; skip compiling
        }

        let bundle = NSBundle(forClass: FoundationBricolage.self).executablePath! // we are just using FoundationBricolage because it is the only class in the BricBrac framework
        let frameworkDir = ((bundle as NSString).stringByDeletingLastPathComponent as NSString).stringByDeletingLastPathComponent

        let args = [
            "/usr/bin/xcrun",
//            "-sdk", "macosx10.11",
            "swiftc",
            "-target", "x86_64-apple-macosx10.11",
            "-sdk", "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk",
            "-F", frameworkDir,
            "-o", (tmppath as NSString).stringByDeletingPathExtension,
            tmppath,
        ]

        print(args.joinWithSeparator(" "))

        let task = NSTask.launchedTaskWithLaunchPath(args[0], arguments: Array(args.dropFirst()))
        task.waitUntilExit()
        let status = task.terminationStatus
        if status != 0 {
            throw CodegenErrors.CompileError("Could not compile \(tmppath)")
        }

        if status == 0 {
            if loccode != code { // if the code has changed, then write it to the test
                if NSFileManager.defaultManager().fileExistsAtPath(locpath) {
                    try! NSFileManager.defaultManager().trashItemAtURL(NSURL(fileURLWithPath: locpath), resultingItemURL: nil)
                }
                try code.writeToFile(locpath, atomically: true, encoding: NSUTF8StringEncoding)
            }
        }
    }
}