import Foundation

protocol TrackerListDelegate: AnyObject {
    func didTapButton(_ cell: TrackerListCell)
    func didTapBackground(_ cell: TrackerListCell)
}
