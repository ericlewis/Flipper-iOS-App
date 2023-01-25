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
      Section("Latency") {
        HStack {
          Spacer()
          Text("\(Text(viewModel.time, format: .number))ms") // ERIC TODO: fix this to be actually the write measurement
            .font(.system(size: 64).monospaced())
            .padding(.vertical)
            .foregroundStyle(viewModel.time == 0 ? .quaternary : .primary)
          Spacer()
        }
      }
      Section("Packet Size") {
        VStack(alignment: .leading) {
          Slider(
            value: $viewModel.payloadSize,
            in: (0...1024),
            step: 1
          ) {
            Text("Packet size")
          }
          Text(Measurement(value: viewModel.payloadSize, unit: UnitInformationStorage.bytes), format: .measurement(width: .narrow))
            .font(.subheadline.monospaced())
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 5)
      }
    }
    .safeAreaInset(edge: .bottom) {
      Button {
        viewModel.sendPing()
      } label: {
        Text(viewModel.isPinging ? "Measuring…" : "Ping Device")
          .frame(maxWidth: .greatestFiniteMagnitude)
      }
      .keyboardShortcut(.defaultAction)
      .controlSize(.large)
      .buttonStyle(.borderedProminent)
      .buttonBorderShape(.roundedRectangle)
      .padding()
    }
    .disabled(viewModel.isPinging)
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("Ping")
    // ERIC TODO: figure out this shit
//    .toolbar {
//      ToolbarItem(placement: .primaryAction) {
//        Menu {
//          Section("Request Timestamp") {
//            Text(Date(timeInterval: TimeInterval(viewModel.requestTimestamp) / 100, since: .now), format: .dateTime)
//          }
//          Section("Response Timestamp") {
//            Text(Date(timeInterval: TimeInterval(viewModel.responseTimestamp) / 100, since: .now), format: .dateTime)
//          }
//          Section("Speed") {
//            Text(viewModel.bytesPerSecond, format: .number)
//          }
//          Section("Latency") {
//            Text(Measurement(value: Double(viewModel.time), unit: UnitDuration(symbol: "en")), format: .measurement(width: .abbreviated))
//          }
//        } label: {
//          Label("Details", systemImage: "info.circle")
//        }
//        .disabled(viewModel.time == 0)
//      }
//    }
  }
}
