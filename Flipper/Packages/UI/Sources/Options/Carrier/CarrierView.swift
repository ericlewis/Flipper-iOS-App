import SwiftUI

struct CarrierView: View {
    @StateObject
    private var viewModel: CarrierViewModel = .init()

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Locale Region: \(viewModel.regionCode)")
            ForEach(viewModel.carriers) { carrier in
                VStack(alignment: .leading) {
                    Text("ID: \(carrier.id)")
                    Text("Carrier name: \(carrier.name)")
                    Text("Mobile Country Code: \(carrier.countryCode)")
                    Text("Mobile Network Code: \(carrier.networkCode)")
                    Text("ISO Country Code: \(carrier.isoCountryCode)")
                    Text("Allows VOIP: \(carrier.allowsVOIP)")
                }
            }
        }
        .padding(14)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("I'm watching you")
    }
}
