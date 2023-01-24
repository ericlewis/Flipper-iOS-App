import SwiftUI

struct LogsView: View {
    @StateObject
    private var viewModel: LogsViewModel = .init()

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        List {
            ForEach(viewModel.logs, id: \.self) { name in
                NavigationLink(name) {
                    NamedLogsView(viewModel: .init(name: name))
                }
            }
            .onDelete { indexSet in
                viewModel.delete(at: indexSet)
            }
        }
        .navigationTitle("Logs")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          Menu {
            Section("Log Level") {
              ForEach(viewModel.logLevels, id: \.self) { level in
                  Button {
                      viewModel.changeLogLevel(to: level)
                  } label: {
                      HStack {
                          Text(level.rawValue)
                          if level == viewModel.logLevel {
                              Image(systemName: "checkmark")
                          }
                      }
                  }
              }
            }
          } label: {
            Label("Log Level", systemImage: "line.3.horizontal.decrease.circle")
          }
          Button {
            viewModel.deleteAll()
          } label: {
            Label("Delete All", systemImage: "trash")
          }
        }
    }
}
