import Defaults
import SwiftUI

struct HistoryListView: View {
  @Binding var searchQuery: String
  @FocusState.Binding var searchFocused: Bool

  @Environment(AppState.self) private var appState
  @Environment(ModifierFlags.self) private var modifierFlags
  @Environment(\.scenePhase) private var scenePhase

  @Default(.pinTo) private var pinTo
  @Default(.previewDelay) private var previewDelay
  @Default(.showFooter) private var showFooter

  @State private var expandedGroups: Set<String> = []

  private let visibleItemCount = 10
  private let groupSize = 10

  private var visibleItems: [HistoryItemDecorator] {
    let items = Array(unpinnedItems.prefix(visibleItemCount))
    for (index, item) in items.enumerated() {
      item.visibleIndex = index
    }
    return items
  }

  private var groupedItems: [[HistoryItemDecorator]] {
    let remaining = Array(unpinnedItems.dropFirst(visibleItemCount))
    let groups = stride(from: 0, to: remaining.count, by: groupSize).map {
      Array(remaining[$0..<min($0 + groupSize, remaining.count)])
    }
    for (groupOffset, group) in groups.enumerated() {
      for (itemIndex, item) in group.enumerated() {
        item.visibleIndex = visibleItemCount + groupOffset * groupSize + itemIndex
      }
    }
    return groups
  }
  
  private func groupIdentifier(for items: [HistoryItemDecorator]) -> String {
    items.first?.id.uuidString ?? "empty"
  }

  private var pinnedItems: [HistoryItemDecorator] {
    appState.history.pinnedItems.filter(\.isVisible)
  }
  private var unpinnedItems: [HistoryItemDecorator] {
    appState.history.unpinnedItems.filter(\.isVisible)
  }
  private var showPinsSeparator: Bool {
    pinsVisible && !unpinnedItems.isEmpty
  }

  private var pinsVisible: Bool {
    return !pinnedItems.isEmpty
  }

  private var pasteStackVisible: Bool {
    if let stack = appState.history.pasteStack,
       !stack.items.isEmpty {
      return true
    }
    return false
  }

  private var topPadding: CGFloat {
    return Popup.verticalSeparatorPadding
  }

  private var bottomPadding: CGFloat {
    return showFooter
      ? Popup.verticalSeparatorPadding
      : (Popup.verticalSeparatorPadding - 1)
  }

  private func topSeparator() -> some View {
    Divider()
      .padding(.horizontal, Popup.horizontalSeparatorPadding)
      .padding(.top, Popup.verticalSeparatorPadding)
  }

  @ViewBuilder
  private func bottomSeparator() -> some View {
    Divider()
      .padding(.horizontal, Popup.horizontalSeparatorPadding)
      .padding(.bottom, Popup.verticalSeparatorPadding)
  }

  @ViewBuilder
  private func separator() -> some View {
    Divider()
      .padding(.horizontal, Popup.horizontalSeparatorPadding)
      .padding(.vertical, Popup.verticalSeparatorPadding)
  }

  var body: some View {
    let topPinsVisible = pinTo == .top && pinsVisible
    let bottomPinsVisible = pinTo == .bottom && pinsVisible
    let topSeparatorVisible = topPinsVisible || pasteStackVisible
    let bottomSeparatorVisible = bottomPinsVisible
    let scrollTopPadding = topSeparatorVisible ? Popup.verticalSeparatorPadding : topPadding
    let scrollBottomPadding = bottomSeparatorVisible ? Popup.verticalSeparatorPadding : bottomPadding

    VStack(spacing: 0) {
      if let stack = appState.history.pasteStack,
         !stack.items.isEmpty {
        PasteStackView(stack: stack)

        if topPinsVisible {
          separator()
        }
      }

      if topPinsVisible {
        PinsView(items: pinnedItems)
      }

      if topSeparatorVisible {
        topSeparator()
      }
    }
    .padding(.top, topSeparatorVisible ? topPadding : 0)
    .readHeight(appState, into: \.popup.extraTopHeight)

    ScrollView {
      ScrollViewReader { proxy in
        VStack(spacing: 0) {
          // First 10 visible items
          MultipleSelectionListView(items: visibleItems) { previous, item, next, index in
            HistoryItemView(item: item, previous: previous, next: next, index: item.visibleIndex)
          }

          // Collapsible groups for items after the first 10
          if !groupedItems.isEmpty {
            if !visibleItems.isEmpty {
              Divider()
                .padding(.horizontal, Popup.horizontalSeparatorPadding)
                .padding(.vertical, Popup.verticalSeparatorPadding)
            }

            ForEach(Array(groupedItems.enumerated()), id: \.element.first?.id) { index, items in
              let groupId = groupIdentifier(for: items)
              CollapsibleHistoryGroup(
                groupId: groupId,
                items: items,
                expandedGroups: $expandedGroups
              )
              .padding(.horizontal, 4)
              .padding(.vertical, 4)

              if index < groupedItems.count - 1 {
                Divider()
                  .padding(.horizontal, Popup.horizontalSeparatorPadding)
                  .padding(.vertical, 4)
              }
            }
          }
        }
        .padding(.top, scrollTopPadding)
        .padding(.bottom, scrollBottomPadding)
        .task(id: appState.navigator.scrollTarget) {
          guard appState.navigator.scrollTarget != nil else { return }

          try? await Task.sleep(for: .milliseconds(10))
          guard !Task.isCancelled else { return }

          if let selection = appState.navigator.scrollTarget {
            proxy.scrollTo(selection)
            appState.navigator.scrollTarget = nil
          }
        }
        .onChange(of: scenePhase) {
          if scenePhase == .active {
            searchFocused = true
            appState.navigator.isKeyboardNavigating = true
            appState.navigator.select(item: appState.history.unpinnedItems.first ?? appState.history.pinnedItems.first)
            appState.preview.enableAutoOpen()
            appState.preview.resetAutoOpenSuppression()
            appState.preview.startAutoOpen()
          } else {
            modifierFlags.flags = []
            appState.navigator.isKeyboardNavigating = true
            appState.preview.cancelAutoOpen()
          }
        }
        // Calculate the total height inside a scroll view.
        .background {
          GeometryReader { geo in
            Color.clear
              .task(id: appState.popup.needsResize) {
                try? await Task.sleep(for: .milliseconds(10))
                guard !Task.isCancelled else { return }

                if appState.popup.needsResize {
                  appState.popup.resize(height: geo.size.height)
                }
              }
          }
        }
      }
      .contentMargins(.leading, 10, for: .scrollIndicators)
      .contentMargins(.top, scrollTopPadding, for: .scrollIndicators)
      .contentMargins(.bottom, scrollBottomPadding, for: .scrollIndicators)
    }

    VStack(spacing: 0) {
      if bottomSeparatorVisible {
        bottomSeparator()
      }

      if bottomPinsVisible {
        PinsView(items: pinnedItems)
      }
    }
    .padding(.bottom, bottomSeparatorVisible ? bottomPadding : 0)
    .readHeight(appState, into: \.popup.extraBottomHeight)
  }
}
