import SwiftUI

struct SelectChannelPopup: View {
    let y: Double
    let onChannelSelected: (String) -> Void

    var body: some View {
        HStack {
            Spacer()
            Card {
                VStack(alignment: .leading, spacing: 0) {
                    ChannelMenuRow(
                        title: "Release",
                        description: "Stable release (recommended)",
                        onClick: onChannelSelected
                    )
                    .padding(12)

                    Divider()
                        .padding(0)

                    ChannelMenuRow(
                        title: "Release-Candidate",
                        description: "Pre-release under testing",
                        onClick: onChannelSelected
                    )
                    .padding(12)

                    Divider()
                        .padding(0)

                    ChannelMenuRow(
                        title: "Development",
                        description: "Daily unstable build, lots of bugs",
                        onClick: onChannelSelected
                    )
                    .padding(12)
                }
            }
            .frame(width: 220)
        }
        .offset(y: y - 14)
        .padding(.trailing, 14)
    }
}

struct ChannelMenuRow: View {
    let title: String
    let description: String
    var onClick: (String) -> Void

    var color: Color {
        switch title {
        case "Release": return .release
        case "Release-Candidate": return .candidate
        case "Development": return .development
        default: return .clear
        }
    }

    var body: some View {
        Button {
            onClick(title)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(color)
                    Text(description)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.black40)
                }
                Spacer()
            }
        }
    }
}

struct SelectChannelButton: View {
    @ObservedObject
    public var viewModel: DeviceUpdateCardModel

    // TODO: make work, and also add other cool things.
    var body: some View {
      Menu {
        Button("Release") {

        }
        Button("Release Candidate") {

        }
        Button("Development", role: .destructive) {

        }
      } label: {
        HStack {
          Text(viewModel.availableFirmware ?? "Unknown")
          Image(systemName: "chevron.down")
            .symbolRenderingMode(.hierarchical)
            .symbolVariant(.circle.fill)
            .imageScale(.large)
        }
        .font(.callout.bold())
      }
      .buttonStyle(.borderless)
      .foregroundStyle(viewModel.channelColor)
      .background(GeometryReader {
          Color.clear.preference(
              key: SelectChannelOffsetKey.self,
              value: $0.frame(in: .global).origin.y)
      })
      .onPreferenceChange(SelectChannelOffsetKey.self) {
          viewModel.channelSelectorOffset = $0
      }
      .popup(isPresented: $viewModel.showChannelSelector, hideOnTap: true) {
          SelectChannelPopup(y: viewModel.channelSelectorOffset) {
              viewModel.onChannelSelected($0)
          }
      }
    }
}

private struct SelectChannelOffsetKey: PreferenceKey {
    typealias Value = Double

    static var defaultValue = Double.zero

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}
