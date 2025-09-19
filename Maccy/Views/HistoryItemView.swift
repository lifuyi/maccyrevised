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
      help: "History pool item #\(poolIndex + 11)"
    ) {
      Text(verbatim: item.title)
        .font(.system(size: 11, weight: .regular, design: .default))
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
      if poolIndex < 9 {
        Text("\(poolIndex + 11)")
          .font(.system(size: 9, weight: .bold, design: .monospaced))
          .foregroundColor(.secondary)
          .padding(.leading, 2)
      }
    }
  }
}
