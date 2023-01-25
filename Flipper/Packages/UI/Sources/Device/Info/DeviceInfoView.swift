import Core
import Collections
import SwiftUI

struct DeviceInfoView: View {
    @StateObject
    private var viewModel: DeviceInfoViewModel = .init()

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        List {
          Section("Device") {
            DeviceInfoViewCard(
                title: "Flipper Device",
                values: [
                    "Device Name": viewModel.deviceName,
                    "Hardware Model": viewModel.hardwareModel,
                    "Hardware Region": viewModel.hardwareRegion,
                    "Hardware Region Provisioned":
                        viewModel.hardwareRegionProvisioned,
                    "Hardware Version": viewModel.hardwareVersion,
                    "Hardware OTP Version": viewModel.hardwareOTPVersion,
                    "Serial Number": viewModel.serialNumber
                ]
            )
          }
          Section("Firmware") {
            DeviceInfoViewCard(
                title: "Firmware",
                values: [
                    "Software Revision": viewModel.softwareRevision,
                    "Build Date": viewModel.buildDate,
                    "Target": viewModel.firmwareTarget,
                    "Protobuf Version": viewModel.protobufVersion
                ]
            )
          }
          Section("Radio") {
            DeviceInfoViewCard(
                title: "Radio Stack",
                values: [
                    "Firmware Version": viewModel.radioFirmware
                ]
            )
          }
          Section("Other") {
            DeviceInfoViewCard(
                title: "Other",
                values: viewModel.otherKeys
            )
          }
        }
        .textSelection(.enabled)
        .navigationTitle("Device Information")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
              ShareButton {
                  viewModel.share()
              }
              .disabled(!viewModel.isReady)
            }
        }
        .task {
            await viewModel.getInfo()
        }
    }
}

struct DeviceInfoViewCard: View {
    let title: String
    var values: OrderedDictionary<String, String>

    var zippedIndexKey: [(Int, String)] {
        .init(zip(values.keys.indices, values.keys))
    }

    var body: some View {
      ForEach(zippedIndexKey, id: \.0) { index, key in
          CardRow(name: LocalizedStringKey(key), value: LocalizedStringKey(values[key] ?? ""))
      }
    }
}
