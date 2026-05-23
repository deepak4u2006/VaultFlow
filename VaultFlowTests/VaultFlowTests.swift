import XCTest
@testable import VaultFlow

final class VaultFlowTests: XCTestCase {
    private var store: KeychainStore!

    override func setUp() {
        super.setUp()
        store = KeychainStore(service: "com.deepak.portfolio.vaultflow.tests.\(UUID().uuidString)")
    }

    func testKeychainRoundTrip() throws {
        let key = "test.pin"
        try store.save(key: key, value: "4829")
        XCTAssertEqual(try store.load(key: key), "4829")
        try store.delete(key: key)
        XCTAssertNil(try store.load(key: key))
    }

    func testKeychainOverwrite() throws {
        let key = "test.pin.overwrite"
        try store.save(key: key, value: "1111")
        try store.save(key: key, value: "2222")
        XCTAssertEqual(try store.load(key: key), "2222")
        try store.delete(key: key)
    }
}
