//
//  FocusAppearField.swift
//  PickPick
//
//  Created by Ruben Mimoun on 04/05/2025.
//

import Combine
import SwiftUI

struct FocusAppearField: View {
    
    enum FAFEvent {
        case idle
        case onChange(name: String)
        case get(name: String)
        case received
    }
    
    @State var obs: Obs
    
    @FocusState var isFocused: Bool
    
    init(name: String, getNameEvent: PassthroughSubject<FAFEvent, Never>) {
        self._obs = .init(wrappedValue: .init(name: name, getNameEvent: getNameEvent))
    }
    
    var body: some View {
        TextField("Insert here...", text: $obs.name.onChange({ name in
            obs.getNameEvent.send(.onChange(name: name))
        }))
        .focused($isFocused)
        .onAppear {
            isFocused = true
        }
        .onDisappear {
            obs.cancel()
        }
        .onSubmit {
            obs.getNameEvent.send(.get(name: obs.name))
        }
    }
    
    @Observable
    class Obs {
        
        var name: String
        let getNameEvent: PassthroughSubject<FAFEvent, Never>
        var cancellable: AnyCancellable?
        
        init(name: String, getNameEvent: PassthroughSubject<FAFEvent, Never>, cancellable: AnyCancellable? = nil) {
            self.name = name
            self.getNameEvent = getNameEvent
            self.cancellable = cancellable
            observeInput()
        }
        
        func observeInput() {
            cancellable = getNameEvent
                .sink(receiveValue: {[weak self] event in
                    guard let self else { return }
                    if case .idle = event {
                        getNameEvent.send(.get(name: name))
                    }
                })
        }
        
        func cancel() {
            cancellable?.cancel()
        }
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}
