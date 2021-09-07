import Core
import Combine
import Injector
import SwiftUI

class ArchiveViewModel: ObservableObject {
    @Published var items: [ArchiveItem]

    init() {
        items = [
            .init(
                id: "123",
                name: "Moms_bank_card",
                description: "ID: 031,33351",
                isFavorite: true,
                kind: .nfc,
                wut: "Mifare")
        ]
    }
}

extension ArchiveItem {
    var icon: some View {
        switch kind {
        case .ibutton:
            return Image(systemName: "key")
                .resizable()
                .toAny()
        case .nfc:
            return Image(systemName: "wifi.circle")
                .resizable()
                .rotationEffect(.degrees(90))
                .toAny()
        case .rfid:
            return Image(systemName: "creditcard.and.123")
                .resizable()
                .toAny()
        case .subghz:
            return Image(systemName: "antenna.radiowaves.left.and.right")
                .resizable()
                .toAny()
        }
    }
}

fileprivate extension View {
    func toAny() -> AnyView { AnyView(self) }
}
