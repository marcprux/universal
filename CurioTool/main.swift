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


var args = Process.arguments.generate()
let cmdname = args.next() ?? "curio"

let usage = [
    "Usage: cat <schema.json> | \(cmdname) <arguments> | xcrun -sdk macosx swiftc -parse -",
    "Parameters:",
    "  -name: The name of the top-level type to be generated",
    "  -defs: The internal path to definitions (default: #/definitions/)",
    "  -maxdirect: The maximum number of properties before making them Indirect",
    "  -rename: A renaming mapping",
    "  -import: Additional imports at the top of the generated source",
    "  -access: Default access (public, private, internal, or default)",
    "  -typetype: Generated type (struct or class)"
].joinWithSeparator("\n")


struct UsageError : ErrorType {
    let msg: String

    init(_ msg: String) {
        self.msg = msg + "\n" + usage
    }
}

var modelName: String? = nil
var defsPath: String? = "#/definitions/"
var accessType: String? = "public"
var renames: [String : String] = [:]
var imports: [String] = ["BricBrac"]
var maxdirect: Int?
var typeType: String?

var done = false

while let arg = args.next() {
    switch arg {
    case "-help":
        print(usage)
        done = true
    case "-name":
        modelName = args.next()
    case "-defs":
        defsPath = args.next()
    case "-maxdirect":
        maxdirect = Int(args.next() ?? "")
    case "-rename":
        renames[args.next() ?? ""] = args.next()
    case "-import":
        imports.append(args.next() ?? "")
    case "-access":
        accessType = args.next()
    case "-typetype":
        typeType = String(args.next() ?? "")
    default:
        throw UsageError("Unrecognized argument: \(arg)")
    }
}

if !done {
    guard let modelName = modelName else {
        throw UsageError("Missing model name")
    }

    guard let defsPath = defsPath else {
        throw UsageError("Missing definitions path")
    }

    guard let accessType = accessType else {
        throw UsageError("Missing access type")
    }

    var access: CodeAccess
    switch accessType {
    case "public": access = .Public
    case "private": access = .Private
    case "internal": access = .Internal
    case "default": access = .Default
    default: throw UsageError("Unknown access type: \(accessType) (must be 'public', 'private', 'internal', or 'default')")
    }

    var curio = Curio()
    if let maxdirect = maxdirect {
        curio.indirectCountThreshold = maxdirect
    }

    if let typeType = typeType {
        switch typeType {
        case "struct": curio.generateValueTypes = true
        case "class": curio.generateValueTypes = false
        default: throw UsageError("Unknown type type: \(typeType) (must be 'struct' or 'class')")
        }
    }

    curio.accessor = { _ in access }

    curio.renamer = { (parents, id) in
        let key = (parents + [id]).joinWithSeparator(".")
        return renames[id] ?? renames[key]
    }


    //debugPrint("Reading schema file from standard input")
    var src: String = ""
    while let line = readLine(stripNewline: false) {
        src += line
    }

    let module = try curio.parseSchema(src, rootName: modelName)
    module.imports = imports

    
    let emitter = CodeEmitter(stream: "")
    module.emit(emitter)

    let code = emitter.stream
    print(code)
}