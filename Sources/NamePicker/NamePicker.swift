import SwiftUI
import SwiftUISugar
import SwiftHaptics
import Introspect

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

public struct NamePicker: View {
    @Binding var name: String
    
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool?
    let recentStrings: [String]
    let presetStrings: [String]
    let lowercased: Bool
    let showClearButton: Bool
    let focusImmediately: Bool

    @State var uiTextField: UITextField? = nil
    @State var hasBecomeFirstResponder: Bool = false

    public init(
        name: Binding<String>,
        showClearButton: Bool = false,
        focusImmediately: Bool = false,
        lowercased: Bool = false,
        recentStrings: [String] = [],
        presetStrings: [String])
    {
        _name = name
        self.recentStrings = recentStrings
        self.presetStrings = presetStrings
        self.lowercased = lowercased
        self.showClearButton = showClearButton
        self.focusImmediately = focusImmediately
    }
}

extension NamePicker {
    public var body: some View {
        scrollView
            .navigationTitle("Name")
            .navigationBarTitleDisplayMode(.inline)
            .introspectTextField(customize: introspectTextField)
    }
    
    /// We're using this to focus the textfield seemingly before this view even appears (as the `.onAppear` modifier—shows the keyboard coming up with an animation
    func introspectTextField(_ uiTextField: UITextField) {
        guard focusImmediately, self.uiTextField == nil, !hasBecomeFirstResponder else {
            return
        }
        
        self.uiTextField = uiTextField
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            uiTextField.becomeFirstResponder()
            /// Set this so further invocations of the `introspectTextField` modifier doesn't set focus again (this happens during dismissal for example)
            hasBecomeFirstResponder = true
        }
    }
    
    var formattedRecentStrings: [String] {
        guard lowercased else {
            return recentStrings
        }
        return recentStrings.map { $0.lowercased() }
    }
    
    var formattedPresetStrings: [String] {
        guard lowercased else {
            return presetStrings
        }
        return presetStrings.map { $0.lowercased() }
    }

    var scrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                textField
                if !recentStrings.isEmpty {
                    Text("Frequently Used")
                        .formSectionHeaderStyle()
                    FlowLayout(mode: .scrollable, items: formattedRecentStrings, itemSpacing: 4) {
                        button(forSuggestion: $0)
                    }
                    .formElementStyle()
                }
                Text("Presets")
                    .formSectionHeaderStyle()
                FlowLayout(mode: .scrollable, items: formattedPresetStrings, itemSpacing: 4) {
                    button(forSuggestion: $0)
                }
                .formElementStyle()
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    var textField: some View {
        let binding = Binding<String>(get: {
            self.name
        }, set: {
            self.name = lowercased ? $0.lowercased() : $0
        })
        
        return TextField("Enter or pick a name", text: binding)
            .focused($isFocused, equals: true)
            .submitLabel(.done)
            .onSubmit {
                dismissForm()
            }
            .if(lowercased) { view in
                view
                    .textInputAutocapitalization(.never)
            }
            .if(showClearButton) { view in
                view
                    .showClearButton($name)
            }
            .formElementStyle()
    }
    
    func button(forSuggestion string: String) -> some View {
        Button {
            name = string
            dismissForm()
        } label: {
            Text(string)
              .foregroundColor(Color(.secondaryLabel))
              .padding(.vertical, 6)
              .padding(.horizontal, 8)
              .background(
                RoundedRectangle(cornerRadius: 5.0)
                      .fill(Color(.secondarySystemFill))
              )
        }
    }
    
    func dismissForm() {
        Haptics.feedback(style: .heavy)
        dismiss()
    }
}
