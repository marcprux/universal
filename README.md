Bric-à-brac
=======

[![Swift 4.2](https://img.shields.io/badge/Swift-4.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms OS X | iOS](https://img.shields.io/badge/Platforms-OS%20X%20%7C%20iOS%20%7C%20Linux-lightgray.svg?style=flat)](https://developer.apple.com/swift/)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-Compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/glimpseio/BricBrac.svg?branch=master)](https://travis-ci.org/glimpseio/BricBrac)
[![Join the chat at https://gitter.im/glimpseio/BricBrac](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/glimpseio/BricBrac?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![codecov.io](http://codecov.io/github/glimpseio/BricBrac/coverage.svg?branch=master)](http://codecov.io/github/glimpseio/BricBrac?branch=master)

**Bric-à-brac** is a lightweight, clean and efficient JSON toolkit for **Swift 4.2**.

## Features

- [x] Integrates with Swift 4's built-in Codable features
- [x] Generate Swift value types from JSON Schemas
- [x] A simple immutable model of the JSON language elements
- [x] An efficient streaming JSON parser
- [x] Type-based (de)serialization of custom objects (no reflection, no intrusion)
- [x] No dependencies on `Foundation` or any other external framework
- [x] 100% Pure Swift

### BricBrac

BricBrac is a support library that contains convenience feautres for serializing instances to an intermediate JSON **Bric** type. Swift's **Codable** feature supports serializing and de-serializing instances to JSON Data, **BricBrac** allows these types to be represented in an intermeidate form so they can be examined and manipulated.

Any instance that supports **Encodable** automatically has a **bricEncoded()** function added to it which will return a **Bric** instance. One use for this is unit testing, where you can check to see if the encoded form of an instance is as you expect it:
    
````swift
  XCTAssertEqual(["encoding":["color":["value":"blue"]]], try encoding.bricEncoded())
````

### Curio

Curio is a tool that generates swift value types (structs and enums) from a valid JSON Schema (Draft 5) file.

 * Add a Build Rule
 * Set the name to "JSON Schema Compiler"
 * From the "Process" menu, select "Source files with names matching:"
 * Next to the menu, enter "*.jsonschema"
 * From the "Using" menu, select "Custom script"
 * In the text area below, paste the following script:
````sh
cat ${INPUT_FILE_PATH} | ${BUILT_PRODUCTS_DIR}/curio -name ${INPUT_FILE_BASE} > ${SRCDIR}/${INPUT_FILE_BASE}.swift
````

 * Under the "Output Files" section, click the plus sign to add a new output file, and then enter: `$(BUILT_PRODUCTS_DIR)/$(INPUT_FILE_BASE).swift`

Now any file with the suffix ".jsonschema" will automatiucally have a Swift file generated in the ${SRCDIR}. After the first time this is run you will need to manually add the subsequently generated files to your project's source files, but any changes to the JSON Schema files will then be reflected in the generated sources as part of the build process.

## Installation

### [Carthage](https://github.com/Carthage/Carthage#installing-carthage)

Add the following line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

````
github "glimpseio/BricBrac"
````

Then do `carthage update`. After that, add the framework to your project.

### Manually

`BricBrac` is a single cross-platform iOS & Mac Framework. To set it up in your project, simply add it as a github submodule, drag the `BricBrac.xcodeproj` into your own project file, add `BricBrac.framework` to your target's dependencies, and `import BricBrac` from any Swift file that should use it.

**Set up Git submodule**

1. Open a Terminal window
1. Change to your projects directory `cd /path/to/MyProject`
1. If this is a new project, initialize Git: `git init`
1. Add the submodule: `git submodule add https://github.com/glimpseio/BricBrac.git BricBrac`.

**Set up Xcode**

1. Find the `BricBrac.xcodeproj` file inside of the cloned BricBrac project directory.
1. Drag & Drop it into the `Project Navigator` (⌘+1).
1. Select your project in the `Project Navigator` (⌘+1).
1. Select your target.
1. Select the tab `Build Phases`.
1. Expand `Link Binary With Libraries`.
1. Add `BricBrac.framework`
1. Add `import BricBrac` to the top of your Swift source files.

