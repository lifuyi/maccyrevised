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
  
  // State for tracking expanded pool groups - all collapsed by default
  @State private var expandedGroups: Set<Int> = []

  private var pinnedItems: [HistoryItemDecorator] {
    appState.history.pinnedItems.filter(\.isVisible)
  }
  private var unpinnedItems: [HistoryItemDecorator] {
    appState.history.unpinnedItems.filter(\.isVisible)
  }
  private var showPinsSeparator: Bool {
    !pinnedItems.isEmpty && !unpinnedItems.isEmpty && appState.history.searchQuery.isEmpty
  }

  var body: some View {
    if pinTo == .top {
      LazyVStack(spacing: 0) {
        ForEach(pinnedItems) { item in
          HistoryItemView(item: item)
        }

        if showPinsSeparator {
          Divider()
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
        }
      }
      .background {
        GeometryReader { geo in
          Color.clear
            .task(id: geo.size.height) {
              appState.popup.pinnedItemsHeight = geo.size.height
            }
        }
      }
    }

    ScrollView {
      ScrollViewReader { proxy in
        LazyVStack(spacing: 0) {
          // Display first 10 unpinned items normally
          ForEach(Array(unpinnedItems.prefix(10).enumerated()), id: \.element.id) { index, item in
            HistoryItemView(item: item)
          }
          
          // Process and display pool items in collapsible groups of 10
          if unpinnedItems.count > 10 {
            PoolGroupsView(unpinnedItems: unpinnedItems, expandedGroups: $expandedGroups)
          }
        }
        .task(id: appState.scrollTarget) {
          guard appState.scrollTarget != nil else { return }

          try? await Task.sleep(for: .milliseconds(10))
          guard !Task.isCancelled else { return }

          if let selection = appState.scrollTarget {
            proxy.scrollTo(selection)
            appState.scrollTarget = nil
          }
        }
        .onChange(of: scenePhase) {
          if scenePhase == .active {
            searchFocused = true
            HistoryItemDecorator.previewThrottler.minimumDelay = Double(previewDelay) / 1000
            HistoryItemDecorator.previewThrottler.cancel()
            appState.isKeyboardNavigating = true
            appState.selection = appState.history.unpinnedItems.first?.id ?? appState.history.pinnedItems.first?.id
          } else {
            modifierFlags.flags = []
            appState.isKeyboardNavigating = true
          }
        }
        // Calculate the total height inside a scroll view.
        .background {
          GeometryReader { geo in
            Color.clear
              .task(id: appState.popup.needsResize) {
                // Wait for animations to complete (pool group expand/collapse = 0.2s + buffer)
                try? await Task.sleep(for: .milliseconds(250))
                guard !Task.isCancelled else { return }

                if appState.popup.needsResize {
                  appState.popup.resize(height: geo.size.height)
                }
              }
          }
        }
      }
      .contentMargins(.leading, 10, for: .scrollIndicators)
    }

    if pinTo == .bottom {
      LazyVStack(spacing: 0) {
        if showPinsSeparator {
          Divider()
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
        }

        ForEach(pinnedItems) { item in
          HistoryItemView(item: item)
        }
      }
      .background {
        GeometryReader { geo in
          Color.clear
            .task(id: geo.size.height) {
              appState.popup.pinnedItemsHeight = geo.size.height
            }
        }
      }
    }
  }
}

struct PoolGroupsView: View {
  let unpinnedItems: [HistoryItemDecorator]
  @Binding var expandedGroups: Set<Int>
  @Environment(AppState.self) private var appState
  
  var body: some View {
    let poolItems = Array(unpinnedItems.dropFirst(10))
    let groups = createGroups(from: poolItems)
    
    ForEach(Array(groups.enumerated()), id: \.offset) { groupIndex, group in
      PoolGroupView(
        group: group,
        groupIndex: groupIndex,
        isExpanded: expandedGroups.contains(groupIndex),
        toggleExpansion: {
          // Trigger immediate height update for responsive UI
          AppState.shared.popup.needsResize = true
          
          withAnimation(.easeInOut(duration: 0.2)) {
            if expandedGroups.contains(groupIndex) {
              expandedGroups.remove(groupIndex)
            } else {
              expandedGroups.insert(groupIndex)
            }
          }
        }
      )
    }
  }
  
  private func createGroups(from items: [HistoryItemDecorator]) -> [[HistoryItemDecorator]] {
    stride(from: 0, to: items.count, by: 10).map { startIndex in
      Array(items[startIndex..<min(startIndex + 10, items.count)])
    }
  }
}

struct PoolGroupView: View {
  let group: [HistoryItemDecorator]
  let groupIndex: Int
  let isExpanded: Bool
  let toggleExpansion: () -> Void
  
  var body: some View {
    VStack(spacing: 0) {
      // Expandable group header with enhanced styling
      HStack {
        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
          .font(.system(size: 11))
          .foregroundColor(isExpanded ? .accentColor : .secondary)
          .animation(.easeInOut(duration: 0.2), value: isExpanded)
        
        Text("Pool Group \(groupIndex + 1)")
          .font(.system(size: 11, weight: .medium, design: .default))
          .foregroundColor(isExpanded ? .primary : .secondary)
        
        Spacer()
        
        Text("\(group.count) items")
          .font(.system(size: 10))
          .foregroundColor(.secondary.opacity(0.8))
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 8)
      .background(isExpanded ? Color.accentColor.opacity(0.1) : Color.secondary.opacity(0.05))
      .cornerRadius(6)
      .padding(.horizontal, 6)
      .onTapGesture(perform: toggleExpansion)
      .scaleEffect(isExpanded ? 1.02 : 1.0)
      .animation(.easeInOut(duration: 0.1), value: isExpanded)
      
      // Items in this group (only show if expanded) with dynamic sizing
      if isExpanded {
        VStack(spacing: 1) {
          ForEach(Array(group.enumerated()), id: \.element.id) { itemIndex, item in
            HistoryItemPoolView(
              item: item, 
              poolIndex: groupIndex * 10 + itemIndex,
              groupNumber: groupIndex,
              itemInGroupIndex: itemIndex
            )
          }
        }
        .padding(.top, 4)
        .padding(.horizontal, 4)
        .transition(.asymmetric(
          insertion: .scale(scale: 0.95).combined(with: .opacity),
          removal: .scale(scale: 0.95).combined(with: .opacity)
        ))
        .animation(.easeInOut(duration: 0.25), value: isExpanded)
      }
    }
    .padding(.vertical, 2)
  }
}
