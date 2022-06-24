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
