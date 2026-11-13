import Foundation
import Testing
import YAML

/// Long sequences and mappings used to cost one stack frame per element, so a
/// few hundred entries could overflow a small stack — `EXC_BAD_ACCESS` at the
/// guard page rather than a thrown error. `parseFlowSeq`, `parseBlockSeq`,
/// `parseFlowMap`, and `parseBlockMap` now iterate, so depth is bounded by
/// document nesting instead of by element count.
@Suite struct YAMLDeepSequenceTests {

    static let count = 5_000

    @Test func testLongFlowSequence() throws {
        let items = (0..<Self.count).map(String.init).joined(separator: ", ")
        let parsed = try onSmallStack { try YAML.parse(yaml: "seq: [\(items)]") }
        let seq = try #require(parsed["seq"]?.array)
        #expect(seq.count == Self.count)
        #expect(seq.first == 0)
        #expect(seq.last == .integer(Self.count - 1))
    }

    @Test func testLongBlockSequence() throws {
        let items = (0..<Self.count).map { "  - \($0)" }.joined(separator: "\n")
        let parsed = try onSmallStack { try YAML.parse(yaml: "seq:\n\(items)") }
        let seq = try #require(parsed["seq"]?.array)
        #expect(seq.count == Self.count)
        #expect(seq.last == .integer(Self.count - 1))
    }

    @Test func testLongBlockMapping() throws {
        // A `last:` sentinel closes the mapping so the final pair can be read
        // back through a literal key — the subscript takes a `Scalar`, and only
        // literals convert to one.
        let pairs = (0..<Self.count).map { "k\($0): \($0)" }.joined(separator: "\n")
        let parsed = try onSmallStack { try YAML.parse(yaml: pairs + "\nlast: 42") }
        #expect(parsed.object?.count == Self.count + 1)
        #expect(parsed["k0"] == 0)
        #expect(parsed["last"] == 42)
    }

    @Test func testLongFlowMapping() throws {
        let pairs = (0..<Self.count).map { "k\($0): \($0)" }.joined(separator: ", ")
        let parsed = try onSmallStack { try YAML.parse(yaml: "map: {\(pairs), last: 42}") }
        #expect(parsed["map"]?.object?.count == Self.count + 1)
        #expect(parsed["map"]?["k0"] == 0)
        #expect(parsed["map"]?["last"] == 42)
    }

    @Test func testDeeplyNestedFlowSequenceStillParses() throws {
        // Nesting legitimately recurses (once per level, not per element); this
        // pins that ordinary nesting keeps working after the rewrite.
        let depth = 40
        let yaml = String(repeating: "[", count: depth) + "1" + String(repeating: "]", count: depth)
        var value = try YAML.parse(yaml: yaml)
        for _ in 0..<depth { value = try #require(value[0]) }
        #expect(value == 1)
    }

    // MARK: Errors the loops still have to report

    @Test(arguments: [
        "seq: [1, 2",  // unterminated flow sequence
        "seq: [1, , 2]",  // missing element
        "seq: [1, 2,]",  // trailing comma
        "map: {a: 1, b 2}",  // missing colon
        "map: {a: 1, a: 2}",  // duplicate key in a flow mapping
        "map: {a: {b: 1}",  // unterminated nested flow mapping
        "a: 1\na: 2",  // duplicate key in a block mapping
        "? a\n: 1\n? a\n: 2",  // duplicate explicit key
        "- 1\n - 2",  // inconsistent block-sequence indentation
    ])
    func testMalformedInputThrows(yaml: String) {
        #expect(throws: (any Error).self) { try YAML.parse(yaml: yaml) }
    }

    @Test func testErrorAfterManyElementsIsStillReported() {
        // The loops accumulate as they go, so a fault after thousands of good
        // elements still has to surface as an error, not a truncated value.
        let items = (0..<Self.count).map(String.init).joined(separator: ", ")
        #expect(throws: (any Error).self) {
            try onSmallStack { try YAML.parse(yaml: "seq: [\(items),]") }
        }
    }
}

/// Holds a value across the thread hop below; the semaphore, not the type,
/// provides the synchronisation.
private final class Box<V>: @unchecked Sendable {
    var value: V
    init(_ value: V) { self.value = value }
}

/// Runs `body` on a thread with a deliberately small stack — smaller than a
/// Swift-concurrency cooperative thread's — so any per-element recursion shows
/// up as a crash here rather than passing on a roomy test stack.
private func onSmallStack<T>(_ body: @escaping () throws -> T) throws -> T {
    let work = Box(body)
    let result = Box<Result<T, Error>?>(nil)
    let finished = DispatchSemaphore(value: 0)
    let thread = Thread {
        result.value = Result { try work.value() }
        finished.signal()
    }
    thread.stackSize = 128 << 10  // 128 KB
    thread.start()
    finished.wait()
    return try result.value!.get()
}
