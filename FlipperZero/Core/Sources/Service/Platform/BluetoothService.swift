import Foundation
import CoreBluetoothMock

class BluetoothService: NSObject, BluetoothConnector {
    private let manager: CBCentralManager

    private var flipperServiceIDs: [CBUUID] { [.flipperZeroWhite, .flipperZeroBlack] }

    private let statusSubject = SafeSubject(BluetoothStatus.notReady(.preparing))
    private let peripheralsSubject = SafeSubject([Peripheral]())

    // TODO: Move to separate protocol
    private let connectedPeripheralSubject = SafeSubject(Peripheral?.none)
    private let receivedSubject = SafeSubject([UInt8]())

    var status: SafePublisher<BluetoothStatus> {
        self.statusSubject.eraseToAnyPublisher()
    }

    var peripherals: SafePublisher<[Peripheral]> {
        self.peripheralsSubject.eraseToAnyPublisher()
    }

    var connectedPeripheral: SafePublisher<Peripheral?> {
        self.connectedPeripheralSubject.eraseToAnyPublisher()
    }

    var received: SafePublisher<[UInt8]> {
        receivedSubject.eraseToAnyPublisher()
    }

    private var peripheralsMap = [UUID: CBPeripheral]() {
        didSet { publishPeripherals() }
    }

    private var connectedCBPeripheral: CBPeripheral? {
        didSet { publishConnectedPeripheral() }
    }

    private func publishPeripherals() {
        let connected = manager
            .retrieveConnectedPeripherals(withServices: [.deviceInformation])
            .filter { $0.state == .connected }
            .compactMap(Peripheral.init)

        let discovered = peripheralsMap.values
            .compactMap(Peripheral.init)
            .filter { !connected.contains($0) }

        peripheralsSubject.value = (connected + discovered)
            .sorted { $0.name < $1.name }
    }

    private func publishConnectedPeripheral() {
        if let connected = connectedCBPeripheral {
            connectedPeripheralSubject.value = Peripheral(connected)
        } else {
            connectedPeripheralSubject.value = .none
        }
    }

    override init() {
        self.manager = CBCentralManagerFactory.instance(forceMock: false)
        super.init()
        self.manager.delegate = self
    }

    func startScanForPeripherals() {
        if self.statusSubject.value == .ready {
            self.manager.scanForPeripherals(withServices: flipperServiceIDs)
        }
    }

    func stopScanForPeripherals() {
        if self.manager.isScanning {
            self.peripheralsMap.removeAll()
            self.manager.stopScan()
        }
    }

    func connect(to uuid: UUID) {
        manager.retrievePeripherals(withIdentifiers: [uuid]).forEach {
            manager.connect($0)
            peripheralsMap[$0.identifier] = $0
        }
    }

    func forget(about uuid: UUID) {
        manager.retrievePeripherals(withIdentifiers: [uuid]).forEach {
            manager.cancelPeripheralConnection($0)
        }
    }

    // TODO: Move to separate protocol
    func send(_ bytes: [UInt8]) {
        guard let connected = connectedCBPeripheral else {
            print("no device connected")
            return
        }
        guard let tx = connected.serialWrite else {
            print("no serial service")
            return
        }
        connected.writeValue(.init(bytes), for: tx, type: .withResponse)
    }
}

extension BluetoothService: CBCentralManagerDelegate {

    // MARK: Status changed

    func centralManagerDidUpdateState(_ manager: CBCentralManager) {
        if manager.state != .poweredOn {
            self.peripheralsMap.removeAll()
        }
        self.statusSubject.value = .init(manager.state)
    }

    // MARK: Did discover

    func centralManager(
        _: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi: NSNumber
    ) {
        self.peripheralsMap[peripheral.identifier] = peripheral
    }

    // MARK: Connection status changed

    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        if let connected = connectedCBPeripheral {
            central.cancelPeripheralConnection(connected)
        }
        peripheral.delegate = self
        connectedCBPeripheral = peripheral
        publishConnectedPeripheral()
        publishPeripherals()

        peripheral.discoverServices(nil)
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        if connectedCBPeripheral?.identifier == peripheral.identifier {
            connectedCBPeripheral = nil
        }
        publishConnectedPeripheral()
        publishPeripherals()
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        publishConnectedPeripheral()
        publishPeripherals()
    }
}

// MARK: Peripheral delegate

extension BluetoothService: CBPeripheralDelegate {

    // MARK: Services

    public func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?
    ) {
        peripheral.services?.forEach { service in
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    // MARK: Characteristics

    public func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        service.characteristics?.forEach { characteristic in
            switch service.uuid {
            case .serial:
                // subscribe to rx updates
                if characteristic.properties.contains(.indicate) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            default:
                // subscibe to value updates
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                // read the value
                peripheral.readValue(for: characteristic)
            }
        }
    }

    // MARK: Values

    public func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if characteristic.uuid == .serialRead {
            receivedSubject.value = .init((characteristic.value ?? .init()))
        } else {
            publishConnectedPeripheral()
        }
    }
}

fileprivate extension CBPeripheral {
    var serialWrite: CBCharacteristic? {
        services?
            .first { $0.uuid == .serial }?
            .characteristics?
            .first { $0.uuid == .serialWrite }
    }
}

fileprivate extension BluetoothStatus {
    init(_ source: CBManagerState) {
        switch source {
        case .resetting, .unknown:
            self = .notReady(.preparing)
        case .unsupported:
            self = .notReady(.unsupported)
        case .unauthorized:
            self = .notReady(.unauthorized)
        case .poweredOff:
            self = .notReady(.poweredOff)
        case .poweredOn:
            self = .ready
        }
    }
}

fileprivate extension Peripheral {
    init?(_ source: CBPeripheral) {
        guard let name = source.name, name.starts(with: "Flipper") else {
            return nil
        }

        self.id = source.identifier
        self.name = name
        self.state = .init(source.state)

        self.deviceInformation = source.services?
            .first { $0.uuid == .deviceInformation }
            .map(Service.DeviceInformation.init) ?? nil

        self.battery = source.services?
            .first { $0.uuid == .battery }
            .map(Service.Battery.init) ?? nil
    }
}

fileprivate extension Peripheral.State {
    init(_ source: CBPeripheralState) {
        // swiftlint:disable switch_case_on_newline
        switch source {
        case .disconnected: self = .disconnected
        case .connecting: self = .connecting
        case .connected: self = .connected
        case .disconnecting: self = .disconnecting
        @unknown default: self = .disconnected
        }
    }
}

fileprivate extension Peripheral.Service.DeviceInformation {
    init?(_ source: CBService) {
        guard source.uuid == .deviceInformation else { return nil }
        self.init(manufacturerName: "", modelNumber: "", firmwareRevision: "", softwareRevision: "")
        source.characteristics?.forEach {
            switch $0.uuid.description.dropLast(" String".count) {
            case manufacturerName.name: self.manufacturerName.value = parse($0.value)
            case modelNumber.name: self.modelNumber.value = parse($0.value)
            case firmwareRevision.name: self.firmwareRevision.value = parse($0.value)
            case softwareRevision.name: self.softwareRevision.value = parse($0.value)
            default: return
            }
        }
    }

    private func parse(_ data: Data?) -> String {
        guard let data = data else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }
}

fileprivate extension Peripheral.Service.Battery {
    init?(_ source: CBService) {
        guard
            source.uuid == .battery,
            let level = source.characteristics?.first,
            let data = level.value, data.count == 1
        else {
            return nil
        }
        self.init(level: Int(data[0]))
    }
}

extension Peripheral.Service {
    init(_ source: CBService) {
        self.name = source.uuid.description
        self.characteristics = source.characteristics?.map(Characteristic.init) ?? []
    }
}

extension Peripheral.Service.Characteristic {
    init(_ source: CBCharacteristic) {
        self.name = source.uuid.description
        switch source.value {
        case let .some(data):
            self.value = String(data: data, encoding: .utf8) ?? ""
        case .none:
            self.value = ""
        }
    }
}

extension CBUUID {
    static var flipperZeroWhite: CBUUID { .init(string: "3080") }
    static var flipperZeroBlack: CBUUID { .init(string: "3081") }

    static var deviceInformation: CBUUID { .init(string: "180A") }
    static var battery: CBUUID { .init(string: "180F") }
    static var batteryLevel: CBUUID { .init(string: "2A19") }

    static var serial: CBUUID { .init(string: "8FE5B3D5-2E7F-4A98-2A48-7ACC60FE0000") }
    static var serialRead: CBUUID { .init(string: "19ED82AE-ED21-4C9D-4145-228E61FE0000") }
    static var serialWrite: CBUUID { .init(string: "19ED82AE-ED21-4C9D-4145-228E62FE0000") }
}
