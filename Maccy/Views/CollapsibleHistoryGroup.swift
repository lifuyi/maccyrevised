import SwiftUI

struct CollapsibleHistoryGroup: View {
  let groupIndex: Int
  let items: [HistoryItemDecorator]
  @Binding var expandedGroups: Set<Int>

  private var isExpanded: Bool {
    expandedGroups.contains(groupIndex)
  }

  private var groupTitle: String {
    let start = groupIndex * 10 + 11
    let end = groupIndex * 10 + 10 + items.count
    return "\(start)-\(end)"
  }

  var body: some View {
    VStack(spacing: 0) {
      Button(action: {
        withAnimation(.easeInOut(duration: 0.15)) {
          if isExpanded {
            expandedGroups.remove(groupIndex)
          } else {
            expandedGroups.insert(groupIndex)
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
              index: groupIndex * 10 + 10 + index
            )
          }
        }
        .padding(.top, 4)
      }
    }
  }
}