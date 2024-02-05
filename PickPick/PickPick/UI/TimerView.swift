//
//  TimerView.swift
//  PickPick
//
//  Created by Ruben Mimoun on 01/02/2024.
//

import Combine
import SwiftUI

enum TimerState {
    case idle, started, update(Double), finished
}

struct TimerView: View {
    
    let observer: TimerObserver
    @State var isButtonEnabled: Bool
    
    init(observer: TimerObserver = .init(timerState: .init()), isButtonEnabled: Bool = true) {
        self.observer = observer
        self._isButtonEnabled = .init(initialValue: isButtonEnabled)
    }
    
    var body: some View {
        ZStack {
            Button(action: {
                observer.startTimer()
            }, label: {
                Text(observer.time)
                    .padding(EdgeInsets(top: 18, leading: 18, bottom: 12, trailing: 18))
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white.opacity(0.1))
                    }
            })
            .appFontStyle()
            .keyframeAnimator(initialValue: AnimationProperties(),
                              trigger: observer.time,
                              content: {content, value in
                content.scaleEffect(value.scale)
            } , keyframes: { _  in
                KeyframeTrack(\.scale) {
                    SpringKeyframe(1.6, duration: 0.2)
                    SpringKeyframe(0.0, duration: 0.1)
                    
                }
            })
            .disabled(!isButtonEnabled)
        }
        .onReceive(observer.timerState, perform: { state in
            switch state {
            case .idle, .finished:
                isButtonEnabled = true
            case .started:
                isButtonEnabled = false
            default:
                break
            }
        })
        .frame(width: 100, height: 60)
        
    }
    
    @Observable
    final class TimerObserver {
        
        var time: String
        var timerState: PassthroughSubject<TimerState, Never>
        
        private var timeValue: Double {
            didSet {
                time = timeValue == 0 ? "💣" : numberFormatter.string(from: NSNumber(value: timeValue))!
            }
        }
        private var numberFormatter: NumberFormatter {
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.maximumFractionDigits = 2
            return f
        }
        private var observer = Timer.publish(every: 1.0, on: .current, in: .default).autoconnect()
        private var subscriptions: Set<AnyCancellable> = .init()
        
        init(time: String = "PICK", timerState: PassthroughSubject<TimerState, Never>) {
            self.time = time
            self.timeValue = 3.0
            self.timerState = timerState
        }
        
        func startTimer() {
            self.timerState.send(.started)
            observer
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: {[weak self] _ in
                    self?.updateTimer()
                })
                .store(in: &subscriptions)
        }
        
        func endTimer() {
            observer.upstream.connect().cancel()
            timerState.send(.finished)
        }
        
        func updateTimer() {
            if timeValue <= 0 {
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
        TimerView()
    }
}
