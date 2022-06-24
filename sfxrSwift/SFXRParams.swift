//
//  Parameters.swift
//  sfxrSwift
//
//  Created by Tetsuo Kubota on 2022/06/24.
//  Copyright © 2022 Yohei Yoshihara. All rights reserved.
//

import Foundation

struct SFXRParams: CustomStringConvertible, Codable {
  enum WaveType: Int, RawRepresentable, CaseIterable, Codable {
    case square = 0
    case sawtooth
    case sine
    case noise
  }
  var waveType: WaveType = .square
  
  var baseFreq: Float = 0.3
  var freqLimit: Float = 0.0
  var freqRamp: Float = 0.0 // bipolar
  var freqDramp: Float = 0.0 // bipolar
  var duty: Float = 0.0
  var dutyRamp: Float = 0.0 // bipolar
  
  var vibStrength: Float = 0.0
  var vibSpeed: Float = 0.0
  var vibDelay: Float = 0.0
  
  var envAttack: Float = 0.0
  var envSustain: Float = 0.3
  var envDecay: Float = 0.4
  var envPunch: Float = 0.0
  
  var filterOn: Bool = false
  var lpfResonance: Float = 0.0
  var lpfFreq: Float = 1.0
  var lpfRamp: Float = 0.0 // bipolar
  var hpfFreq: Float = 0.0
  var hpfRamp: Float = 0.0 // bipolar
  
  var phaOffset: Float = 0.0 // bipolar
  var phaRamp: Float = 0.0 // bipolar
  
  var repeatSpeed: Float = 0.0
  
  var arpSpeed: Float = 0.0
  var arpMod: Float = 0.0 // bipolar
  
  var description: String {
    return "baseFreq=\(baseFreq), freqLimit=\(freqLimit), freqRamp=\(freqRamp), " +
    "freqDramp=\(freqDramp), duty=\(duty), dutyRamp=\(dutyRamp), vibStrength=\(vibStrength), " +
    "vibSpeed=\(vibSpeed), vibDelay=\(vibDelay), envAttack=\(envAttack), envSustain=\(envSustain), " +
    "envDecay=\(envDecay), envPunch=\(envPunch), filterOn=\(filterOn), lpfResonance=\(lpfResonance), " +
    "lpfFreq=\(lpfFreq), lpfRamp=\(lpfRamp), hpfFreq=\(hpfFreq), hpfRamp=\(hpfRamp), " +
    "phaOffset=\(phaOffset), phaRamp=\(phaRamp), repeatSpeed=\(repeatSpeed), arpSpeed=\(arpSpeed), " +
    "arpMod=\(arpMod)"
  }
}
