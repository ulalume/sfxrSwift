//
//  ContentView.swift
//  Silivane
//
//  Created by kbt on 2025/07/02.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var paramsList: [Params] = []
    
    @State private var soundPlayer = SoundPlayer()
    
    var body: some View {
        VStack(spacing: 20) {
            List(paramsList) { params in
                VStack(alignment: .leading) {
                    Button(action: {
                        let wave = params.wave
                        soundPlayer.play(data: wave)
                    }) {
                        Text("Timestamp: \(params.timestamp, formatter: DateFormatter())")
                        Text("Parameters: \(params.sfxrParameters.description)")
                    }
                }
            }
            
            Button("Add Params") {
                let newParams = Params(timestamp: Date(), params: .random())
                modelContext.insert(newParams)
                try? modelContext.save()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Params.self, inMemory: true)
}
