import CoreTelephony

@MainActor
class CarrierViewModel: ObservableObject {
    let carriers: [Carrier]
    var regionCode: String {
      Locale.current.language.region?.identifier ?? "unknown"
    }

    struct Carrier: Identifiable {
        let id: String
        let name: String
        let countryCode: String
        let networkCode: String
        let isoCountryCode: String
        let allowsVOIP: String
    }

    init() {
        var carriers: [Carrier] = []
        CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.forEach {
            let carrier = $0.value
          // ERIC TODO: this may not be desired, but the depracation is a thing.
          if #available(iOS 16.0, *) {
            carriers.append(.init(
                id: $0.key,
                name: "unknown",
                countryCode: "unknown",
                networkCode: "unknown",
                isoCountryCode: "unknown",
                allowsVOIP: "no")
            )
          } else {
            carriers.append(.init(
                id: $0.key,
                name: carrier.carrierName ?? "unknown",
                countryCode: carrier.mobileCountryCode ?? "unknown",
                networkCode: carrier.mobileNetworkCode ?? "unknown",
                isoCountryCode: carrier.isoCountryCode ?? "unknown",
                allowsVOIP: carrier.allowsVOIP ? "yes" : "no")
            )
          }
        }
        self.carriers = carriers
    }
}

extension String {
    var localizedCountry: String {
        (Locale.current as NSLocale)
            .displayName(forKey: .countryCode, value: self) ?? "unknown"
    }
}
