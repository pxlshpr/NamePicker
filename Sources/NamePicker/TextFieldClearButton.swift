import SwiftUI

struct TextFieldClearButton: ViewModifier {
    @Binding var fieldText: String
    
    @State var showingClearButton: Bool

    init(fieldText: Binding<String>) {
        _fieldText = fieldText
        _showingClearButton = State(initialValue: !fieldText.wrappedValue.isEmpty)
    }
    
    func body(content: Content) -> some View {
        HStack {
            content
            if showingClearButton {
                Spacer()
                clearButton
            }
        }
        .onChange(of: fieldText) { newValue in
            withAnimation(.interactiveSpring()) {
                showingClearButton = !fieldText.isEmpty
            }
//            if !fieldText.isEmpty && !showingClearButton {
//                withAnimation(.interactiveSpring()) {
//                    showingClearButton = true
//                }
//            } else if fieldText.isEmpty && showingClearButton {
//                withAnimation(.interactiveSpring()) {
//                    showingClearButton = false
//                }
//            }
        }
    }
    
    var clearButton: some View {
        Button {
            fieldText = ""
        } label: {
            Image(systemName: "multiply.circle.fill")
        }
        .foregroundColor(.secondary)
    }
}

extension View {
    func showClearButton(_ text: Binding<String>) -> some View {
        self.modifier(TextFieldClearButton(fieldText: text))
    }
}
