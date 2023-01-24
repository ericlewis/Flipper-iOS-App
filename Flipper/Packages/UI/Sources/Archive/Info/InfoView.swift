import SwiftUI

struct InfoView: View {
  @ObservedObject
  var viewModel: InfoViewModel

  @StateObject
  private var alertController: AlertController = .init()

  @Environment(\.dismiss)
  private var dismiss

  var body: some View {
    NavigationView {
      VStack(alignment: .leading, spacing: 0) {
        // ERIC TODO: move this to nav bar
  //      if viewModel.isEditing {
  //        SheetEditHeader(
  //          title: "Editing",
  //          description: viewModel.item.name.value,
  //          onSave: viewModel.saveChanges,
  //          onCancel: viewModel.undoChanges
  //        )
  //      } else {
  //        SheetHeader(
  //          title: viewModel.item.isNFC ? "Card Info" : "Key Info",
  //          description: viewModel.item.name.value
  //        ) {
  //          viewModel.dismiss()
  //        }
  //      }

        List {
          Section {
            CardView(
              item: $viewModel.item,
              isEditing: $viewModel.isEditing,
              kind: .existing
            )
          } footer: {
            EmulateView(viewModel: .init(item: viewModel.item))
              .opacity(viewModel.isEditing ? 0 : 1)
              .environmentObject(alertController)
              .padding(.top)
              .padding(.bottom, 20)
              .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
          }
          if viewModel.item.isEditableNFC {
            InfoButton(
              image: "HexEditor",
              title: "Edit Dump"
            ) {
              viewModel.showDumpEditor = true
            }
            .foregroundColor(.primary)
          }
          Section {
            InfoButton(
              image: "Share",
              title: "Share" // TODO: should be system image
            ) {
              viewModel.share()
            }
            InfoButton(
              image: "Delete",
              title: "Delete" // TODO: should be system image
            ) {
              viewModel.delete()
            }
            .foregroundColor(.sRed)
          }
        }
      }
      .overlay {
        if alertController.isPresented {
          alertController.alert
        }
      }
      .bottomSheet(isPresented: $viewModel.showShareView) {
        ShareView(viewModel: .init(item: viewModel.item))
      }
      .fullScreenCover(isPresented: $viewModel.showDumpEditor) {
        NFCEditorView(viewModel: .init(item: $viewModel.item))
      }
      .alert(isPresented: $viewModel.isError) {
        Alert(title: Text(viewModel.error))
      }
      .onReceive(viewModel.dismissPublisher) {
        dismiss()
      }
      .background(Color.background)
      .edgesIgnoringSafeArea(.bottom)
      .environmentObject(alertController)
      .navigationTitle(viewModel.item.isNFC ? "Card Info" : "Key Info")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem {
          Button {
            dismiss()
          } label: {
            Label("Dismiss", systemImage: "xmark")
          }
        }
      }
    }
  }
}

struct InfoButton: View {
  let image: String
  let title: LocalizedStringKey
  let action: () -> Void

  init(
    image: String,
    title: LocalizedStringKey,
    action: @escaping () -> Void,
    longPressAction: @escaping () -> Void = {}
  ) {
    self.image = image
    self.title = title
    self.action = action
  }

  var body: some View {
    Button {
    } label: {
      HStack(spacing: 8) {
        Image(image)
          .renderingMode(.template)
        Text(title)
          .font(.system(size: 14, weight: .medium))
      }
    }
    .simultaneousGesture(TapGesture().onEnded {
      action()
    })
  }
}
