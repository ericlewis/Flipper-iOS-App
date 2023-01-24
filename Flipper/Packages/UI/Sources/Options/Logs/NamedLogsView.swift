import SwiftUI

struct NamedLogsView: View {
    @StateObject var viewModel: NamedLogsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(viewModel.messages, id: \.self) { message in
                Text(message)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.name)
        .toolbar {
          // ERIC TODO: should use share link, and idk what we are sharing.
          ShareLink(item: "https://google.com") {
            Label("Share Log", systemImage: "square.and.arrow.up")
          }
        }
    }
}
