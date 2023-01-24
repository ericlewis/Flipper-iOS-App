import Core
import Peripheral
import SwiftUI

struct DeviceInfoCard: View {
    @StateObject
    private var viewModel: DeviceInfoCardViewModel = .init()

    var body: some View {
      if viewModel.isUpdating {
          VStack(spacing: 4) {
              Spinner()
              Text(
                  "Waiting for Flipper to finish update.\n" +
                  "Reconnecting..."
              )
              .multilineTextAlignment(.center)
              .font(.system(size: 14, weight: .medium))
              .foregroundColor(.black30)
          }
          .padding(.top, 66)
          .padding(.bottom, 62)
      } else if viewModel.isDisconnected || viewModel.isNoDevice {
          VStack(spacing: 2) {
              Image("InfoNoDevice")
              Text("Connect to Flipper to see device info")
                  .font(.system(size: 14, weight: .medium))
                  .foregroundColor(.black30)
          }
          .padding(.vertical, 62)
      } else {
        CardRow(
            name: "Firmware Version",
            value: viewModel.firmwareVersion
        )
        .foregroundColor(viewModel.firmwareVersionColor)
        CardRow(
            name: "Build Date",
            value: viewModel.firmwareBuild
        )
        CardRow(
            name: "Internal Flash",
            value: viewModel.internalSpace
        )
        CardRow(
            name: "SD Card",
            value: viewModel.externalSpace
        )
        NavigationLink("Device Information") {
          DeviceInfoView()
        }
      }
    }
}
