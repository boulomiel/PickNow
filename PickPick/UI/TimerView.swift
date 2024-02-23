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
    
    init(observer: TimerObserver = .init()) {
        self.observer = observer
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red)
            
            Text(observer.time)
                .foregroundStyle(.white)
                .fontWeight(.heavy)
                .fontDesign(.rounded)
                .fontWidth(.expanded)
                .keyframeAnimator(initialValue: AnimationProperties(),
                                  trigger: observer.time,
                                  content: {content, value in
                    content.scaleEffect(value.scale)
                } , keyframes: { _  in
                    KeyframeTrack(\.scale) {
                        SpringKeyframe(1.3, duration: 0.1)
                        SpringKeyframe(0.0, duration: 0.1)

                    }
                })
        }
        .frame(width: 100, height: 60)
        .onTapGesture {
            observer.startTimer()
        }
    }
    
    @Observable
    final class TimerObserver {
        
        var time: String
        private var timeValue: Double {
            didSet {
               time = numberFormatter.string(from: NSNumber(value: timeValue)) ?? "0"
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
        
        init(time: String = "5") {
            self.time = time
            self.timeValue = 5.0
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
                endTimer()
            } else {
                timeValue -= 1
            }
        }
    }
    
    struct AnimationProperties {
        var scale: Double = 1.0
    }
}

#Preview {
    TimerView()
}
