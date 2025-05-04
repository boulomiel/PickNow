//
//  SelectionNameCell.swift
//  PickPick
//
//  Created by Ruben Mimoun on 04/05/2025.
//

import Combine
import SwiftUI
import NaturalLanguage

struct SelectionNameCell: View {
    
    @State var obs: Obs
    
    var body: some View {
        Group {
            if obs.isLast {
                FocusAppearField(name: "", getNameEvent: obs.getNameEvent)
            } else {
                TextField(obs.name, text: .constant(obs.name))
                    .disabled(true)
                    .foregroundStyle(.gray)
                    .onAppear {
                        obs.detectLanguageDirection()
                    }
            }
        }
    }
    
    @Observable
    class Obs: Identifiable {
        
        let id: UUID = .init()
        var name: String
        var isLast: Bool
        let getNameEvent: PassthroughSubject<FocusAppearField.FAFEvent, Never>
        let languageRecognizer: NLLanguageRecognizer
        var isRightToLeft: Bool
        
        private var cancellable: AnyCancellable?
        
        init(name: String, isLast: Bool, getNameEvent: PassthroughSubject<FocusAppearField.FAFEvent, Never>, languageRecognizer: NLLanguageRecognizer = .init()) {
            self.name = name
            self.isLast = isLast
            self.languageRecognizer = languageRecognizer
            self.getNameEvent = getNameEvent
            self.isRightToLeft = false
            observeInput()
        }
        
        func detectLanguageDirection() {
            detectLanguageDirection(text: name)
        }
        
        func detectLanguageDirection(text: String) {
            languageRecognizer.processString(text)
            if let language = languageRecognizer.dominantLanguage {
            self.isRightToLeft = language.isRightToLeft
            }
        }
        
        private func observeInput() {
            cancellable = getNameEvent
                .compactMap {
                    if case .onChange(name: let name) = $0 {
                        return name
                    } else {
                        return nil
                    }
                }
                .removeDuplicates()
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: {[weak self] name in
                   self?.detectLanguageDirection(text: name)
                })
        }
    }
}
