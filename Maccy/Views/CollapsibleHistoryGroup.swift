import SwiftUI

struct CollapsibleHistoryGroup: View {
  let groupId: String
  let items: [HistoryItemDecorator]
  @Binding var expandedGroups: Set<String>

  private var isExpanded: Bool {
    expandedGroups.contains(groupId)
  }

  private var groupTitle: String {
    let start = items.first?.visibleIndex ?? 0
    let end = start + items.count - 1
    return "\(start)-\(end)"
  }

  var body: some View {
    VStack(spacing: 0) {
      Button(action: {
        withAnimation(.easeInOut(duration: 0.15)) {
          if isExpanded {
            expandedGroups.remove(groupId)
          } else {
            expandedGroups.insert(groupId)
          }
        }
      }) {
        HStack(spacing: 8) {
          Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.secondary.opacity(0.8))
            .frame(width: 16)

          Text(groupTitle)
            .font(.system(size: 12))
            .foregroundColor(.secondary.opacity(0.8))

          Spacer()

          Text("\(items.count)")
            .font(.system(size: 11))
            .foregroundColor(.secondary.opacity(0.6))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
          RoundedRectangle(cornerRadius: Popup.cornerRadius, style: .continuous)
            .fill(Color.secondary.opacity(0.08))
        )
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)

      if isExpanded {
        VStack(spacing: 0) {
          ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
            HistoryItemView(
              item: item,
              previous: nil,
              next: index < items.count - 1 ? items[index + 1] : nil,
              index: item.visibleIndex
            )
          }
        }
        .padding(.top, 4)
      }
    }
  }
}