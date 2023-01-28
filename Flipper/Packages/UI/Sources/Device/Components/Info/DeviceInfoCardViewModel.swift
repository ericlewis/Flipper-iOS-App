import Core
import Inject
import Combine
import Peripheral
import Foundation
import SwiftUI

@MainActor
class DeviceInfoCardViewModel: ObservableObject {
    @Inject private var appState: AppState
    private var disposeBag: DisposeBag = .init()

    @Published
    var device: Flipper?

    var isConnecting: Bool {
        device?.state == .connecting
    }
    
    var isConnected: Bool {
        device?.state == .connected
    }
    
    var isDisconnected: Bool {
        device?.state == .disconnected ||
        device?.state == .pairingFailed ||
        device?.state == .invalidPairing
    }
    
    var isNoDevice: Bool {
        device == nil
    }
    
    var isUpdating: Bool {
        appState.status == .updating
    }

    var _protobufVersion: ProtobufVersion? {
        device?.information?.protobufRevision
    }

    var protobufVersion: String {
        guard isConnected else { return "" }
        guard let version = _protobufVersion else { return "" }
        return version == .unknown ? "—" : version.rawValue
    }

    var firmwareVersion: String {
        guard isConnected else { return "" }
        guard let info = device?.information else { return "" }
        return info.shortSoftwareVersion ?? "invalid"
    }

    var firmwareVersionColor: Color {
        switch firmwareVersion {
        case _ where firmwareVersion.starts(with: "Dev"): return .development
        case _ where firmwareVersion.starts(with: "RC"): return .candidate
        case _ where firmwareVersion.starts(with: "Release"): return .release
        default: return .clear
        }
    }

    var firmwareBuild: String {
        guard isConnected else { return "" }
        guard let info = device?.information else { return "" }

        let build = info
            .softwareRevision
            .split(separator: " ")
            .suffix(1)
            .joined(separator: " ")

        return .init(build)
    }

    var internalSpace: Text {
        guard isConnected, let int = device?.storage?.internal else {
            return Text("")
        }
        return Text(
            "\(Text(Measurement(value: Double(int.used), unit: UnitInformationStorage.bytes), format: .byteCount(style: .file))) / \(Text(Measurement(value: Double(int.total), unit: UnitInformationStorage.bytes), format: .byteCount(style: .file)))"
        )
        .foregroundColor(int.free < 20_000 ? .sRed : .primary)
    }

    var externalSpace: Text {
        guard isConnected, device?.storage?.internal != nil else {
            return Text("")
        }
        guard let ext = device?.storage?.external else {
            return Text("—")
        }
        return Text("\(Text(Measurement(value: Double(ext.used), unit: UnitInformationStorage.bytes), format: .byteCount(style: .file))) / \(Text(Measurement(value: Double(ext.total), unit: UnitInformationStorage.bytes), format: .byteCount(style: .file)))")
          .foregroundColor(ext.free < 100_000 ? .red : .primary)
    }

    init() {
        appState.$flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.device, on: self)
            .store(in: &disposeBag)
    }
}
