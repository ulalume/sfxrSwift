/**
 Copyright (c) 2007 Tomas Pettersson
               2016 Yohei Yoshihara
               2022 Tetsuo Kubota

 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

enum GeneratorType: Int, CaseIterable {
  case pickupCoin = 0
  case laserShoot
  case explosion
  case powerup
  case hitHurt
  case jump
  case blipSelect
}

class SFXRGenerator {
  
  class func mutate(params: SFXRParams) -> SFXRParams {
    var p = params
    if Bool.random() {
      p.baseFreq += frnd(0.1) - 0.05
    }
    //    if Bool.random() { p.freqLimit += frnd(0.1) - 0.05 }
    if Bool.random() {
      p.freqRamp += frnd(0.1) - 0.05
    }
    if Bool.random() {
      p.freqDramp += frnd(0.1) - 0.05
    }
    if Bool.random() {
      p.duty += frnd(0.1) - 0.05
    }
    if Bool.random() {
      p.dutyRamp += frnd(0.1) - 0.05
    }
    if Bool.random() {
      p.vibStrength += frnd(0.1) - 0.05
    }
    if Bool.random() {
      p.vibSpeed += frnd(0.1) - 0.05
    }
    if Bool.random() {
      p.vibDelay += frnd(0.1) - 0.05
    }
    if Bool.random() {
      p.envAttack += frnd(0.1) - 0.05
    }
    if Bool.random() {
      p.envSustain += frnd(0.1) - 0.05
    }
    if Bool.random() {
      p.envDecay += frnd(0.1) - 0.05
    }
    if Bool.random() {
      p.envPunch += frnd(0.1) - 0.05
    }
    if Bool.random() {
      p.lpfResonance += frnd(0.1) - 0.05
    }
    if Bool.random() {
      p.lpfFreq += frnd(0.1) - 0.05
    }
    if Bool.random() {
      p.lpfRamp += frnd(0.1) - 0.05
    }
    if Bool.random() {
      p.hpfFreq += frnd(0.1) - 0.05
    }
    if Bool.random() {
      p.hpfRamp += frnd(0.1) - 0.05
    }
    if Bool.random() {
      p.phaOffset += frnd(0.1) - 0.05
    }
    if Bool.random() {
      p.phaRamp += frnd(0.1) - 0.05
    }
    if Bool.random() {
      p.repeatSpeed += frnd(0.1) - 0.05
    }
    if Bool.random() {
      p.arpSpeed += frnd(0.1) - 0.05
    }
    if Bool.random() {
      p.arpMod += frnd(0.1) - 0.05
    }
    return p
  }
  
  class func random(waveType: SFXRParams.WaveType?) -> SFXRParams {
    var p = SFXRParams()
    p.waveType = waveType ?? SFXRParams.WaveType.allCases.randomElement()!
    p.baseFreq = pow(frnd(2.0) - 1.0, 2.0)
    if Bool.random() {
      p.baseFreq = pow(frnd(2.0) - 1.0, 3.0) + 0.5
    }
    p.freqLimit = 0.0
    p.freqRamp = pow(frnd(2.0) - 1.0, 5.0)
    if p.baseFreq > 0.7 && p.freqRamp > 0.2 {
      p.freqRamp = -p.freqRamp
    }
    if p.baseFreq < 0.2 && p.freqRamp < -0.05 {
      p.freqRamp = -p.freqRamp
    }
    p.freqDramp = pow(frnd(2.0) - 1.0, 3.0)
    p.duty = frnd(2.0) - 1.0
    p.dutyRamp = pow(frnd(2.0) - 1.0, 3.0)
    
    p.vibStrength = pow(frnd(2.0) - 1.0, 3.0)
    p.vibSpeed = frnd(2.0) - 1.0
    p.vibDelay = frnd(2.0) - 1.0
    
    p.envAttack = pow(frnd(2.0) - 1.0, 3.0)
    p.envSustain = pow(frnd(2.0) - 1.0, 2.0)
    p.envDecay = frnd(2.0) - 1.0
    p.envPunch = pow(frnd(0.8), 2.0)
    if p.envAttack + p.envSustain + p.envDecay < 0.2 {
      p.envSustain += 0.2 + frnd(0.3)
      p.envDecay += 0.2 + frnd(0.3)
    }
    
    p.lpfResonance = frnd(2.0) - 1.0
    p.lpfFreq = 1.0 - pow(frnd(1.0), 3.0)
    p.lpfRamp = pow(frnd(2.0) - 1.0, 3.0)
    if p.lpfFreq < 0.1 && p.lpfRamp < -0.05 {
      p.lpfRamp = -p.lpfRamp
    }
    p.hpfFreq = pow(frnd(1.0), 5.0)
    p.hpfRamp = pow(frnd(2.0) - 1.0, 5.0)
    
    p.phaOffset = pow(frnd(2.0) - 1.0, 3.0)
    p.phaRamp = pow(frnd(2.0) - 1.0, 3.0)
    
    p.repeatSpeed = frnd(2.0) - 1.0
    
    p.arpSpeed = frnd(2.0) - 1.0
    p.arpMod = frnd(2.0) - 1.0
    return p
  }
  
  class func generate(generator: GeneratorType) -> SFXRParams {
    var p = SFXRParams()
    switch generator {
    case .pickupCoin:
      p.baseFreq = 0.4 + frnd(0.5)
      p.envAttack = 0.0
      p.envSustain = frnd(0.1)
      p.envDecay = 0.1 + frnd(0.4)
      p.envPunch = 0.3 + frnd(0.3)
      if Bool.random() {
        p.arpSpeed = 0.5 + frnd(0.2)
        p.arpMod = 0.2 + frnd(0.4)
      }
    case .laserShoot:
      p.waveType = SFXRParams.WaveType(rawValue: rnd(2))!
      if p.waveType == .sine && Bool.random() {
        p.waveType = SFXRParams.WaveType(rawValue: rnd(1))!
      }
      p.baseFreq = 0.5 + frnd(0.5)
      p.freqLimit = p.baseFreq - 0.2 - frnd(0.6)
      if p.freqLimit < 0.2 {
        p.freqLimit = 0.2
      }
      p.freqRamp = -0.15 - frnd(0.2)
      if rnd(2) == 0 {
        p.baseFreq = 0.3 + frnd(0.6)
        p.freqLimit = frnd(0.1)
        p.freqRamp = -0.35 - frnd(0.3)
      }
      if Bool.random() {
        p.duty = frnd(0.5)
        p.dutyRamp = frnd(0.2)
      } else {
        p.duty = 0.4 + frnd(0.5)
        p.dutyRamp = -frnd(0.7)
      }
      p.envAttack = 0.0
      p.envSustain = 0.1 + frnd(0.2)
      p.envDecay = frnd(0.4)
      if Bool.random() {
        p.envPunch = frnd(0.3)
      }
      if rnd(2) == 0 {
        p.phaOffset = frnd(0.2)
        p.phaRamp = -frnd(0.2)
      }
      if Bool.random() {
        p.hpfFreq = frnd(0.3)
      }
    case .explosion:
      p.waveType = .noise
      if Bool.random() {
        p.baseFreq = 0.1 + frnd(0.4)
        p.freqRamp = -0.1 + frnd(0.4)
      } else {
        p.baseFreq = 0.2 + frnd(0.7)
        p.freqRamp = -0.2 - frnd(0.2)
      }
      p.baseFreq *= p.baseFreq
      if rnd(4) == 0 {
        p.freqRamp = 0.0
      }
      if rnd(2) == 0 {
        p.repeatSpeed = 0.3 + frnd(0.5)
      }
      p.envAttack = 0.0
      p.envSustain = 0.1 + frnd(0.3)
      p.envDecay = frnd(0.5)
      if rnd(1) == 0 {
        p.phaOffset = -0.3 + frnd(0.9)
        p.phaRamp = -frnd(0.3)
      }
      p.envPunch = 0.2 + frnd(0.6)
      if Bool.random() {
        p.vibStrength = frnd(0.7)
        p.vibSpeed = frnd(0.6)
      }
      if rnd(2) == 0 {
        p.arpSpeed = 0.6 + frnd(0.3)
        p.arpMod = 0.8 - frnd(1.6)
      }
    case .powerup:
      if Bool.random() {
        p.waveType = .sawtooth
      } else {
        p.duty = frnd(0.6)
      }
      if Bool.random() {
        p.baseFreq = 0.2 + frnd(0.3)
        p.freqRamp = 0.1 + frnd(0.4)
        p.repeatSpeed = 0.4 + frnd(0.4)
      } else {
        p.baseFreq = 0.2 + frnd(0.3)
        p.freqRamp = 0.05 + frnd(0.2)
        if Bool.random() {
          p.vibStrength = frnd(0.7)
          p.vibSpeed = frnd(0.6)
        }
      }
      p.envAttack = 0.0
      p.envSustain = frnd(0.4)
      p.envDecay = 0.1 + frnd(0.4)
    case .hitHurt:
      p.waveType = SFXRParams.WaveType(rawValue: rnd(2))!
      if p.waveType == .sine {
        p.waveType = .noise
      }
      if p.waveType == .square {
        p.duty = frnd(0.6)
      }
      p.baseFreq = 0.2 + frnd(0.6)
      p.freqRamp = -0.3 - frnd(0.4)
      p.envAttack = 0.0
      p.envSustain = frnd(0.1)
      p.envDecay = 0.1 + frnd(0.2)
      if Bool.random() {
        p.hpfFreq=frnd(0.3)
      }
    case .jump:
      p.waveType = .square
      p.duty = frnd(0.6)
      p.baseFreq = 0.3 + frnd(0.3)
      p.freqRamp = 0.1 + frnd(0.2)
      p.envAttack = 0.0
      p.envSustain = 0.1 + frnd(0.3)
      p.envDecay = 0.1 + frnd(0.2)
      if Bool.random() {
        p.hpfFreq = frnd(0.3)
      }
      if Bool.random() {
        p.lpfFreq = 1.0 - frnd(0.6)
      }
    case .blipSelect:
      p.waveType = SFXRParams.WaveType(rawValue: rnd(1))!
      if p.waveType == .square {
        p.duty = frnd(0.6)
      }
      p.baseFreq = 0.2 + frnd(0.4)
      p.envAttack = 0.0
      p.envSustain = 0.1 + frnd(0.1)
      p.envDecay = frnd(0.2)
      p.hpfFreq = 0.1
    }
    return p
  }
}
