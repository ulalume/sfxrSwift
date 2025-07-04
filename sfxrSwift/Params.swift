//
//  Item.swift
//  sfxrSwift
//
//  Created by kbt on 2025/07/02.
//  Copyright © 2025 Yohei Yoshihara. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Params {
    var timestamp: Date
    var params: Data
    
    @Transient private var _sfxrParameters: SFXRParameters?
    var sfxrParameters: SFXRParameters {
        if let _sfxrParameters {
            return _sfxrParameters
        }
        let sfxrParameters = SFXRParameters(from: params)
        _sfxrParameters = sfxrParameters
        return sfxrParameters
    }
    
    @Transient private var _wave: Data?
    var wave: Data {
        if let _wave {
            return _wave
        }
        let wave = sfxrParameters.exportWav()
        _wave = wave
        return wave
    }
    
    
    init(timestamp: Date, params: SFXRParameters) {
        self.timestamp = timestamp
        self._sfxrParameters = params
        self.params = params.exportData()
    }
}
