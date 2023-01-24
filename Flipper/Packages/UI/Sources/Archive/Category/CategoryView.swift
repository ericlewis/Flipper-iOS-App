import Core
import SwiftUI

struct CategoryView: View {
    @ObservedObject
    var viewModel: CategoryViewModel

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        List {
          CategoryList(items: viewModel.items) { item in
            viewModel.onItemSelected(item: item)
          }
        }
        .overlay {
          if viewModel.items.isEmpty {
            Text("You have no keys yet")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black40)
          }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.name)
        .sheet(isPresented: $viewModel.showInfoView) {
            InfoView(viewModel: .init(item: viewModel.selectedItem))
        }
    }
}
