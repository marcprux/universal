Universal
=========

[![Build Status](https://github.com/marcprux/universal/workflows/Universal%20CI/badge.svg?branch=main)](https://github.com/marcprux/universal/actions)
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Platform](https://img.shields.io/badge/Platforms-macOS%20|%20Linux%20|%20Windows%20|%20iOS%20|%20tvOS%20|%20watchOS-lightgray.svg)](https://github.com/marcprux/universal/actions)
[![](https://tokei.rs/b1/github/marcprux/universal)](https://github.com/marcprux/universal)

**Universal**: A tiny zero-dependency cross-platform Swift parser for JSON, XML, and YAML, as well as an in-memory `JSON` data structure (and an `Either` type).

## Example:

```swift
import Universal

func demoUniversal() throws {
    var json: JSON = try JSON.parse("""
        {"parent": {"child": 1}}
        """.data(using: .utf8)!)

    assert(json["parent"]?["child"] == 1)


    let yaml: YAML = try YAML.parse("""
        parent:
          child: 1
        """.data(using: .utf8)!)
    assert(yaml["parent"]?["child"] == 1)

    let yamlJSON: JSON = try yaml.json() // convert YAML to JSON struct
    assert(yamlJSON == json)



    let xml: XML = try XML.parse("""
        <parent><child>1</child></parent>
        """.data(using: .utf8)!)

    let xmlJSON: JSON = try xml.json() // convert XML to JSON struct

    // XML parses everything as a String
    assert(json["parent"]?["child"] == 1)
    json["parent"]?["child"] = "1"
    assert(json["parent"]?["child"] == "1") // now the JSON matches

    assert(xmlJSON == json)
}
```

## API

Browse the [API Documentation].


## License

LGPL 3.0
See [LICENSE.LGPL](LICENSE.LGPL) for details.


[Swift Package Manager]: https://swift.org/package-manager
[API Documentation]: https://marcprux.github.io/universal/documentation/universal/
