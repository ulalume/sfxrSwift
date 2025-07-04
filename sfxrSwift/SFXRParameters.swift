import Foundation
import Observation

enum WaveType: Int, RawRepresentable {
    case square = 0
    case sawtooth = 1
    case sine = 2
    case noise = 3
}

let maxWaveTypeRawValue = WaveType.noise.rawValue

enum GeneratorType: Int, CaseIterable {
    case pickupCoin = 0
    case laserShoot = 1
    case explosion = 2
    case powerup = 3
    case hitHurt = 4
    case jump = 5
    case blipSelect = 6
}

fileprivate func rnd(_ range: Int) -> Int {
    Int.random(in: 0...range)
}
fileprivate func frnd(_ range: Float) -> Float {
    Float.random(in: 0...range)
}

@Observable
class SFXRParameters: CustomStringConvertible {
    var waveType: WaveType = .square
    var soundVol: Float = 0.5
    var masterVol: Float = 0.05
    var baseFreq: Float = 0.3
    var freqLimit: Float = 0.0
    var freqRamp: Float = 0.0
    var freqDramp: Float = 0.0
    var duty: Float = 0.0
    var dutyRamp: Float = 0.0
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
    var lpfRamp: Float = 0.0
    var hpfFreq: Float = 0.0
    var hpfRamp: Float = 0.0
    var phaOffset: Float = 0.0
    var phaRamp: Float = 0.0
    var repeatSpeed: Float = 0.0
    var arpSpeed: Float = 0.0
    var arpMod: Float = 0.0

    func reset() {
        baseFreq = 0.3
        freqLimit = 0.0
        freqRamp = 0.0
        freqDramp = 0.0
        duty = 0.0
        dutyRamp = 0.0
        vibStrength = 0.0
        vibSpeed = 0.0
        vibDelay = 0.0
        envAttack = 0.0
        envSustain = 0.3
        envDecay = 0.4
        envPunch = 0.0
        filterOn = false
        lpfResonance = 0.0
        lpfFreq = 1.0
        lpfRamp = 0.0
        hpfFreq = 0.0
        hpfRamp = 0.0
        phaOffset = 0.0
        phaRamp = 0.0
        repeatSpeed = 0.0
        arpSpeed = 0.0
        arpMod = 0.0
    }

    var description: String {
        "baseFreq=\(baseFreq), freqLimit=\(freqLimit), freqRamp=\(freqRamp), " +
        "freqDramp=\(freqDramp), duty=\(duty), dutyRamp=\(dutyRamp), vibStrength=\(vibStrength), " +
        "vibSpeed=\(vibSpeed), vibDelay=\(vibDelay), envAttack=\(envAttack), envSustain=\(envSustain), " +
        "envDecay=\(envDecay), envPunch=\(envPunch), filterOn=\(filterOn), lpfResonance=\(lpfResonance), " +
        "lpfFreq=\(lpfFreq), lpfRamp=\(lpfRamp), hpfFreq=\(hpfFreq), hpfRamp=\(hpfRamp), " +
        "phaOffset=\(phaOffset), phaRamp=\(phaRamp), repeatSpeed=\(repeatSpeed), arpSpeed=\(arpSpeed), " +
        "arpMod=\(arpMod)"
    }

    static func random() -> SFXRParameters {
        let p = SFXRParameters()
        p.baseFreq = pow(frnd(2.0) - 1.0, 2.0)
        if Bool.random() {
            p.baseFreq = pow(frnd(2.0) - 1.0, 3.0) + 0.5
        }
        p.freqLimit = 0.0
        p.freqRamp = pow(frnd(2.0) - 1.0, 5.0)
        if p.baseFreq > 0.7, p.freqRamp > 0.2 {
            p.freqRamp = -p.freqRamp
        }
        if p.baseFreq < 0.2, p.freqRamp < -0.05 {
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
        if p.lpfFreq < 0.1, p.lpfRamp < -0.05 {
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

    func mutate() {
        if Bool.random() {
            baseFreq += frnd(0.1) - 0.05
        }
        if Bool.random() {
            freqRamp += frnd(0.1) - 0.05
        }
        if Bool.random() {
            freqDramp += frnd(0.1) - 0.05
        }
        if Bool.random() {
            duty += frnd(0.1) - 0.05
        }
        if Bool.random() {
            dutyRamp += frnd(0.1) - 0.05
        }
        if Bool.random() {
            vibStrength += frnd(0.1) - 0.05
        }
        if Bool.random() {
            vibSpeed += frnd(0.1) - 0.05
        }
        if Bool.random() {
            vibDelay += frnd(0.1) - 0.05
        }
        if Bool.random() {
            envAttack += frnd(0.1) - 0.05
        }
        if Bool.random() {
            envSustain += frnd(0.1) - 0.05
        }
        if Bool.random() {
            envDecay += frnd(0.1) - 0.05
        }
        if Bool.random() {
            envPunch += frnd(0.1) - 0.05
        }
        if Bool.random() {
            lpfResonance += frnd(0.1) - 0.05
        }
        if Bool.random() {
            lpfFreq += frnd(0.1) - 0.05
        }
        if Bool.random() {
            lpfRamp += frnd(0.1) - 0.05
        }
        if Bool.random() {
            hpfFreq += frnd(0.1) - 0.05
        }
        if Bool.random() {
            hpfRamp += frnd(0.1) - 0.05
        }
        if Bool.random() {
            phaOffset += frnd(0.1) - 0.05
        }
        if Bool.random() {
            phaRamp += frnd(0.1) - 0.05
        }
        if Bool.random() {
            repeatSpeed += frnd(0.1) - 0.05
        }
        if Bool.random() {
            arpSpeed += frnd(0.1) - 0.05
        }
        if Bool.random() {
            arpMod += frnd(0.1) - 0.05
        }
    }

    static func template(for type: GeneratorType) -> SFXRParameters {
        let p = SFXRParameters()
        switch type {
        case .pickupCoin:
            p.reset()
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
            p.reset()
            p.waveType = WaveType(rawValue: rnd(2))!
            if p.waveType == .sine, Bool.random() {
                p.waveType = WaveType(rawValue: rnd(1))!
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
            p.reset()
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
            p.reset()
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
            p.reset()
            p.waveType = WaveType(rawValue: rnd(2))!
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
                p.hpfFreq = frnd(0.3)
            }
        case .jump:
            p.reset()
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
            p.reset()
            p.waveType = WaveType(rawValue: rnd(1))!
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

    func exportData() -> Data {
        let bdata = BinaryData()
        let version: UInt32 = 102
        bdata.append(version)
        bdata.append(UInt32(self.waveType.rawValue))
        bdata.append(self.soundVol)
        bdata.append(self.baseFreq)
        bdata.append(self.freqLimit)
        bdata.append(self.freqRamp)
        bdata.append(self.freqDramp)
        bdata.append(self.duty)
        bdata.append(self.dutyRamp)
        bdata.append(self.vibStrength)
        bdata.append(self.vibSpeed)
        bdata.append(self.vibDelay)
        bdata.append(self.envAttack)
        bdata.append(self.envSustain)
        bdata.append(self.envDecay)
        bdata.append(self.envPunch)
        bdata.append(self.filterOn)
        bdata.append(self.lpfResonance)
        bdata.append(self.lpfFreq)
        bdata.append(self.lpfRamp)
        bdata.append(self.hpfFreq)
        bdata.append(self.hpfRamp)
        bdata.append(self.phaOffset)
        bdata.append(self.phaRamp)
        bdata.append(self.repeatSpeed)
        bdata.append(self.arpSpeed)
        bdata.append(self.arpMod)
        return bdata.data
    }

    convenience init(from data: Data) {
        self.init()
        let bdata = BinaryData(data: data)
        var pos = 0
        let version: UInt32 = bdata.uint32(at: pos)
        pos += MemoryLayout<UInt32>.size
        let waveType: UInt32 = bdata.uint32(at: pos)
        pos += MemoryLayout<UInt32>.size
        if let wt = WaveType(rawValue: Int(waveType)) {
            self.waveType = wt
        }
        if version == 102 {
            self.soundVol = bdata.float(at: pos)
            pos += MemoryLayout<Float>.size
        }
        self.baseFreq = bdata.float(at: pos)
        pos += MemoryLayout<Float>.size
        self.freqLimit = bdata.float(at: pos)
        pos += MemoryLayout<Float>.size
        self.freqRamp = bdata.float(at: pos)
        pos += MemoryLayout<Float>.size
        if version >= 101 {
            self.freqDramp = bdata.float(at: pos)
            pos += MemoryLayout<Float>.size
        }
        self.duty = bdata.float(at: pos)
        pos += MemoryLayout<Float>.size
        self.dutyRamp = bdata.float(at: pos)
        pos += MemoryLayout<Float>.size
        self.vibStrength = bdata.float(at: pos)
        pos += MemoryLayout<Float>.size
        self.vibSpeed = bdata.float(at: pos)
        pos += MemoryLayout<Float>.size
        self.vibDelay = bdata.float(at: pos)
        pos += MemoryLayout<Float>.size
        self.envAttack = bdata.float(at: pos)
        pos += MemoryLayout<Float>.size
        self.envSustain = bdata.float(at: pos)
        pos += MemoryLayout<Float>.size
        self.envDecay = bdata.float(at: pos)
        pos += MemoryLayout<Float>.size
        self.envPunch = bdata.float(at: pos)
        pos += MemoryLayout<Float>.size
        let filter_on: Bool = bdata.bool(at: pos)
        self.filterOn = filter_on
        pos += 1
        self.lpfResonance = bdata.float(at: pos)
        pos += MemoryLayout<Float>.size
        self.lpfFreq = bdata.float(at: pos)
        pos += MemoryLayout<Float>.size
        self.lpfRamp = bdata.float(at: pos)
        pos += MemoryLayout<Float>.size
        self.hpfFreq = bdata.float(at: pos)
        pos += MemoryLayout<Float>.size
        self.hpfRamp = bdata.float(at: pos)
        pos += MemoryLayout<Float>.size
        self.phaOffset = bdata.float(at: pos)
        pos += MemoryLayout<Float>.size
        self.phaRamp = bdata.float(at: pos)
        pos += MemoryLayout<Float>.size
        self.repeatSpeed = bdata.float(at: pos)
        pos += MemoryLayout<Float>.size
        if version >= 101 {
            self.arpSpeed = bdata.float(at: pos)
            pos += MemoryLayout<Float>.size
            self.arpMod = bdata.float(at: pos)
            pos += MemoryLayout<Float>.size
        }
    }
    
    struct SynthState {
        var phase: Int = 0
        var fperiod: Double = 0.0
        var fmaxperiod: Double = 0.0
        var fslide: Double = 0.0
        var fdslide: Double = 0.0
        var period: Int = 0
        var squareDuty: Float = 0.0
        var squareSlide: Float = 0.0
        var envStage: Int = 0
        var envTime: Int = 0
        var envLength: [Int] = [0, 0, 0]
        var envVol: Float = 0.0
        var fphase: Float = 0.0
        var fdphase: Float = 0.0
        var iphase: Int = 0
        var phaserBuffer: [Float] = Array(repeating: 0.0, count: 1024)
        var ipp: Int = 0
        var noiseBuffer: [Float] = Array(repeating: 0.0, count: 32)
        var fltp: Float = 0.0
        var fltdp: Float = 0.0
        var fltw: Float = 0.0
        var fltwD: Float = 0.0
        var fltdmp: Float = 0.0
        var fltphp: Float = 0.0
        var flthp: Float = 0.0
        var flthpD: Float = 0.0
        var vibPhase: Float = 0.0
        var vibSpeed: Float = 0.0
        var vibAmp: Float = 0.0
        var repTime: Int = 0
        var repLimit: Int = 0
        var arpTime: Int = 0
        var arpLimit: Int = 0
        var arpMod: Double = 0.0
        var playingSample: Bool = true
    }

    func exportWav(sampleRate: Int = 44100, bits: Int = 16) -> Data {
        let wavBits = bits
        let wavFreq = sampleRate
        let bdata = BinaryData()
        bdata.append("RIFF")
        bdata.append(UInt32(0)) // placeholder for file size
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
        bdata.append(UInt32(0)) // placeholder for data chunk size
        var state = SynthState()
        // --- 初期化 ---
        state.fperiod = 100.0 / (Double(self.baseFreq) * Double(self.baseFreq) + 0.001)
        state.period = Int(state.fperiod)
        state.fmaxperiod = 100.0 / (Double(self.freqLimit) * Double(self.freqLimit) + 0.001)
        state.fslide = 1.0 - pow(Double(self.freqRamp), 3.0) * 0.01
        state.fdslide = -pow(Double(self.freqDramp), 3.0) * 0.000001
        state.squareDuty = 0.5 - self.duty * 0.5
        state.squareSlide = -self.dutyRamp * 0.00005
        if self.arpMod >= 0.0 {
            state.arpMod = 1.0 - pow(Double(self.arpMod), 2.0) * 0.9
        } else {
            state.arpMod = 1.0 + pow(Double(self.arpMod), 2.0) * 10.0
        }
        state.arpTime = 0
        state.arpLimit = Int(pow(1.0 - self.arpSpeed, 2.0) * 20000 + 32)
        if self.arpSpeed == 1.0 {
            state.arpLimit = 0
        }
        // reset filter
        state.fltp = 0.0
        state.fltdp = 0.0
        state.fltw = pow(self.lpfFreq, 3.0) * 0.1
        state.fltwD = 1.0 + self.lpfRamp * 0.0001
        state.fltdmp = 5.0 / (1.0 + pow(self.lpfResonance, 2.0) * 20.0) * (0.01 + state.fltw)
        if state.fltdmp > 0.8 {
            state.fltdmp = 0.8
        }
        state.fltphp = 0.0
        state.flthp = pow(self.hpfFreq, 2.0) * 0.1
        state.flthpD = 1.0 + self.hpfRamp * 0.0003
        // reset vibrato
        state.vibPhase = 0.0
        state.vibSpeed = pow(self.vibSpeed, 2.0) * 0.01
        state.vibAmp = self.vibStrength * 0.5
        // reset envelope
        state.envVol = 0.0
        state.envStage = 0
        state.envTime = 0
        state.envLength[0] = max(1, Int(self.envAttack * self.envAttack * 100000.0))
        state.envLength[1] = max(1, Int(self.envSustain * self.envSustain * 100000.0))
        state.envLength[2] = max(1, Int(self.envDecay * self.envDecay * 100000.0))
        state.fphase = pow(self.phaOffset, 2.0) * 1020.0
        if self.phaOffset < 0.0 {
            state.fphase = -state.fphase
        }
        state.fdphase = pow(self.phaRamp, 2.0) * 1.0
        if self.phaRamp < 0.0 {
            state.fdphase = -state.fdphase
        }
        state.iphase = abs(Int(state.fphase))
        state.ipp = 0
        for i in 0 ..< state.phaserBuffer.count {
            state.phaserBuffer[i] = 0.0
        }
        for i in 0 ..< state.noiseBuffer.count {
            state.noiseBuffer[i] = frnd(2.0) - 1.0
        }
        state.repTime = 0
        state.repLimit = Int(pow(1.0 - self.repeatSpeed, 2.0) * 20000 + 32)
        if self.repeatSpeed == 0.0 {
            state.repLimit = 0
        }
        // --- 合成ループ ---
        var fileSampleswritten = 0
        var filesample: Float = 0.0
        var fileacc: Int = 0
        let bufferSize = 256
        var data = Data(count: bufferSize * MemoryLayout<Int16>.size)
        while state.playingSample {
            var framesWritten = 0
            data.withUnsafeMutableBytes { rawMutableBufferPointer in
                let bufferPointer = rawMutableBufferPointer.bindMemory(to: Int16.self)
                if let address = bufferPointer.baseAddress {
                    framesWritten = synthSample(parameters: self, state: &state, pointer: address, numberOfFrames: bufferSize, exportWave: true, filesample: &filesample, fileacc: &fileacc, wavFreq: wavFreq, wavBits: wavBits)
                }
            }
            let nbytes = framesWritten * MemoryLayout<Int16>.size
            for i in 0 ..< nbytes {
                bdata.append(data[i])
            }
            fileSampleswritten += nbytes
        }
        bdata.setUInt32(UInt32(bdata.data.count - 8), at: 4)
        bdata.setUInt32(UInt32(fileSampleswritten * wavBits / 8), at: 40)
        return bdata.data
    }

    private func synthSample(parameters: SFXRParameters, state: inout SynthState, pointer _ptr: UnsafeMutablePointer<Int16>, numberOfFrames nframes: Int, exportWave: Bool, filesample: inout Float, fileacc: inout Int, wavFreq: Int, wavBits: Int) -> Int {
        var ptr = _ptr
        var framesWritten = 0
        for _ in 0 ..< nframes {
            if !state.playingSample {
                break
            }
            state.repTime += 1
            if state.repLimit != 0, state.repTime >= state.repLimit {
                state.repTime = 0
                // 再初期化（restart: true）
                // ここでは省略
            }
            // frequency envelopes/arpeggios
            state.arpTime += 1
            if state.arpLimit != 0, state.arpTime >= state.arpLimit {
                state.arpLimit = 0
                state.fperiod *= state.arpMod
            }
            state.fslide += state.fdslide
            state.fperiod *= state.fslide
            if state.fperiod > state.fmaxperiod {
                state.fperiod = state.fmaxperiod
                state.playingSample = false
            }
            var rfperiod = state.fperiod
            if state.vibAmp > 0.0 {
                state.vibPhase += state.vibSpeed
                rfperiod = state.fperiod * Double(1.0 + sin(state.vibPhase) * state.vibAmp)
            }
            state.period = Int(rfperiod)
            if state.period < 8 {
                state.period = 8
            }
            state.squareDuty += state.squareSlide
            if state.squareDuty < 0.0 {
                state.squareDuty = 0.0
            }
            if state.squareDuty > 0.5 {
                state.squareDuty = 0.5
            }
            // volume envelope
            state.envTime += 1
            if state.envTime > state.envLength[state.envStage] {
                state.envTime = 0
                state.envStage += 1
                if state.envStage == 3 {
                    state.playingSample = false
                }
            }
            if state.envStage == 0 {
                state.envVol = Float(state.envTime) / Float(state.envLength[0])
            }
            if state.envStage == 1 {
                state.envVol = 1.0 + pow(1.0 - Float(state.envTime) / Float(state.envLength[1]), 1.0) * 2.0 * parameters.envPunch
            }
            if state.envStage == 2 {
                state.envVol = 1.0 - Float(state.envTime) / Float(state.envLength[2])
            }
            // phaser step
            state.fphase += state.fdphase
            state.iphase = abs(Int(state.fphase))
            if state.iphase > 1023 {
                state.iphase = 1023
            }
            if state.flthpD != 0.0 {
                state.flthp *= state.flthpD
                if state.flthp < 0.00001 {
                    state.flthp = 0.00001
                }
                if state.flthp > 0.1 {
                    state.flthp = 0.1
                }
            }
            var ssample: Float = 0.0
            for _ in 0 ..< 8 { // 8x supersampling
                var sample: Float = 0.0
                state.phase += 1
                if state.phase >= state.period {
                    state.phase %= state.period
                    if self.waveType == .noise {
                        for i in 0 ..< 32 {
                            state.noiseBuffer[i] = frnd(2.0) - 1.0
                        }
                    }
                }
                // base waveform
                let fp = Float(state.phase) / Float(state.period)
                switch self.waveType {
                case .square:
                    sample = fp < state.squareDuty ? 0.5 : -0.5
                case .sawtooth:
                    sample = 1.0 - fp * 2.0
                case .sine:
                    sample = sin(fp * 2.0 * Float.pi)
                case .noise:
                    sample = state.noiseBuffer[state.phase * 32 / state.period]
                }
                // lp filter
                let pp = state.fltp
                state.fltw *= state.fltwD
                if state.fltw < 0.0 {
                    state.fltw = 0.0
                }
                if state.fltw > 0.1 {
                    state.fltw = 0.1
                }
                if self.lpfFreq != 1.0 {
                    state.fltdp += (sample - state.fltp) * state.fltw
                    state.fltdp -= state.fltdp * state.fltdmp
                } else {
                    state.fltp = sample
                    state.fltdp = 0.0
                }
                state.fltp += state.fltdp
                // hp filter
                state.fltphp += state.fltp - pp
                state.fltphp -= state.fltphp * state.flthp
                sample = state.fltphp
                // phaser
                state.phaserBuffer[state.ipp & 1023] = sample
                sample += state.phaserBuffer[(state.ipp - state.iphase + 1024) & 1023]
                state.ipp = (state.ipp + 1) & 1023
                // final accumulation and envelope application
                ssample += sample * state.envVol
            }
            ssample = ssample / 8 * self.masterVol
            ssample *= 2.0 * self.soundVol
            if !exportWave {
                if ssample > 1.0 {
                    ssample = 1.0
                }
                if ssample < -1.0 {
                    ssample = -1.0
                }
                ptr.pointee = Int16(ssample * 32000.0)
            } else {
                ssample *= 4.0 // arbitrary gain
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
                    }
                    filesample = 0.0
                }
            }
            ptr = ptr.successor()
            framesWritten += 1
        }
        return framesWritten
    }
} 
