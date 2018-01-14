//
//  Curio+Cocoa.swift
//  Bric-à-brac
//
//  Created by Marc Prud'hommeaux on 7/20/15.
//  Copyright © 2015 io.glimpse. All rights reserved.
//

import Foundation

public extension Curio {
    public func emit(_ module: CodeModule, name: String, dir: String) throws {
        let locpath = (dir as NSString).appendingPathComponent(name)
        module.imports.append("BricBrac")

        let emitter = CodeEmitter(stream: "")
        module.emit(emitter)

        let code = emitter.stream
        let tmppath = (NSTemporaryDirectory() as NSString).appendingPathComponent(name)
        try code.write(toFile: tmppath, atomically: true, encoding: String.Encoding.utf8)

        let loccode: String
        do {
            loccode = try NSString(contentsOfFile: locpath, encoding: String.Encoding.utf8.rawValue) as String
        } catch {
            loccode = ""
        }

        if loccode == code {
            return // contents are unchanged from local version; skip compiling
        }

        let bundle = Bundle(for: FoundationBricolage.self).executablePath! // we are just using FoundationBricolage because it is the only class in the BricBrac framework
        let frameworkDir = ((bundle as NSString).deletingLastPathComponent as NSString).deletingLastPathComponent

        let args = [
            "/usr/bin/xcrun",
            "swiftc",
            "-target", "x86_64-apple-macosx10.13",
            "-sdk", "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.13.sdk",
            "-F", frameworkDir,
            "-o", (tmppath as NSString).deletingPathExtension,
            tmppath,
        ]

        print(args.joined(separator: " "))

        let task = Process.launchedProcess(launchPath: args[0], arguments: Array(args.dropFirst()))
        task.waitUntilExit()
        let status = task.terminationStatus
        if status != 0 {
            throw CodegenErrors.compileError("Could not compile \(tmppath)")
        }

        if status == 0 {
            if loccode != code { // if the code has changed, then write it to the test
                if FileManager.default.fileExists(atPath: locpath) {
                    try! FileManager.default.trashItem(at: URL(fileURLWithPath: locpath), resultingItemURL: nil)
                }
                try code.write(toFile: locpath, atomically: true, encoding: String.Encoding.utf8)
            }
        }
    }
}
