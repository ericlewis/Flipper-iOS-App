import Core
import SwiftUI

struct OptionsView: View {
    @StateObject
    private var viewModel: OptionsViewModel = .init()
  
    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
      NavigationView {
        List {
            Section(header: Text("Utilities")) {
                NavigationLink("Ping") {
                    PingView()
                }
                .disabled(!viewModel.isAvailable)
                NavigationLink("Stress Test") {
                    StressTestView()
                }
                .disabled(!viewModel.isAvailable)
                NavigationLink("Speed Test") {
                    SpeedTestView()
                }
                .disabled(!viewModel.isAvailable)
                NavigationLink("Logs") {
                    LogsView()
                }
                Button("Backup Keys") {
                    viewModel.backupKeys()
                }
                .disabled(!viewModel.hasKeys)
            }

            Section(header: Text("Device")) {
                NavigationLink("Remote Control") {
                    RemoteControlView()
                }
                NavigationLink("File Manager") {
                    FileManagerView(viewModel: .init())
                }
                Button("Reboot Flipper") {
                    viewModel.rebootFlipper()
                }
                .foregroundColor(viewModel.isAvailable ? .accentColor : .gray)
            }
            .disabled(!viewModel.isAvailable)

            Section {
                Button("Widget Settings") {
                    viewModel.showWidgetSettings()
                }
                .foregroundColor(.primary)
            }

            if viewModel.isDebugMode {
                Section(header: Text("Debug")) {
                    Toggle(isOn: $viewModel.isProvisioningDisabled) {
                        Text("Disable provisioning")
                    }
                    NavigationLink("I'm watching you") {
                        CarrierView()
                    }
                    Button("Reset App") {
                        viewModel.showResetApp = true
                    }
                    .foregroundColor(.sRed)
                    .actionSheet(isPresented: $viewModel.showResetApp) {
                        .init(title: Text("Are you sure?"), buttons: [
                            .destructive(Text("Reset App")) {
                                viewModel.resetApp()
                            },
                            .cancel()
                        ])
                    }
                }
            }

            Section {
                Link("Forum", destination: URL(string: "https://forum.flipperzero.one")!)
                Link("GitHub", destination: URL(string: "https://github.com/flipperdevices")!)
            } header: {
              Text("Resources")
            } footer: {
              VStack(alignment: .center) {
                  Text("Flipper Mobile App")
                      .font(.system(size: 12, weight: .medium))
                      .foregroundColor(.black20)
                  Text("Version: \(viewModel.appVersion)")
                      .font(.system(size: 12, weight: .medium))
                      .foregroundColor(.black40)
              }
              .frame(maxWidth: .infinity)
              .padding(.vertical)
              .onTapGesture {
                  viewModel.onVersionTapGesture()
              }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Options")
      }
    }
}
