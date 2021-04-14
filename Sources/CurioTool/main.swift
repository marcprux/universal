//
//  main.swift
//  CurioTool
//
//  Created by Marc Prud'hommeaux on 9/8/15.
//  Copyright © 2010-2021 io.glimpse. All rights reserved.
//

// usage: cat /opt/src/glimpse/glimpse/Glean/Glean/glean-schema.json | /Users/mprudhom/Library/Developer/Xcode/DerivedData/Glimpse-akzmpxhsvpypdxbqqszohlbdbwzm/Build/Products/Debug/CurioTool | xcrun -sdk macosx swiftc -parse -

// The pure swift process handling is woefully simplistic; there is no stderr or process exiting, so
// for the time being we throw errors when there is a problem with the arguments
// We could alternatively import Darwin, but we'd like to keep this 100% pure Swift

//import Curio // NOTE: we should not import any Frameworks here, but instead rely on the target's source file list

try Curio.runWithArguments(CommandLine.arguments)
