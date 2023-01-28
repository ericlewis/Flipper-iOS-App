import Core
import SwiftUI
import Combine
import PagingView

struct FavoriteCard: View {
  let item: ArchiveItem

  @State
  private var selectedItem: ArchiveItem?

  var body: some View {
    Button {
      selectedItem = item
    } label: {
      ZStack {
        RoundedRectangle(cornerRadius: 10).fill(item.kind.color)
        VStack(alignment: .leading) {
          HStack {
            item.kind.icon
              .resizable()
              .aspectRatio(1, contentMode: .fit)
              .frame(width: 14)
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
          Spacer()
          Text(item.name.value)
            .font(.callout.bold())
        }
        .foregroundStyle(.white)
        .padding(8)
      }
    }
    .buttonStyle(.plain)
    .sheet(item: $selectedItem) { item in
      InfoView(viewModel: .init(item: item))
    }
  }
}

struct ArchiveView: View {
  @StateObject
  private var viewModel: ArchiveViewModel = .init()

  var body: some View {
    NavigationStack {
      VStack {
        if viewModel.status == .connecting {
          VStack(spacing: 4) {
            Spinner()
            Text("Connecting to Flipper...")
              .font(.system(size: 14, weight: .medium))
              .foregroundColor(.black30)
          }
        } else if viewModel.status == .synchronizing {
          VStack(spacing: 4) {
            ProgressView(value: Double(viewModel.syncProgress), total: 100)
              .progressViewStyle(.circular)
            Text(
              viewModel.syncProgress == 0
              ? "Synchronizing..."
              : "Synchronizing \(viewModel.syncProgress)%"
            )
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.black30)
          }
        } else {
          List {
            Section {
              CategoryCard(
                groups: viewModel.groups
              )
            } header: {
              if !viewModel.favoriteItems.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                  HStack {
                    Label("Favorites", systemImage: "star")
                      .symbolVariant(.fill)
                      .symbolRenderingMode(.multicolor)
                    Spacer()
                  }
                  .padding(.top, 8)
                  PagingView(config: .init(margin: 20, spacing: 10)) {
                    ForEach(viewModel.favoriteItems) { item in
                      FavoriteCard(item: item)
                    }
                  }
                  .aspectRatio(2.7, contentMode: .fit)
                  .padding(.top, 14)
                  .padding(.bottom, 20)
                  .padding(.horizontal, -20)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
              }
            }
            CategoryDeletedLink(count: viewModel.deleted.count)
          }
          .searchable(text: .constant(""))
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle("Archive")
      // ERIC TODO: fix this? make search work
      //            .toolbar {
      //                ToolbarItem {
      //                    SearchButton {
      //                        viewModel.showSearchView = true
      //                    }
      //                }
      //            }
      .sheet(isPresented: $viewModel.showInfoView) {
        InfoView(viewModel: .init(item: viewModel.selectedItem))
      }
      .sheet(isPresented: $viewModel.hasImportedItem) {
        ImportView(viewModel: .init(url: viewModel.importedItem))
      }
      .fullScreenCover(isPresented: $viewModel.showSearchView) {
        ArchiveSearchView(viewModel: .init())
      }
      .fullScreenCover(isPresented: $viewModel.showWidgetSettings) {
        WidgetSettingsView(viewModel: .init())
      }
      .onAppear {
          viewModel.refresh()
      }
    }
  }
}

extension ArchiveView {
  struct FavoritesSection: View {
    @StateObject
    private var viewModel: ArchiveViewModel

    var body: some View {
      VStack(alignment: .leading, spacing: 12) {
        HStack {
          Text("Favorites")
            .font(.system(size: 16, weight: .bold))
          Image("StarFilled")
            .resizable()
            .renderingMode(.template)
            .frame(width: 20, height: 20)
            .foregroundColor(.sYellow)
        }

        CompactList(items: viewModel.favoriteItems) { item in
          viewModel.onItemSelected(item: item)
        }
      }
    }
  }
}
