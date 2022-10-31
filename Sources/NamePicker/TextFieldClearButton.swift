import SwiftUI
import SwiftHaptics

struct TextFieldClearButton: ViewModifier {

    @Binding var fieldText: String
    @State var showingClearButton: Bool
    var isFocused: FocusState<Bool>.Binding
    
    init(fieldText: Binding<String>, isFocused: FocusState<Bool>.Binding) {
        _fieldText = fieldText
        _showingClearButton = State(initialValue: !fieldText.wrappedValue.isEmpty)
        self.isFocused = isFocused
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
            Haptics.feedback(style: .rigid)
            fieldText = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(Color(.quaternaryLabel))
        }
        .opacity((isFocused.wrappedValue && !fieldText.isEmpty) ? 1 : 0)
        .animation(.default, value: fieldText)
    }
}

extension View {
    func showClearButton(_ text: Binding<String>, isFocused: FocusState<Bool>.Binding) -> some View {
        self.modifier(TextFieldClearButton(fieldText: text, isFocused: isFocused))
    }
}
