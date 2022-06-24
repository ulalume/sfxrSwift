/**
 Copyright (c) 2007 Tomas Pettersson
               2016 Yohei Yoshihara
 
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
import AudioToolbox
import AVFoundation

func rnd(_ range: Int) -> Int {
  return Int(arc4random_uniform(UInt32(range) + 1))
}

func frnd(_ range: Float) -> Float {
  return Float.random(in: 0...range)
}

class SFXRPlayer {
  private let wavBits: Int = 16
  private let wavFreq: Int = 44100
  
  private var p = SFXRParams()
  
  var parameters: SFXRParams {
    get {
      return self.p
    }
    set {
      self.p = newValue
    }
  }
  
  private var playingSample = false {
    didSet {
      if (!oldValue && playingSample) {
        ioUnit.outputProvider = { (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
          timestamp: UnsafePointer<AudioTimeStamp>,
          frameCount: AUAudioFrameCount,
          busIndex: Int,
          rawBufferList: UnsafeMutablePointer<AudioBufferList>) -> AUAudioUnitStatus in
          
          let bufferList = UnsafeMutableAudioBufferListPointer(rawBufferList)
          if bufferList.count > 0 {
            let nframes = Int(bufferList[0].mDataByteSize) / MemoryLayout<Int16>.size
            if var ptr = bufferList[0].mData?.bindMemory(to: Int16.self, capacity: nframes) {
              if self.playingSample && !self.muteStream {
                _ = self.synthSample(pointer: ptr, numberOfFrames: nframes)
              }
              else {
                for _ in 0 ..< nframes {
                  ptr.pointee = Int16(0)
                  ptr = ptr.successor()
                }
              }
            }
          }
          return noErr
        }
      }else if (oldValue && !playingSample) {
        ioUnit.outputProvider = nil
      }
    }
  }
  
  var soundVol: Float = 0.5
  var masterVol: Float = 0.05
  
  private var phase: Int = 0
  private var fperiod: Double = 0.0
  private var fmaxperiod: Double = 0.0
  private var fslide: Double = 0.0
  private var fdslide: Double = 0.0
  private var period: Int = 0
  private var squareDuty: Float = 0.0
  private var squareSlide: Float = 0.0
  private var envStage: Int = 0
  private var envTime: Int = 0
  private var envLength: [Int] = [0, 0, 0]
  private var envVol: Float = 0.0
  private var fphase: Float = 0.0
  private var fdphase: Float = 0.0
  private var iphase: Int = 0
  private var phaserBuffer = [Float](repeating: 0.0, count: 1024)
  private var ipp: Int = 0
  private var noiseBuffer = [Float](repeating: 0.0, count: 32)
  private var fltp: Float = 0.0
  private var fltdp: Float = 0.0
  private var fltw: Float = 0.0
  private var fltwD: Float = 0.0
  private var fltdmp: Float = 0.0
  private var fltphp: Float = 0.0
  private var flthp: Float = 0.0
  private var flthpD: Float = 0.0
  private var vibPhase: Float = 0.0
  private var vibSpeed: Float = 0.0
  private var vibAmp: Float = 0.0
  private var repTime: Int = 0
  private var repLimit: Int = 0
  private var arpTime: Int = 0
  private var arpLimit: Int = 0
  private var arpMod: Double = 0.0
  
  private var filesample: Float = 0.0
  private var fileacc: Int = 0
  
  private var muteStream: Bool = false
  
  private var ioUnit: AUAudioUnit
  
  init() {
    let description = AudioComponentDescription(componentType: kAudioUnitType_Output,
                                               componentSubType: kAudioUnitSubType_HALOutput,
                                               componentManufacturer: kAudioUnitManufacturer_Apple,
                                               componentFlags: 0,
                                               componentFlagsMask: 0)
    
    let ioUnit = try! AUAudioUnit(componentDescription: description,
                                  options: AudioComponentInstantiationOptions())
    let renderFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 44100.0, channels: 1, interleaved: false)!
    try! ioUnit.inputBusses[0].setFormat(renderFormat)
    
    try! ioUnit.allocateRenderResources()
    try! ioUnit.startHardware()
    
    self.ioUnit = ioUnit
  }
  
  func resetSample(restart: Bool) {
    if !restart {
      phase = 0
    }
    fperiod = 100.0 / (Double(p.baseFreq) * Double(p.baseFreq) + 0.001)
    period = Int(fperiod)
    fmaxperiod = 100.0 / (Double(p.freqLimit) * Double(p.freqLimit) + 0.001)
    fslide = 1.0 - pow(Double(p.freqRamp), 3.0) * 0.01
    fdslide = -pow(Double(p.freqDramp), 3.0) * 0.000001
    squareDuty = 0.5 - p.duty * 0.5
    squareSlide = -p.dutyRamp * 0.00005
    if p.arpMod >= 0.0 {
      arpMod = 1.0 - pow(Double(p.arpMod), 2.0) * 0.9
    } else {
      arpMod = 1.0 + pow(Double(p.arpMod), 2.0) * 10.0
    }
    arpTime = 0
    arpLimit = Int(pow(1.0 - p.arpSpeed, 2.0) * 20000 + 32)
    if p.arpSpeed == 1.0 {
      arpLimit = 0
    }
    if !restart {
      // reset filter
      fltp = 0.0
      fltdp = 0.0
      fltw = pow(p.lpfFreq, 3.0) * 0.1
      fltwD = 1.0 + p.lpfRamp * 0.0001
      fltdmp = 5.0 / (1.0 + pow(p.lpfResonance, 2.0) * 20.0) * (0.01 + fltw)
      if fltdmp > 0.8 {
        fltdmp = 0.8
      }
      fltphp = 0.0
      flthp = pow(p.hpfFreq, 2.0) * 0.1
      flthpD = 1.0 + p.hpfRamp * 0.0003
      // reset vibrato
      vibPhase = 0.0
      vibSpeed = pow(p.vibSpeed, 2.0) * 0.01
      vibAmp = p.vibStrength * 0.5
      // reset envelope
      envVol = 0.0
      envStage = 0
      envTime = 0
      // to avoid "divide by zero", add max(1, ...)
      envLength[0] = max(1, Int(p.envAttack * p.envAttack * 100000.0))
      envLength[1] = max(1, Int(p.envSustain * p.envSustain * 100000.0))
      envLength[2] = max(1, Int(p.envDecay * p.envDecay * 100000.0))
      
      fphase = pow(p.phaOffset, 2.0) * 1020.0
      if p.phaOffset < 0.0 {
        fphase = -fphase
      }
      fdphase = pow(p.phaRamp, 2.0) * 1.0
      if p.phaRamp < 0.0 {
        fdphase = -fdphase
      }
      iphase = abs(Int(fphase))
      ipp = 0
      for i in 0 ..< phaserBuffer.count {
        phaserBuffer[i] = 0.0
      }
      
      for i in 0 ..< noiseBuffer.count {
        noiseBuffer[i] = frnd(2.0) - 1.0
      }
      
      repTime = 0
      repLimit = Int(pow(1.0 - p.repeatSpeed, 2.0) * 20000 + 32)
      if p.repeatSpeed == 0.0 {
        repLimit = 0
      }
    }
  }
  
  func playSample() {
    playingSample = false
    resetSample(restart: false)
    playingSample = true
  }
  
  func synthSample(pointer _ptr: UnsafeMutablePointer<Int16>, numberOfFrames nframes: Int, exportWave: Bool = false) -> Int {
    var ptr = _ptr
    
    var framesWritten = 0
    for _ in 0 ..< nframes {
      if !playingSample {
        break
      }
      
      repTime += 1
      if repLimit != 0 && repTime >= repLimit {
        repTime = 0
        resetSample(restart: true)
      }
      
      // frequency envelopes/arpeggios
      arpTime += 1
      if arpLimit != 0 && arpTime >= arpLimit {
        arpLimit = 0
        fperiod *= arpMod
      }
      fslide += fdslide
      fperiod *= fslide
      if fperiod > fmaxperiod {
        fperiod = fmaxperiod
        if p.freqLimit > 0.0 {
          playingSample = false
        }
      }
      var rfperiod = fperiod
      if vibAmp > 0.0 {
        vibPhase += vibSpeed
        rfperiod = fperiod * Double(1.0 + sin(vibPhase) * vibAmp)
      }
      period = Int(rfperiod)
      if period < 8 {
        period = 8
      }
      squareDuty += squareSlide
      if squareDuty < 0.0 {
        squareDuty = 0.0
      }
      if squareDuty > 0.5 {
        squareDuty = 0.5
      }
      // volume envelope
      envTime += 1
      if envTime > envLength[envStage] {
        envTime = 0
        envStage += 1
        if envStage == 3 {
          playingSample = false
        }
      }
      if envStage == 0 {
        envVol = Float(envTime) / Float(envLength[0])
      }
      if envStage == 1 {
        envVol = 1.0 + pow(1.0 - Float(envTime) / Float(envLength[1]), 1.0) * 2.0 * p.envPunch
      }
      if envStage == 2 {
        envVol = 1.0 - Float(envTime) / Float(envLength[2])
      }
      
      // phaser step
      fphase += fdphase
      iphase = abs(Int(fphase))
      if iphase > 1023 {
        iphase = 1023
      }
      
      if flthpD != 0.0 {
        flthp *= flthpD
        if flthp < 0.00001 {
          flthp = 0.00001
        }
        if flthp > 0.1 {
          flthp = 0.1
        }
      }
      
      var ssample: Float = 0.0
      for _ in 0 ..< 8 { // 8x supersampling
        var sample: Float = 0.0
        phase += 1
        if phase >= period {
          //        phase=0;
          phase %= period
          if p.waveType == .noise {
            for i in 0 ..< 32 {
              noiseBuffer[i] = frnd(2.0) - 1.0
            }
          }
        }
        // base waveform
        let fp = Float(phase) / Float(period)
        switch p.waveType {
        case .square: // square
          if fp < squareDuty {
            sample = 0.5
          } else {
            sample = -0.5
          }
        case .sawtooth: // sawtooth
          sample = 1.0 - fp * 2.0
        case .sine: // sine
          sample = sin(fp * 2.0 * Float.pi)
        case .noise: // noise
          sample = noiseBuffer[phase * 32 / period]
        }
        // lp filter
        let pp = fltp
        fltw *= fltwD
        if fltw < 0.0 {
          fltw = 0.0
        }
        if fltw > 0.1 {
          fltw = 0.1
        }
        if p.lpfFreq != 1.0 {
          fltdp += (sample - fltp) * fltw
          fltdp -= fltdp * fltdmp
        }
        else {
          fltp = sample
          fltdp = 0.0
        }
        fltp += fltdp
        // hp filter
        fltphp += fltp - pp
        fltphp -= fltphp * flthp
        sample = fltphp
        // phaser
        phaserBuffer[ipp & 1023] = sample
        sample += phaserBuffer[(ipp - iphase + 1024) & 1023];
        ipp = (ipp + 1) & 1023
        // final accumulation and envelope application
        ssample += sample * envVol
      }
      ssample = ssample / 8 * masterVol
      
      ssample *= 2.0 * soundVol
      
      if !exportWave {
        if ssample > 1.0 {
          ssample = 1.0
        }
        if ssample < -1.0 {
          ssample = -1.0
        }
        ptr.pointee = Int16(ssample * 32000.0)
      }
      else {
        // quantize depending on format
        // accumulate/count to accomodate variable sample rate?
        ssample *= 4.0 // arbitrary gain to get reasonable output volume...
        if ssample > 1.0 {
          ssample = 1.0
        }
        if ssample < -1.0 {
          ssample = -1.0
        }
        filesample += ssample
        fileacc += 1
        if wavFreq == 44100 || fileacc == 2 {
          filesample /= Float(fileacc)
          fileacc = 0
          if wavBits == 16 {
            let isample = Int16(filesample * 32000)
            ptr.pointee = isample
          } else {
            //            unsigned char isample = (unsigned char)(filesample * 127 + 128);
            //            fwrite(&isample, 1, 1, file);
          }
          filesample = 0.0
        }
      }
      ptr = ptr.successor()
      framesWritten += 1
    }
    return framesWritten
  }
  
  func exportWAV() -> Data {
    let bdata = BinaryData()
    bdata.append("RIFF")
    bdata.append(UInt32(0)) // remaining file size
    bdata.append("WAVE")
    bdata.append("fmt ")
    bdata.append(UInt32(16)) // chunk size
    bdata.append(UInt16(1)) // compression code
    bdata.append(UInt16(1)) // channels
    bdata.append(UInt32(wavFreq)) // sample rate
    bdata.append(UInt32(wavFreq * wavBits / 8)) // bytes/sec
    bdata.append(UInt16(wavBits / 8)) // block align
    bdata.append(UInt16(wavBits)) // bits per sample
    
    bdata.append("data")
    
    bdata.append(UInt32(0)) // chunk size
    
    muteStream = true
    var fileSampleswritten = 0
    filesample = 0.0
    fileacc = 0
    playSample()
    var data = Data(count: 256 * MemoryLayout<Int16>.size)
    while playingSample {
      var framesWritten = 0
      data.withUnsafeMutableBytes { rawMutableBufferPointer in
          let bufferPointer = rawMutableBufferPointer.bindMemory(to: Int16.self)
          if let address = bufferPointer.baseAddress {
              framesWritten = synthSample(pointer: address, numberOfFrames: 256, exportWave: true)
          }
      }
      let nbytes = framesWritten * MemoryLayout<Int16>.size
      for i in 0 ..< nbytes {
        bdata.append(data[i])
      }
      fileSampleswritten += nbytes
    }
    muteStream = false
    
    bdata.setUInt32(UInt32(bdata.data.count - 8), at: 4)
    bdata.setUInt32(UInt32(fileSampleswritten * wavBits / 8), at: 40)
    
    return bdata.data
  }
  
  deinit {
    ioUnit.stopHardware()
  }
}

