import Core
import SwiftUI

struct NFCToolsView: View {
    @StateObject
    private var viewModel: NFCToolsViewModel = .init()

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        ScrollView {
            VStack {
                Button {
                    viewModel.showReaderAttackView = true
                } label: {
                    ReaderAttackCard(hasNotification: viewModel.hasMFLog)
                }
            }
            .padding(14)
        }
        .background(Color.background)
        .navigationTitle("NFC Tools")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $viewModel.showReaderAttackView) {
            ReaderAttackView()
        }
    }
}
