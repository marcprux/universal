//
//  main.swift
//  CurioTool
//
//  Created by Marc Prud'hommeaux on 9/8/15.
//  Copyright © 2010-2021 io.glimpse. All rights reserved.
//

// usage: cat /opt/src/glimpse/glimpse/Glean/Glean/glean-schema.json | /Users/mprudhom/Library/Developer/Xcode/DerivedData/Glimpse-akzmpxhsvpypdxbqqszohlbdbwzm/Build/Products/Debug/CurioTool | xcrun -sdk macosx swiftc -parse -

import Curio

try Curio.runWithArguments(CommandLine.arguments)
