Universal
=========

[![Build Status](https://github.com/marcprux/universal/workflows/Universal%20CI/badge.svg?branch=main)](https://github.com/marcprux/universal/actions)
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Platform](https://img.shields.io/badge/Platforms-macOS%20|%20Linux%20|%20Windows%20|%20iOS%20|%20tvOS%20|%20watchOS-lightgray.svg)](https://github.com/marcprux/universal/actions)
[![](https://tokei.rs/b1/github/marcprux/universal)](https://github.com/marcprux/universal)

**Universal**: A tiny zero-dependency cross-platform Swift parser and decoder for JSON, XML, YAML, and property lists.

## Usage:

Add the following dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/marcprux/universal.git", from: "5.0.5")
```

The package provides the modules `Either`, `JSON`, `XML`, `YAML`, `PLIST`,
or `Universal`, which is an umbrella module that re-exports all the other modules.


## Example:

```swift
import Universal

func testUniversalExample() throws {
    // JSON Parsing
    let json: JSON = try JSON.parse(Data("""
        {"parent": {"child": 1}}
        """.utf8))

    assert(json["parent"]?["child"] == 1)
    assert(json["parent"]?["child"] == JSON.number(1.0)) // JSON's only number is Double


    // YAML Parsing
    let yaml: YAML = try YAML.parse(Data("""
        parent:
          child: 1
        """.utf8))

    assert(yaml["parent"]?["child"] == 1)
    assert(yaml["parent"]?["child"] == YAML.integer(1)) // YAML can parse integers
    assert(yaml["parent"]?["child"] != 1.0) // not the same as a double

    let yamlJSON: JSON = try yaml.json() // convert YAML to JSON struct
    assert(yamlJSON == json)


    // XML Parsing
    let xml: XML = try XML.parse(Data("""
        <parent><child>1</child></parent>
        """.utf8))

    let xmlJSON: JSON = try xml.json() // convert XML to JSON struct

    assert(xml["parent"]?["child"] == XML.string("1")) // XML parses everything as strings

    // fixup the XML by changing the JSON to match
    assert(json["parent"]?["child"] == 1)
    var jsonEdit = json
    jsonEdit["parent"]?["child"] = JSON.string("1") // update the JSON to match
    assert(jsonEdit["parent"]?["child"] == "1") // now the JSON matches

    assert(xmlJSON == jsonEdit)
}
```

## Coding

Universal provides the ability to decode from (but not encode to) YAML and XML
through their ability to convert to a `JSON` struct:


```swift
import Universal

struct Coded : Decodable, Equatable {
    let person: Person

    struct Person : Decodable, Equatable {
        let firstName: String
        let lastName: String
        let astrologicalSign: String
    }
}

let decodedFromJSON = try Coded(json: JSON.parse(Data("""
    {
      "person": {
        "firstName": "Marc",
        "lastName": "Prud'hommeaux",
        "astrologicalSign": "Sagittarius"
      }
    }
    """.utf8)))

let decodedFromYAML = try Coded(json: YAML.parse(Data("""
    # A YAML version of a Person
    person:
      firstName: Marc
      lastName: Prud'hommeaux
      astrologicalSign: Sagittarius # what's your sign?
    """.utf8)).json())
assert(decodedFromJSON == decodedFromYAML)

let decodedFromXML = try Coded(json: XML.parse(Data("""
    <!-- An XML version of a Person -->
    <person>
      <firstName>Marc</firstName>
      <!-- escaping and stuff -->
      <lastName>Prud&apos;hommeaux</lastName>
      <astrologicalSign>Sagittarius</astrologicalSign>
    </person>
    """.utf8)).json())
assert(decodedFromYAML == decodedFromXML)

let decodedFromPLISTXML = try Coded(json: PLIST.parse(Data("""
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>person</key>
        <dict>
            <key>firstName</key>
            <string>Marc</string>
            <key>lastName</key>
            <string>Prud&apos;hommeaux</string>
            <key>astrologicalSign</key>
            <string>Sagittarius</string>
        </dict>
    </dict>
    </plist>
    """.utf8)).json())
assert(decodedFromXML == decodedFromPLISTXML)

let decodedFromPLISTOpenStep = try Coded(json: PLIST.parse(Data("""
    {
        person = {
            firstName = Marc;
            lastName = "Prud'hommeaux";
            astrologicalSign = Sagittarius;
        };
    }
    """.utf8)).json())
assert(decodedFromPLISTOpenStep == decodedFromPLISTXML)
```

## API

Browse the [API Documentation].


## License

LGPL 3.0
See [LICENSE.LGPL](LICENSE.LGPL) for details.


[Swift Package Manager]: https://swift.org/package-manager
[API Documentation]: https://marcprux.github.io/universal/documentation/universal/
