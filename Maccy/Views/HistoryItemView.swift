import Defaults
import SwiftUI

struct HistoryItemView: View {
  @Bindable var item: HistoryItemDecorator

  @Environment(AppState.self) private var appState

  var body: some View {
    ListItemView(
      id: item.id,
      appIcon: item.applicationImage,
      image: item.thumbnailImage,
      accessoryImage: item.thumbnailImage != nil ? nil : ColorImage.from(item.title),
      attributedTitle: item.attributedTitle,
      shortcuts: item.shortcuts,
      isSelected: item.isSelected
    ) {
      Text(verbatim: item.title)
    }
    .onTapGesture {
      appState.history.select(item)
    }
    .popover(isPresented: $item.showPreview, arrowEdge: .trailing) {
      PreviewItemView(item: item)
    }
  }
}

struct HistoryItemPoolView: View {
  @Bindable var item: HistoryItemDecorator
  let poolIndex: Int
  let groupNumber: Int
  let itemInGroupIndex: Int

  @Environment(AppState.self) private var appState

  var body: some View {
    ListItemView(
      id: item.id,
      appIcon: item.applicationImage,
      image: item.thumbnailImage,
      accessoryImage: item.thumbnailImage != nil ? nil : ColorImage.from(item.title),
      attributedTitle: item.attributedTitle,
      shortcuts: item.shortcuts,
      isSelected: item.isSelected,
      help: "History pool group \(groupNumber + 1), item #\(itemInGroupIndex + 1)"
    ) {
      Text(verbatim: item.title)
        .font(.system(size: 12, weight: .regular, design: .default))
    }
    .onTapGesture {
      appState.history.select(item)
    }
    .popover(isPresented: $item.showPreview, arrowEdge: .trailing) {
      PreviewItemView(item: item)
    }
    .padding(.leading, 12)
    .opacity(0.8)
    .overlay(alignment: .leading) {
      if itemInGroupIndex < 9 {
        Text("\(itemInGroupIndex + 1)")
          .font(.system(size: 9, weight: .medium, design: .monospaced))
          .foregroundColor(.secondary.opacity(0.6))
          .padding(.leading, 2)
      }
    }
    .scaleEffect(1.0)
    .animation(.easeInOut(duration: 0.15), value: item.isSelected)
  }
}
