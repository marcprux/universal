//
//  main.swift
//  CurioTool
//
//  Created by Marc Prud'hommeaux on 9/8/15.
//  Copyright © 2015 io.glimpse. All rights reserved.
//

// usage: cat /opt/src/glimpse/glimpse/Glance/Glance/glance-schema.json | /Users/mprudhom/Library/Developer/Xcode/DerivedData/Glimpse-akzmpxhsvpypdxbqqszohlbdbwzm/Build/Products/Debug/CurioTool | xcrun -sdk macosx swiftc -parse -

// The pure swift process handling is woefully simplistic; there is no stderr or process exiting, so
// for the time being we throw errors when there is a problem with the arguments
// We could alternatively import Darwin, but we'd like to keep this 100% pure Swift
try Curio.runWithArguments(Process.arguments)