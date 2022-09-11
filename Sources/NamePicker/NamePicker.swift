import SwiftUI
import SwiftUISugar
import SwiftUIFlowLayout

public struct NamePicker: View {
//    @EnvironmentObject var diaryController: DiaryView.Controller
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool?
    @Binding var name: String
    
    var recentStrings: [String]
    var presetStrings: [String]
    
    public init(name: Binding<String>, recentStrings: [String] = [], presetStrings: [String]) {
        _name = name
        self.recentStrings = recentStrings
        self.presetStrings = presetStrings
    }
}

extension NamePicker {
    public var body: some View {
        scrollView
            .navigationTitle("Name")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    var scrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                textField
                recents
                presets
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    var textField: some View {
        TextField("", text: $name)
            .focused($isFocused, equals: true)
            .submitLabel(.done)
            .onSubmit {
                dismiss()
            }
            .formElementStyle()
    }
    
    var recents: some View {
        Group {
            if !recentStrings.isEmpty {
                Text("Frequently Used")
                    .formSectionHeaderStyle()
                FlowLayout(mode: .scrollable, items: recentStrings, itemSpacing: 4) {
                    button(forSuggestion: $0)
                }
                .formElementStyle()
            }
        }
    }
    
    var presets: some View {
        Group {
            Text("Presets")
                .formSectionHeaderStyle()
            FlowLayout(mode: .scrollable, items: presetStrings, itemSpacing: 4) {
                button(forSuggestion: $0)
            }
            .formElementStyle()
        }
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
