//
//  Item.swift
//  sfxrSwift
//
//  Created by kbt on 2025/07/02.
//  Copyright © 2025 Yohei Yoshihara. All rights reserved.
//

import Foundation
import SwiftData
import SFXRSwiftLib

@Observable
final class ParamsData {
    var sfxrParameters: SFXRParameters
    var wave: Data? = nil
    var waveform: [WaveformPoint]? = nil
    var detailedWaveform: [WaveformPoint]? = nil
    
    init(sfxrParameters: SFXRParameters) {
        self.sfxrParameters = sfxrParameters
    }
}

@Model
final class Params {
    var timestamp: Date
    var params: Data
    
    @Transient private var _paramsData: ParamsData?
    private var paramsData: ParamsData {
        if let _paramsData {
            return _paramsData
        }
        let sfxrParameters = SFXRParameters(from: params)
        let paramsData = ParamsData(sfxrParameters: sfxrParameters)
        self._paramsData = paramsData
        return paramsData
    }
    
    var sfxrParameters: SFXRParameters {
        get {
            paramsData.sfxrParameters
        }
        set {
            paramsData.sfxrParameters = newValue
        }
    }
    var wave: Data {
        if let _wave = paramsData.wave {
            return _wave
        }
        let wave = paramsData.sfxrParameters.exportWav()
        self.paramsData.wave = wave
        return wave
    }
    
    var waveform: [WaveformPoint] {
        if let _waveform = paramsData.waveform {
            return _waveform
        }
        
        let waveform = loadDownsampledWaveform(data: wave, targetSampleCount: 100)
        self.paramsData.waveform = waveform
        return waveform
    }
    var detailedWaveform: [WaveformPoint] {
        if let _detailedWaveform = paramsData.detailedWaveform {
            return _detailedWaveform
        }
        
        let detailedWaveform = loadDownsampledWaveform(data: wave, targetSampleCount: 500)
        self.paramsData.detailedWaveform = detailedWaveform
        return detailedWaveform
    }
    
    func update() {
        paramsData.wave = nil
        paramsData.waveform = nil
        paramsData.detailedWaveform = nil
        params = paramsData.sfxrParameters.exportData()
    }
    
    init(timestamp: Date, sfxrParameters: SFXRParameters) {
        self.timestamp = timestamp
        self.params = sfxrParameters.exportData()
        self._paramsData = ParamsData(sfxrParameters: sfxrParameters)
    }
}
