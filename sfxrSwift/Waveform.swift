//
//  Waveform.swift
//  sfxrSwift
//
//  Created by kbt on 2025/07/06.
//  Copyright © 2025 Yohei Yoshihara. All rights reserved.
//

import AVFoundation

struct WaveformPoint {
    let min: Float
    let max: Float
}

func loadDownsampledWaveform(data: Data, targetSampleCount: Int) -> [WaveformPoint] {
    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("wav")
    do {
        try data.write(to: tempURL)
    } catch {
        print("一時ファイルへの書き出しに失敗: \(error)")
        return []
    }
    
    // AVAudioFileで読み込み
    guard let file = try? AVAudioFile(forReading: tempURL) else {
        print("AVAudioFileの初期化に失敗")
        return []
    }
    
    let format = file.processingFormat
    let frameCount = Int(file.length)
    guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frameCount)) else {
        print("PCMバッファ作成失敗")
        return []
    }
    
    do {
        try file.read(into: buffer)
    } catch {
        print("音声データの読み込みに失敗: \(error)")
        return []
    }
    
    guard let floatData = buffer.floatChannelData?[0] else { return [] }
    let samples = Array(UnsafeBufferPointer(start: floatData, count: frameCount))
    
    let st = max(1, samples.count / targetSampleCount)
    var result: [WaveformPoint] = []
    
    for i in stride(from: 0, to: samples.count, by: st) {
        let end = min(i + st, samples.count)
        let segment = samples[i..<end]
        let min = segment.min() ?? 0
        let max = segment.max() ?? 0
        result.append(WaveformPoint(min: min, max: max))
    }
    
    return result
}

import SwiftUI

struct WaveformView: View {
    let samples: [WaveformPoint]
    var color: Color = .accentColor
    
    var body: some View {
        Canvas { context, size in
            let midY = size.height / 2
            let stepX = size.width / CGFloat(samples.count)
            
            var path = Path()
            for (index, sample) in samples.enumerated() {
                let x = CGFloat(index) * stepX
                let y1 = midY - CGFloat(sample.max) * midY
                let y2 = midY - CGFloat(sample.min) * midY
                path.move(to: CGPoint(x: x, y: y1))
                path.addLine(to: CGPoint(x: x, y: y2))
            }
            context.stroke(path, with: .color(color), lineWidth: 1)
        }
    }
}
