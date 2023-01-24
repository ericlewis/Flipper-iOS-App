import SwiftUI

struct ActionButton: View {
    let image: String
    let title: LocalizedStringKey
    let action: @MainActor () -> Void

    init(
        image: String,
        title: LocalizedStringKey,
        action: @escaping @MainActor () -> Void
    ) {
        self.image = image
        self.title = title
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
          Label {
            Text(title)
          } icon: {
            Image(image)
              .renderingMode(.template)
          }
        }
    }
}
