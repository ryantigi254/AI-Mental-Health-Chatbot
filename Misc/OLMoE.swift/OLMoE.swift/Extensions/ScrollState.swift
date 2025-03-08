import SwiftUI

struct ScrollState {
    static let BottomScrollThreshold = 40.0
    static let ScrollSpaceName: String = "scrollSpace"

    public var contentHeight: CGFloat = 0
    public var isAtBottom: Bool = true
    public var scrollOffset: CGFloat = 0
    public var scrollViewHeight: CGFloat = 0

    mutating func onContentResized(contentHeight: CGFloat) {
        self.contentHeight = contentHeight
        updateState()
    }

    mutating func onScroll(scrollOffset: CGFloat) {
        self.scrollOffset = scrollOffset
        updateState()
    }

    private mutating func updateState() {
        let needsScroll = contentHeight > scrollViewHeight
        let sizeDelta = contentHeight - scrollViewHeight
        let offsetDelta = abs(sizeDelta) + scrollOffset
        let isAtBottom = !needsScroll || offsetDelta < ScrollState.BottomScrollThreshold
        self.isAtBottom = isAtBottom
    }
} 