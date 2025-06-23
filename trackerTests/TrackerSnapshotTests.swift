import XCTest
import SnapshotTesting
@testable import tracker

final class TrackerViewSnapshotTests: XCTestCase {
    
    func testMainViewController_Light() {
        let vc = TrackerListViewController()
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testMainViewController_Dark() {
        let vc = TrackerListViewController()
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}

