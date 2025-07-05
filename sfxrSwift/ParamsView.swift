//
//  ParamsView.swift
//  sfxrSwift
//
//  Created by kbt on 2025/07/04.
//  Copyright © 2025 Yohei Yoshihara. All rights reserved.
//

import SwiftUI
import CoreGraphics

struct LabelWidthPreferenceKey: @preconcurrency PreferenceKey {
    @MainActor static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
struct MeasuringText: View {
    var text: String
    
    var body: some View {
        Text(text)
            .fixedSize()
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: LabelWidthPreferenceKey.self, value: proxy.size.width)
                }
            )
    }
}

struct ParamsView: View {
    @Environment(SoundPlayer.self) private var soundPlayer
    @Binding var params: Params
    @State private var labelWidth: CGFloat = 0
    
    func play () {
        let wave = params.sfxrParameters.exportWav()
        soundPlayer.play(data: wave)
    }
    
    @ViewBuilder
    private func sliderRow(label: String, value: Binding<Float>, range: ClosedRange<Float> = 0...1) -> some View {
        HStack {
            MeasuringText(text: label)
                .frame(width: labelWidth, alignment: .leading)
            Slider(value: value, in: range, onEditingChanged: { editing in
                if !editing {
                    play()
                }
            })
        }
    }
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    let binding = Binding<WaveType>(
                        get: { params.sfxrParameters.waveType },
                        set: {
                            newValue in params.sfxrParameters.waveType = newValue
                            play()
                        }
                    )
                    Picker(selection: binding, content: {
                        ForEach(WaveType.allCases, id: \.self) { waveType in
                            Text(waveType.label).tag(waveType)
                        }
                    }, label: {
                        MeasuringText(text: "Wave Type")
                            .frame(width: labelWidth, alignment: .leading)
                    })
                    .pickerStyle(.segmented)
                    
                }
                
                Divider().padding(.vertical)
                
                sliderRow(label: "Attack Time", value: $params.sfxrParameters.envAttack)
                sliderRow(label: "Sustain Punch", value: $params.sfxrParameters.envPunch)
                sliderRow(label: "Sustain Time", value: $params.sfxrParameters.envSustain)
                sliderRow(label: "Decay Time", value: $params.sfxrParameters.envDecay)
             
                Divider().padding(.vertical)
                
                sliderRow(label: "Start Frequency", value: $params.sfxrParameters.baseFreq)
                sliderRow(label: "Min Frequency", value: $params.sfxrParameters.freqLimit)
                sliderRow(label: "Slide", value: $params.sfxrParameters.freqRamp, range: 0...1)
                sliderRow(label: "Delta Slide", value: $params.sfxrParameters.freqDramp, range: 0...1)
                
                Divider().padding(.vertical)
                
                sliderRow(label: "Vibrato Depth", value: $params.sfxrParameters.vibStrength)
                sliderRow(label: "Vibrato Speed", value: $params.sfxrParameters.vibSpeed)
                
                Divider().padding(.vertical)
                
                sliderRow(label: "Change Amount", value: $params.sfxrParameters.arpMod, range: -1...1)
                sliderRow(label: "Change Speed", value: $params.sfxrParameters.arpSpeed)
                
                Divider().padding(.vertical)
                
                sliderRow(label: "Square Duty", value: $params.sfxrParameters.duty)
                sliderRow(label: "Duty Sweep", value: $params.sfxrParameters.dutyRamp, range: -1...1)
                
                Divider().padding(.vertical)
                
                sliderRow(label: "Repeat Speed", value: $params.sfxrParameters.repeatSpeed, range: -1...1)
                
                Divider().padding(.vertical)
                
                sliderRow(label: "Phaser Offset", value: $params.sfxrParameters.phaOffset, range: -1...1)
                sliderRow(label: "Phaser Sweep", value: $params.sfxrParameters.phaRamp, range: -1...1)
                
                
                Divider().padding(.vertical)
                
                sliderRow(label: "Lowpass Filter Cutoff", value: $params.sfxrParameters.lpfFreq)
                sliderRow(label: "Lowpass Filter Cutoff Sweep", value: $params.sfxrParameters.lpfRamp)
                sliderRow(label: "Lowpass Filter Resonance", value: $params.sfxrParameters.lpfResonance)
                sliderRow(label: "Highpass Filter Cutoff", value: $params.sfxrParameters.hpfFreq)
                sliderRow(label: "Highpass Filter Cutoff Sweep", value: $params.sfxrParameters.hpfRamp, range: -1...1)
                
            }
            .padding()
        }
        .onPreferenceChange(LabelWidthPreferenceKey.self) { newWidth in
            labelWidth = newWidth
        }
    }
}

#Preview {
    @Previewable @State var soundPlayer = SoundPlayer()
    @Previewable @State var params = Params(timestamp: Date(), params: .random())
    ParamsView(params: $params)
        .environment(soundPlayer)
}
