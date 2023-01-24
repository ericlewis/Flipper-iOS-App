import Core
import SwiftUI

struct HubView: View {
    @StateObject
    private var viewModel: HubViewModel = .init()

    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    NFCToolsView()
                } label: {
                    NFCToolsCard(hasNotification: viewModel.hasMFLog)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Hub")
        }
        .navigationViewStyle(.stack)
    }
}
