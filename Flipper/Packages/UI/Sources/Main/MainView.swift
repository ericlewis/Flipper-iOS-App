import SwiftUI

struct MainView: View {
    @StateObject
    private var viewModel: MainViewModel = .init()

    @StateObject
    private var tabViewController: TabViewController = .init()

    init() {
      // ERIC TODO: moo
      UITabBarItem.appearance().badgeColor = .systemOrange
    }

    var body: some View {
      SwiftUI.TabView(selection: $viewModel.selectedTab) {
        DeviceView()
          .tag(TabView.Tab.device)
          .tabItem {
            Label("Connected", systemImage: "checkmark.circle")
          }
        ArchiveView()
          .tag(TabView.Tab.archive)
          .tabItem {
            Label("Archive", systemImage: "folder")
          }
        HubView()
          .tag(TabView.Tab.hub)
          .tabItem {
            Label("Hub", systemImage: "rectangle.grid.2x2")
          }
          .badge("")
        OptionsView()
          .tag(TabView.Tab.options)
          .tabItem {
            Label("Options", systemImage: "gearshape")
          }
      }
      // ERIC TODO: kill this, we don't need it i think since its hide / show
        .environmentObject(tabViewController)
    }
}

struct ImportedBanner: View {
    let itemName: String
    @Environment(\.colorScheme) var colorScheme

    var backgroundColor: Color {
        colorScheme == .light ? .black4 : .black80
    }

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                Image("Done")
                VStack(alignment: .leading, spacing: 2) {
                    Text(itemName)
                        .lineLimit(1)
                        .font(.system(size: 12, weight: .bold))
                    Text("saved to Archive")
                        .font(.system(size: 12, weight: .medium))
                }
                Spacer()
            }
            .padding(12)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(8)
        }
        .padding(12)
    }
}
