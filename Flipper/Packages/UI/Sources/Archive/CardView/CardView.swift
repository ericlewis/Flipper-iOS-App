import Core
import SwiftUI

struct CardView: View {
    @State var focusedField: String = ""
    @Binding var item: ArchiveItem
    @Binding var isEditing: Bool
    let kind: Kind

    enum Kind {
        case existing
        case imported
        case deleted
    }

    init(item: Binding<ArchiveItem>, isEditing: Binding<Bool>, kind: Kind) {
        self._item = item
        self._isEditing = isEditing
        self.kind = kind
    }

    var body: some View {
      CardHeaderView(
          item: $item,
          kind: kind,
          isEditing: isEditing
      )
      .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 5))
      .listRowSeparator(.hidden)
      CardNameView(
          item: $item,
          kind: kind,
          isEditing: $isEditing,
          focusedField: $focusedField
      )
      CardDataView(
          item: $item,
          isEditing: isEditing,
          focusedField: $focusedField
      )
    }
}
