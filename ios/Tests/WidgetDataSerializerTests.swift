import XCTest
@testable import native_home_widgets

final class WidgetDataSerializerTests: XCTestCase {

    func testSerializeString() {
        let result = WidgetDataSerializer.serialize("hello")
        XCTAssertEqual(result as? String, "hello")
    }

    func testSerializeInt() {
        let result = WidgetDataSerializer.serialize(42)
        XCTAssertEqual(result as? Int, 42)
    }

    func testSerializeDouble() {
        let result = WidgetDataSerializer.serialize(3.14)
        XCTAssertEqual(result as? Double, 3.14, accuracy: 0.001)
    }

    func testSerializeBool() {
        let result = WidgetDataSerializer.serialize(true)
        XCTAssertEqual(result as? Bool, true)
    }

    func testSerializeNil() {
        let result = WidgetDataSerializer.serialize(nil)
        XCTAssertNil(result)
    }

    func testSerializeArray() {
        let input = [1, 2, 3]
        let result = WidgetDataSerializer.serialize(input)
        XCTAssertNotNil(result as? [Int])
    }

    func testSerializeDictionary() {
        let input = ["key": "value"]
        let result = WidgetDataSerializer.serialize(input)
        XCTAssertNotNil(result as? [String: String])
    }

    func testEncodeDecodeDate() {
        let original = Date(timeIntervalSince1970: 1_700_000_000)
        let encoded = WidgetDataSerializer.encodeDate(original)
        let decoded = WidgetDataSerializer.decodeDate(encoded)

        XCTAssertEqual(decoded.timeIntervalSince1970, original.timeIntervalSince1970, accuracy: 0.001)
    }
}
