import Foundation
import AVFoundation
import Observation

@Observable class SoundPlayer {
    private var player: AVAudioPlayer?
    
    func play(data: Data) {
        do {
            player = try AVAudioPlayer(data: data)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Audio再生エラー: \(error)")
        }
    }
}
