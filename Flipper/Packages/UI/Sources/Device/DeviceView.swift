import Core
import SwiftUI

struct DeviceView: View {
    @StateObject
    private var viewModel: DeviceViewModel = .init()

    var body: some View {
        NavigationView {
          List {
            Section {
              if viewModel.status == .unsupportedDevice {
                UnsupportedDevice()
              } else if viewModel.status != .noDevice {
                DeviceUpdateCard()
              }
              if viewModel.status != .unsupportedDevice {
                Section {
                  // TODO: handle the disclosure indicator
  //                      NavigationLink {
  //                          DeviceInfoView()
  //                      } label: {
                      DeviceInfoCard()
                        .frame(maxWidth: .greatestFiniteMagnitude)
  //                      }
                  .disabled(!viewModel.status.isAvailable) // ERIC TODO: disable this during testing or something?
                }
              }
            } header: {
              DeviceHeader(device: viewModel.flipper)
                .cornerRadius(8)
                .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0))
            }
            if viewModel.status != .noDevice {
              Section {
                ActionButton(
                    image: "Sync",
                    title: "Synchronize"
                ) {
                    viewModel.sync()
                }
                .disabled(!viewModel.canSync)
                ActionButton(
                    image: "Alert",
                    title: "Play Alert"
                ) {
                    viewModel.playAlert()
                }
                .disabled(!viewModel.canPlayAlert)
              }
            }
            Section {
              if viewModel.status == .noDevice {
                  ActionButton(
                      image: "Connect",
                      title: "Connect Flipper"
                  ) {
                      viewModel.connect()
                  }
              } else {
                if viewModel.canConnect {
                    ActionButton(
                        image: "Connect",
                        title: "Connect"
                    ) {
                        viewModel.connect()
                    }
                } else if viewModel.canDisconnect {
                    ActionButton(
                        image: "Disconnect",
                        title: "Disconnect"
                    ) {
                        viewModel.disconnect()
                    }
                    if viewModel.canForget {
                        ActionButton(
                            image: "Forget",
                            title: "Forget Flipper"
                        ) {
                            viewModel.showForgetActionSheet()
                        }
                        .foregroundColor(.sRed)
                    }
                }
              }
            }
            .navigationBarTitle("Connected")
            .navigationBarTitleDisplayMode(.inline)
          }
//            VStack(spacing: 0) {
//
////              Color.clear.alert(
////                  isPresented: $viewModel.showUnsupportedVersionAlert
////              ) {
////                  .unsupportedDeviceIssue
////              }
//            }
            .actionSheet(isPresented: $viewModel.showForgetAction) {
                .init(
                    title: Text("This action won't delete your keys"),
                    buttons: [
                        .destructive(Text("Forget Flipper")) {
                            viewModel.forgetFlipper()
                        },
                        .cancel()
                    ]
                )
            }
        }
        .navigationViewStyle(.stack)
    }
}
