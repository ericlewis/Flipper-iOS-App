import Core
import Inject
import Analytics
import Peripheral
import SwiftUI
import Logging

@MainActor
class EmulateViewModel: ObservableObject {
    private let logger = Logger(label: "emulate-vm")

    @Inject var rpc: RPC
    @Inject var analytics: Analytics

    @Published var item: ArchiveItem
    @Published var isConnected = false
    @Published var isEmulating = false
    @Published var isFileLoaded = false
    @Published var isFlipperAppStarted = false
    @Published var isFlipperAppCancellation = false
    @Published var isFlipperAppSystemLocked = false

    var emulatePress: Date = .now
    var emulateRelease: Date = .now
    var emulateStarted: Date = .now
    private var emulateTask: Task<Void, Swift.Error>?

    @Published var appState: AppState = .shared
    var disposeBag = DisposeBag()

    init(item: ArchiveItem) {
        self.item = item

        rpc.onAppStateChanged { [weak self] state in
            guard let self = self else { return }
            Task { @MainActor in
                self.onAppStateChanged(state)
            }
        }

        appState.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.isConnected = ($0 == .connected || $0 == .synchronized)
                if $0 == .disconnected {
                    self.resetEmulate()
                }
            }
            .store(in: &disposeBag)
    }

    func onAppStateChanged(_ state: Message.AppState) {
        isFlipperAppStarted = state == .started
        if state == .closed {
            isEmulating = false
            isFlipperAppCancellation = false
        }
        logger.info("flipper app \(state)")
    }

    func waitForAppStartedEvent() async throws {
        while !isFlipperAppStarted {
            try await Task.sleep(nanoseconds: 100 * 1_000_000)
        }
    }

    func startApp() async throws {
        while !isFlipperAppCancellation {
            do {
                try await rpc.appStart(item.fileType.application, args: "RPC")
                return
            } catch let error as Error {
                if error == .application(.systemLocked) {
                    isFlipperAppSystemLocked = true
                }
                throw error
            }
        }
    }

    func loadFile(_ path: Peripheral.Path) async throws {
        try await rpc.appLoadFile(path)
        isFileLoaded = true
    }

    func startEmulate() {
        guard !isEmulating else { return }
        isEmulating = true
        emulatePress = .now
        emulateTask = Task {
            do {
                feedback(style: .soft)
                try await startApp()
                try await waitForAppStartedEvent()
                try await loadFile(item.path)
                if item.fileType == .subghz {
                    try await rpc.appButtonPress()
                }
                feedback(style: .heavy)
                emulateStarted = .now
            } catch {
                logger.error("emilating key: \(error)")
                resetEmulate()
            }
            emulateTask = nil
        }
        recordEmulate()
    }

    var emulateLag: Int {
        let desired = Int(emulateRelease.timeIntervalSince(emulatePress) * 1000)
        let emulated = Int(Date().timeIntervalSince(emulateStarted) * 1000)
        return max(0, desired - emulated)
    }

    func stopEmulate() {
        guard !isFlipperAppCancellation else { return }
        isFlipperAppCancellation = true
        emulateRelease = .now
        Task {
            _ = await emulateTask?.result
            do {
                try await Task.sleep(milliseconds: emulateLag)
                if item.fileType == .subghz {
                    try await rpc.appButtonRelease()
                }
                try await rpc.appExit()
                feedback(style: .soft)
            } catch {
                logger.error("exiting the app: \(error)")
            }
        }
    }

    func toggleEmulate() {
        isEmulating
            ? stopEmulate()
            : startEmulate()
    }

    func resetEmulate() {
        isEmulating = false
        isFileLoaded = false
        isFlipperAppStarted = false
        isFlipperAppCancellation = false
    }

    // Analytics

    func recordEmulate() {
        analytics.appOpen(target: .keyEmulate)
    }
}
