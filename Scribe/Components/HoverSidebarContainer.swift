import SwiftUI

struct HoverSidebarContainer<SidebarContent: View>: View {
    @Binding var selectedDate: Date?
    let sidebarContent: () -> SidebarContent

    @State private var isHoveringSidebar = false
    @State private var isHoveringEdge = false

    var body: some View {
        ZStack(alignment: .leading) {
            // Invisible edge trigger area
            Color.clear
                .frame(width: 60)
                .onHover { hovering in
                    isHoveringEdge = hovering
                }

            // Sidebar content
            if isHoveringSidebar || isHoveringEdge {
                sidebarContent()
                    .frame(width: 180)
                    .transition(.move(edge: .leading))
                    .onHover { hovering in
                        isHoveringSidebar = hovering
                    }
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isHoveringSidebar || isHoveringEdge)
    }
}
