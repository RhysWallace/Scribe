import SwiftUI
import AppKit

// MARK: - Hybrid Text Editor (Plain text + Links)

struct TextEditor: View {
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            LinkSupportingTextView(text: $text)
                .frame(minHeight: 200)
                .cornerRadius(4)
        }
    }
}

// MARK: - NSTextView with minimal rich text (just links)

private struct LinkSupportingTextView: NSViewRepresentable {
    @Binding var text: String
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = NSTextView()
        
        // Configure scroll view first
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        
        // Configure text view with proper sizing
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        
        // Text container setup
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.heightTracksTextView = false
        
        // Text view behavior
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.isRichText = false  // Start with plain text
        textView.isAutomaticLinkDetectionEnabled = true
        textView.isAutomaticDataDetectionEnabled = true
        
        // Appearance - force specific colors to ensure visibility
        textView.font = AppKitFont.body1
        textView.textColor = AppKitColor.contentPrimaryA
        textView.backgroundColor = AppKitColor.contentWhite
        textView.typingAttributes = AppKitTextAttributes.body1
        // textView.insertionPointColor = NSColor.black
        
        // Set the text content
        textView.string = text
        
        // Set up delegate
        textView.delegate = context.coordinator
        
        // Important: Set the document view AFTER configuration
        scrollView.documentView = textView
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        // Only update if different to prevent cursor jumping
        if textView.string != text {
            let selectedRange = textView.selectedRange()
            textView.string = text
            // Restore selection if possible
            if selectedRange.location <= text.count {
                textView.setSelectedRange(selectedRange)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        let parent: LinkSupportingTextView
        
        init(_ parent: LinkSupportingTextView) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            DispatchQueue.main.async {
                self.parent.text = textView.string
            }
        }
    }
}
