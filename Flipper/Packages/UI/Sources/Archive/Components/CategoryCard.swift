import Core
import SwiftUI
import OrderedCollections

struct CategoryCard: View {
    let groups: OrderedDictionary<ArchiveItem.Kind, Int>

    var body: some View {
      Section {
        ForEach(groups.keys, id: \.self) { key in
            CategoryLink(
                kind: key,
                count: groups[key] ?? 0)
        }
      }
    }
}

struct CategoryLink: View {
    let kind: ArchiveItem.Kind
    let count: Int

    var body: some View {
        NavigationLink {
          CategoryView(viewModel: CategoryViewModel(name: kind.name, kind: kind))
        } label: {
            CategoryRow(
                image: kind.icon,
                name: kind.name,
                count: count)
        }
    }
}

struct CategoryDeletedLink: View {
    let count: Int

    var body: some View {
        NavigationLink {
            CategoryDeletedView()
        } label: {
            CategoryRow(image: Image("Delete"), name: "Deleted", count: count)
            .foregroundStyle(.red)
        }
    }
}

struct CategoryRow: View {
    let image: Image?
    let name: LocalizedStringKey
    let count: Int

    var body: some View {
      Label {
        Text(name)
      } icon: {
        Group {
          if let image {
            image
              .resizable()
              .renderingMode(.template)
          } else {
            ProgressView()
          }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 18)
      }
      .badge(count == 0 ? "" : "\(count)")
    }
}
