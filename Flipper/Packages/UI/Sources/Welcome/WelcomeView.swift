import SwiftUI

struct WelcomeView: View {
    @StateObject var viewModel: WelcomeViewModel

    var body: some View {
        NavigationView {
            InstructionView(viewModel: .init())
                .customBackground(Color.background)
        }
        .navigationViewStyle(.stack)
    }
}
