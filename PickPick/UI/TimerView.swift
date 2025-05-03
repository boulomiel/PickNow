//
//  TimerView.swift
//  PickPick
//
//  Created by Ruben Mimoun on 01/02/2024.
//

import Combine
import SwiftUI

struct TimerView: View {
    
    let observer: TimerObserver
    @State var time: String
    let isButtonEnabled: Bool
    
    init(observer: TimerObserver, isButtonEnabled: Bool) {
        self.observer = observer
        self._time = .init(initialValue: "PICK")
        self.isButtonEnabled = isButtonEnabled
    }
    
    var body: some View {
        Button(action: {
            observer.startTimer()
        }, label: {
            Text(time)
                .padding()
                .frame(width: 80, height: 40)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.2))
                }
        })
        .disabled(!isButtonEnabled)
        .appFontStyle()
        .keyframeAnimator(initialValue: AnimationProperties(),
                          trigger: time,
                          content: {content, value in
            content.scaleEffect(value.scale)
        } , keyframes: { _  in
            KeyframeTrack(\.scale) {
                SpringKeyframe(1.3, duration: 0.1)
                SpringKeyframe(0.0, duration: 0.1)
                
            }
        })
        .onReceive(observer.timerState, perform: { state in
            switch state {
            case .update(let value):
                time = observer.numberFormatter.string(from: NSNumber(value: value))!
            case .finished:
                time = "💣"
            case .idle:
                time = "PICK"
            case .started:
                break
            }
        })
    }
    
    enum TimerState {
        case update(Double)
        case finished
        case idle
        case started
    }
    
    @Observable
    final class TimerObserver {
        
        private var timeValue: Double
        private var observer = Timer.publish(every: 1.0, on: .current, in: .default).autoconnect()
        private var subscriptions: Set<AnyCancellable> = .init()
        
        var timerState: PassthroughSubject<TimerState, Never>
        var numberFormatter: NumberFormatter {
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.maximumFractionDigits = 2
            return f
        }
        
        init(timerState: PassthroughSubject<TimerState, Never>) {
            self.timeValue = 3.0
            self.timerState = timerState
        }
        
        func startTimer() {
            observer.sink(receiveValue: {[weak self] _ in
                self?.updateTimer()
            })
            .store(in: &subscriptions)
        }
        
        func endTimer() {
            observer.upstream.connect().cancel()
        }
        
        func updateTimer() {
            if timeValue <= 0 {
                timerState.send(.finished)
                endTimer()
            } else {
                timeValue -= 1
                timerState.send(.update(timeValue))
            }
        }
    }
    
    struct AnimationProperties {
        var scale: Double = 1.0
    }
}

#Preview {
    ZStack {
        Color.black
        TimerView(observer: .init(timerState: .init()), isButtonEnabled: true)
    }
    .ignoresSafeArea()
}
