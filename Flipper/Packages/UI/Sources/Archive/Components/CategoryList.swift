import Core
import SwiftUI

struct CategoryList: View {
  struct Favorite: View {
    let item: ArchiveItem

    var body: some View {
      HStack {
        Label {
          Text(item.name.value)
        } icon: {
          item.kind.icon
            .resizable()
            .renderingMode(.template)
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 14)
        }
        Spacer()
        switch item.status {
        case .synchronizing:
          Image(systemName: "arrow.triangle.2.circlepath")
        default:
          Image(systemName: "checkmark")
        }
      }
      .symbolVariant(.fill.circle)
      .imageScale(.large)
    }
  }

  let items: [ArchiveItem]
  let onItemSelected: (ArchiveItem) -> Void

  var body: some View {
    ForEach(items) { item in
      Button {
        onItemSelected(item)
      } label: {
        Favorite(item: item)
      }
    }
  }
}
