import SwiftUI
import SwiftUISugar
import SwiftUIFlowLayout

struct TextFieldClearButton: ViewModifier {
    @Binding var fieldText: String
    
    @State var showingClearButton: Bool = false

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
    var recentStrings: [String]
    var presetStrings: [String]
    var lowercased: Bool
    var showClearButton: Bool
    
    public init(name: Binding<String>, showClearButton: Bool = false, lowercased: Bool = false, recentStrings: [String] = [], presetStrings: [String]) {
        _name = name
        self.recentStrings = recentStrings
        self.presetStrings = presetStrings
        self.lowercased = lowercased
        self.showClearButton = showClearButton
    }
}

extension NamePicker {
    public var body: some View {
        scrollView
            .navigationTitle("Name")
            .navigationBarTitleDisplayMode(.inline)
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
        TextField("Enter or pick a name", text: $name)
            .focused($isFocused, equals: true)
            .submitLabel(.done)
            .onSubmit {
                dismiss()
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
            dismiss()
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
}
