import SwiftUI

struct NFCToolsCard: View {
  let hasNotification: Bool

  var body: some View {
    Label {
      VStack(alignment: .leading, spacing: 8) {
        Text("NFC Tools")
          .font(.headline)
          .foregroundColor(.primary)
        Text("Calculate MIFARE Classic card keys using Flipper Zero")
          .font(.subheadline)
          .multilineTextAlignment(.leading)
          .foregroundColor(.black30)
      }
    } icon: {
      Image("nfc")
        .resizable()
        .renderingMode(.template)
        .frame(width: 20, height: 20)
    }
  }
}


// ERIC TODO: put this in badge i think
//Circle()
//  .frame(width: 14, height: 14)
//  .foregroundColor(.a1)
//  .opacity(hasNotification ? 1 : 0)
