import SwiftUI
import AppKit

// MARK: - SwiftUI
// Fonts
extension Font {
    static let body1 = Font.system(size: 20)
    static let body2 = Font.system(size: 16)
    static let caption = Font.system(size: 12)
}



// MARK: - AppKit
// Fonts
enum AppKitFont {
    static let body1 = NSFont.systemFont(ofSize: 20)
    static let body2 = NSFont.systemFont(ofSize: 16)
    static let caption = NSFont.systemFont(ofSize: 12)
}

// Parahraph line heights
enum AppKitTextAttributes {
    
    static var body1: [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = LineHeight.body1 - AppKitFont.body1.pointSize
        return [
            .font: AppKitFont.body1,
            .paragraphStyle: paragraphStyle
        ]
    }
    
    static var body2: [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = LineHeight.body2 - AppKitFont.body2.pointSize
        return [
            .font: AppKitFont.body2,
            .paragraphStyle: paragraphStyle
        ]
    }
    
    static var caption: [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = LineHeight.caption - AppKitFont.caption.pointSize
        return [
            .font: AppKitFont.caption,
            .paragraphStyle: paragraphStyle
        ]
    }
}




// Colours (from asset catalog)
enum AppKitColor {
    static let contentPrimaryA = NSColor(named: "contentPrimaryA") ?? .labelColor
    static let contentSecondary = NSColor(named: "contentSecondary") ?? .secondaryLabelColor
    static let contentTeritary = NSColor(named: "contentTeritary") ?? .tertiaryLabelColor
    static let white = NSColor(named: "white") ?? .white
}





// MARK: - Shared
// Line heights
enum LineHeight {
    static let body1: CGFloat = 28
    static let body2: CGFloat = 22
    static let caption: CGFloat = 16
}
