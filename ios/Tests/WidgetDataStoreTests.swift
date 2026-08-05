import XCTest
@testable import native_home_widgets

final class WidgetDataStoreTests: XCTestCase {

    var store: WidgetDataStore!

    override func setUp() {
        super.setUp()
        // Use standard UserDefaults for testing (no App Group needed)
        store = WidgetDataStore(appGroupId: nil)
        // Clean state
        store.clear()
    }

    override func tearDown() {
        store.clear()
        store = nil
        super.tearDown()
    }

    func testSaveAndGetString() {
        store.save(key: "title", value: "Hello")
        let result = store.get(key: "title") as? String
        XCTAssertEqual(result, "Hello")
    }

    func testSaveAndGetInt() {
        store.save(key: "count", value: 42)
        let result = store.get(key: "count") as? Int
        XCTAssertEqual(result, 42)
    }

    func testSaveAndGetBool() {
        store.save(key: "enabled", value: true)
        let result = store.get(key: "enabled") as? Bool
        XCTAssertEqual(result, true)
    }

    func testGetReturnsDefaultValueWhenKeyMissing() {
        let result = store.get(key: "missing", defaultValue: "fallback")
        XCTAssertEqual(result as? String, "fallback")
    }

    func testRemoveDeletesKey() {
        store.save(key: "temp", value: "data")
        store.remove(key: "temp")
        let result = store.get(key: "temp")
        XCTAssertNil(result)
    }

    func testWidgetScopedKeys() {
        store.save(key: "title", value: "Widget A", widgetId: "w1")
        store.save(key: "title", value: "Widget B", widgetId: "w2")

        let a = store.get(key: "title", widgetId: "w1") as? String
        let b = store.get(key: "title", widgetId: "w2") as? String

        XCTAssertEqual(a, "Widget A")
        XCTAssertEqual(b, "Widget B")
    }

    func testClearWithWidgetId() {
        store.save(key: "title", value: "A", widgetId: "w1")
        store.save(key: "title", value: "B", widgetId: "w2")

        store.clear(widgetId: "w1")

        let a = store.get(key: "title", widgetId: "w1")
        let b = store.get(key: "title", widgetId: "w2") as? String

        XCTAssertNil(a)
        XCTAssertEqual(b, "B")
    }

    func testClearAll() {
        store.save(key: "a", value: 1)
        store.save(key: "b", value: 2)

        store.clear()

        XCTAssertNil(store.get(key: "a"))
        XCTAssertNil(store.get(key: "b"))
    }

    func testOverwriteValue() {
        store.save(key: "key", value: "first")
        store.save(key: "key", value: "second")

        let result = store.get(key: "key") as? String
        XCTAssertEqual(result, "second")
    }
}
