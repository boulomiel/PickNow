//
//  SelectionNameSheet.swift
//  PickPick
//
//  Created by Ruben Mimoun on 02/05/2025.
//

import SwiftUI
import Combine

enum NameErrors {
    case idle
    case emptyName
    case tooShort
    case nameAlreadyExists
}

struct SelectionNameSheet: View {
    
    @Environment(\.dismiss) var dimiss
    @State private var showTextError: Bool = false
    @State private var nameError: NameErrors = .idle
    @State private var selectedNames: [String] = [""]
    @Namespace private var errorSpace
    
    let getNameEvent: PassthroughSubject<GetName, Never> = .init()
    let onSelectionDone: ([String]) -> Void
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(selectedNames, id: \.self) { name in
                    nameCell(name)
                }
                .onDelete { indexSet in
                    selectedNames.remove(atOffsets: indexSet)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        getNameEvent.send(.idle)
                    } label: {
                        SystemImage(systemName: "plus")
                    }
                }
            }
            .onReceive(getNameEvent, perform: { event in
                guard nameError == .idle else { return }
                if case let .get(name: name) =  event {
                    selectedNames[selectedNames.count-1] = name
                    onAddingNameTapped()
                }
            })
            .overlay(alignment: .bottom) {
                if nameError == .idle {
                    if selectedNames.count > 2 {
                        validateNamesButton
                    }
                } else {
                    errorPopup
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    var validateNamesButton: some View {
        Button {
            dimiss.callAsFunction()
            onSelectionDone(selectedNames)
        } label: {
            Label {
                Text("Let's go").appFontStyle()
            } icon: {
                SystemImage(systemName: "checkmark")
            }
        }
    }
    
    @ViewBuilder
    func nameCell(_ name: String) -> some View {
        Group {
            if name == selectedNames.last {
                FocusAppearField(name: "", getNameEvent: getNameEvent)
            } else {
                Text(name)
                    .foregroundStyle(.gray)
            }
        }
        .deleteDisabled(selectedNames.count < 2 || name == selectedNames.last)
    }
    
    @ViewBuilder
    var errorPopup: some View {
        GeometryReader { geo in
            let size = geo.size
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue)
                .frame(width: nameError == .idle ? 0 : size.width * 0.8, height:  nameError == .idle ? 0 : 60)
                .overlay {
                    Group {
                        switch nameError {
                        case .idle:
                            EmptyView()
                        case .tooShort:
                            Text("Oops! The name is too short.")
                        case .emptyName:
                            Text("Oops! Can't add an empty name.")
                        case .nameAlreadyExists:
                            Text("Oops! This name is already in the list.")
                        }
                    }
                    .appFontStyle()
                    .frame(width: nameError == .idle ? 0 : size.width * 0.8, height: nameError == .idle ? 0 : 60)
                    .opacity(showTextError ? 1 : 0)
                }
                .matchedGeometryEffect(id: "error", in: errorSpace)
                .position(x: size.width * 0.5, y: size.height * 0.5)
        }
        .frame(height: 60)
    }
        
    func onAddingNameTapped() {
        guard !selectedNames.isEmpty else { return }
        guard let (offset, name) = Array(selectedNames.enumerated()).last else { return }
        guard !name.isEmpty, name.count >= 2 else {
            toggleError(error: .tooShort)
            return
        }
        var set = Set(selectedNames.dropLast())
        let (inserted, _) = set.insert(name)
        guard inserted else {
            withAnimation {
                selectedNames[offset] = ""
            }
            toggleError(error: .nameAlreadyExists)
            return
        }
        selectedNames.append("")
    }
    
    func toggleError(error: NameErrors) {
        withAnimation {
            self.nameError = error
        } completion: {
            withAnimation(.bouncy) {
                showTextError = true
            } completion: {
                withAnimation(.easeOut.delay(0.3)) {
                    showTextError = false
                } completion: {
                    withAnimation {
                        nameError = .idle
                    }
                }
            }
        }
    }
    
    struct FocusAppearField: View {
        
        @State var name: String
        let getNameEvent: PassthroughSubject<GetName, Never>

        @FocusState var isFocused: Bool
        
        init(name: String, getNameEvent: PassthroughSubject<GetName, Never>) {
            self.name = name
            self.getNameEvent = getNameEvent
        }
                
        var body: some View {
            TextField("Insert here...", text: $name)
                .focused($isFocused)
                .onAppear {
                    isFocused = true
                }
                .onSubmit {
                    getNameEvent.send(.get(name: name))
                    name = ""
                    isFocused = false
                }
                .onReceive(getNameEvent) { event in
                    if case .idle = event {
                        getNameEvent.send(.get(name: name))
                    }
                    name = ""
                    isFocused = false
                }
            
        }
    }
    
    enum GetName {
        case idle
        case get(name: String)
    }
}

#Preview {
    SelectionNameSheet { _ in  }
}
