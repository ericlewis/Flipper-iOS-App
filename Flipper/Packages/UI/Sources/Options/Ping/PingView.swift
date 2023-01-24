import SwiftUI

struct PingView: View {
  @StateObject
  private var viewModel: PingViewModel = .init()

  @Environment(\.dismiss)
  private var dismiss

  @State
  private var entered: String = ""

  var body: some View {
    Form {
      Section {
        Slider(
          value: $viewModel.payloadSize,
          in: (0...1024),
          step: 1
        ) {
          Text("Packet size")
        } minimumValueLabel: {
          Text("1")
        } maximumValueLabel: {
          Text(1024, format: .number)
        }
        .padding(.vertical, 5)
      } header: {
        Text("Payload Size \(Text(viewModel.payloadSize, format: .number))")
      }
      Section("Result") {
        Text(viewModel.requestTimestamp, format: .number)
          .badge("Request")
        Text(viewModel.responseTimestamp, format: .number)
          .badge("Response")
        Text(viewModel.time, format: .number)
          .badge("Total")
        Text(viewModel.bytesPerSecond, format: .number)
          .badge("Throughput")
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("Ping")
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button("Send") {
          viewModel.sendPing()
        }
      }
    }
  }
}
