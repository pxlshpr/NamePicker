import SwiftUI
import SwiftUISugar
import SwiftHaptics

public struct NamePicker: View {
    @Binding var name: String
    
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    let recentStrings: [String]
    let presetStrings: [String]
    let lowercased: Bool
    let showClearButton: Bool
    let focusOnAppear: Bool
    
    let title: String
    let titleDisplayMode: NavigationBarItem.TitleDisplayMode

    public init(
        name: Binding<String>,
        showClearButton: Bool = false,
        focusOnAppear: Bool = false,
        lowercased: Bool = false,
        title: String = "Name",
        titleDisplayMode: NavigationBarItem.TitleDisplayMode = .inline,
        recentStrings: [String] = [],
        presetStrings: [String])
    {
        _name = name
        self.recentStrings = recentStrings
        self.presetStrings = presetStrings
        self.lowercased = lowercased
        self.title = title
        self.titleDisplayMode = titleDisplayMode
        self.showClearButton = showClearButton
        self.focusOnAppear = focusOnAppear
    }
}

extension NamePicker {
    public var body: some View {
        scrollView
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(titleDisplayMode)
            .onAppear(perform: appeared)
    }
    
    func appeared() {
        if focusOnAppear {
            isFocused = true
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
        FormStyledScrollView {
            FormStyledSection {
                textField
            }
            if !recentStrings.isEmpty {
                FormStyledSection(header: Text("Recently Used")) {
                    FlowLayout(mode: .scrollable, items: formattedRecentStrings, itemSpacing: 4) {
                        button(forSuggestion: $0)
                    }
                }
            }
            FormStyledSection(header: Text("Presets")) {
                FlowLayout(mode: .scrollable, items: formattedPresetStrings, itemSpacing: 4) {
                    button(forSuggestion: $0)
                }
            }
        }
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

public struct NamePickerPreview: View {
    
    @State var showingNamePicker = false
    @State var name: String = ""
    
    public init() { }
    
    public var body: some View {
        Button("Pick Name") {
            showingNamePicker = true
        }
        .sheet(isPresented: $showingNamePicker) {
            NavigationView {
                NamePicker(name: $name,
                           showClearButton: true,
                           focusOnAppear: true,
                           lowercased: true,
                           title: "Size Name",
                           titleDisplayMode: .large,
                           recentStrings: ["Recent 1", "Recent 2"],
                           presetStrings: ["Preset 1", "Preset 2", "Preset 1", "Preset 2", "Preset 1", "Presetasdasdas 2", "Pr 1", "Preset 2", "Preset 1", "Preset 2", "Preset 1", "Preset 2"])
            }
        }
    }
}

struct NamePicker_Previews: PreviewProvider {
    static var previews: some View {
        NamePickerPreview()
    }
}
