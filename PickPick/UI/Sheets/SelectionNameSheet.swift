//
//  SelectionNameSheet.swift
//  PickPick
//
//  Created by Ruben Mimoun on 02/05/2025.
//

import SwiftUI
import Combine
import NaturalLanguage

struct SelectionNameSheet: View {
    
    @Observable
    class Obs {
        var cellObs: [SelectionNameCell.Obs]
        var nameError: NameErrors = .idle
        var showTextError: Bool = false
        let languageRecognizer: NLLanguageRecognizer = .init()
        let getNameEvent: PassthroughSubject<FocusAppearField.FAFEvent, Never> = .init()
        
        init() {
            cellObs = [
                .init(name: "", isLast: true, getNameEvent: getNameEvent),
            ]
        }
        
        private var cancellable: AnyCancellable?
        
        
        func onAddingNameTapped() {
            guard !cellObs.isEmpty else { return }
            guard let (offset, cellOb) = Array(cellObs.enumerated()).last else { return }
            let name = cellOb.name
            guard !name.isEmpty, name.count >= 2 else {
                toggleError(error: .tooShort)
                return
            }
            var set = Set(cellObs.map(\.name).dropLast())
            let (inserted, _) = set.insert(name)
            guard inserted else {
                withAnimation {
                    cellObs[offset].name = ""
                }
                toggleError(error: .nameAlreadyExists)
                return
            }
            cellObs[offset].isLast = false
            cellObs.append(.init(name: "", isLast: true, getNameEvent: getNameEvent))
            getNameEvent.send(.received)
        }
        
        func resetObs(with list: [String]) {
            cellObs = list.map { name in
                SelectionNameCell.Obs(name: name, isLast: false, getNameEvent: getNameEvent)
            }
            cellObs.append(.init(name: "", isLast: true, getNameEvent: getNameEvent))
        }
        
        func toggleError(error: NameErrors) {
            withAnimation {
                self.nameError = error
            } completion: {
                withAnimation(.bouncy) {
                    self.showTextError = true
                } completion: {
                    withAnimation(.easeOut.delay(0.3)) {
                        self.showTextError = false
                    } completion: {
                        withAnimation {
                            self.nameError = .idle
                        }
                    }
                }
            }
        }
    }
    
    let obs: Obs = .init()
    @Environment(\.dismiss) var dimiss
    let onSelectionDone: ([String]) -> Void
    @AppStorage("lastList") var lastList: Data?

    var body: some View {
        NavigationStack {
            List {
                ForEach(obs.cellObs, id: \.id) { cellOb in
                    SelectionNameCell(obs: cellOb)
                        .deleteDisabled(obs.cellObs.count < 2 || cellOb === obs.cellObs.last)
                }
                .onDelete { indexSet in
                    obs.cellObs.remove(atOffsets: indexSet)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        TransitionView(transition: .scale, when: self.lastList != nil) {
                            Button {
                                let selected = Storage.loadStringArray(data: lastList!)
                                obs.resetObs(with: selected)
                            } label: {
                                SystemImage(systemName: "arrow.counterclockwise")
                            }
                        }
                        
                        Button {
                            obs.getNameEvent.send(.idle)
                        } label: {
                            SystemImage(systemName: "plus")
                        }
                    }
                }
            }
            .onReceive(obs.getNameEvent, perform: { event in
                guard obs.nameError == .idle else { return }
                if case let .get(name: name) =  event {
                    obs.cellObs[obs.cellObs.count-1].name = name
                    obs.onAddingNameTapped()
                }
            })
            .overlay(alignment: .bottom) {
                if obs.nameError == .idle {
                    if obs.cellObs.count > 2 {
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
            let selected = obs.cellObs.map(\.name).filter { !$0.isEmpty }
            lastList = Storage.archiveStringArray(object: selected)
            onSelectionDone(obs.cellObs.map(\.name).filter { !$0.isEmpty })
        } label: {
            Label {
                Text("Let's go").appFontStyle()
            } icon: {
                SystemImage(systemName: "checkmark")
            }
        }
    }
    
    @ViewBuilder
    var errorPopup: some View {
        GeometryReader { geo in
            let size = geo.size
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue)
                .frame(width: obs.nameError == .idle ? 0 : size.width * 0.8, height:  obs.nameError == .idle ? 0 : 60)
                .overlay {
                    Group {
                        switch obs.nameError {
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
                    .frame(width: obs.nameError == .idle ? 0 : size.width * 0.8, height: obs.nameError == .idle ? 0 : 60)
                    .opacity(obs.showTextError ? 1 : 0)
                }
                .position(x: size.width * 0.5, y: size.height * 0.5)
        }
        .frame(height: 60)
    }
}

class Storage: NSObject {
    
    static func archiveStringArray(object : [String]) -> Data {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)
            return data
        } catch {
            fatalError("Can't encode data: \(error)")
        }

    }

    static func loadStringArray(data: Data) -> [String] {
        do {
            guard let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String] else {
                return []
            }
            return array
        } catch {
            fatalError("loadWStringArray - Can't encode data: \(error)")
        }
    }
}

extension NLLanguage {
    var isRightToLeft: Bool {
        switch self {
        case .hebrew, .arabic, .persian, .urdu:
            true
        default:
            false
        }
    }
}

#Preview {
    SelectionNameSheet{_ in}
}
