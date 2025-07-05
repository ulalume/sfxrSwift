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
    @Environment(SoundPlayer.self) private var soundPlayer
    @Query private var paramsList: [Params] = []
    @Binding var selectedItem: Params?
    
    @State private var dateFormatter = DateFormatter();
    
    func add(sfxr: SFXRParameters) {
        let newParams = Params(timestamp: Date(), params: sfxr)
        modelContext.insert(newParams)
        try? modelContext.save()
        
        self.selectedItem = newParams
    }
    func play() {
        guard let selectedItem else { return }
        let wave = selectedItem.sfxrParameters.exportWav()
        soundPlayer.play(data: wave)
    }
    var body: some View {
        NavigationSplitView {
            List(paramsList, selection: $selectedItem) { params in
                HStack {
                    Text(params.sfxrParameters.waveType.label)
                        .font(.headline)
                    Spacer()
                    Text(dateFormatter.string(from: params.timestamp))
                        .font(.caption)
                }.tag(params)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        add(sfxr: .init())
                    }) {
                        Label("Add", systemImage: "plus")
                    }
                }
                if let selectedItem {
                    ToolbarItem(placement:.destructiveAction) {
                        Button(action: {
                            modelContext.delete(selectedItem)
                            try? modelContext.save()
                            self.selectedItem = nil
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        } detail: {
            if let selectedItem {
                let bindingParams = Binding<Params>(
                    get: { selectedItem },
                    set: { newValue in
                        self.selectedItem = newValue
                    }
                )
                ParamsView(params: bindingParams)
                    .navigationTitle("")
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: {
                                selectedItem.sfxrParameters.mutate()
                                try? modelContext.save()
                                
                                play()
                            }) {
                                Label("Mutate", systemImage: "arrow.trianglehead.clockwise.rotate.90")
                            }
                        }
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: play) {
                                Label("Play", systemImage: "play.fill")
                            }
                        }
                        ToolbarItemGroup(placement: .navigation) {
                            Button(action: {
                                self.selectedItem?.sfxrParameters = .random()
                                try? modelContext.save()
                                play()
                            }) {
                                Label("Random", systemImage: "dice.fill")
                            }
                            ForEach(GeneratorType.allCases, id: \.self) { generator in
                                Button(action: {
                                    self.selectedItem?.sfxrParameters = .template(for: generator)
                                    try? modelContext.save()
                                    
                                    play()
                                }) {
                                    Label(generator.label, systemImage: generator.systemImage)
                                }
                            }
                        }
                    }
            } else {
                Text("No params selected")
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            if paramsList.isEmpty {
                let initialParams = Params(timestamp: Date(), params: .random())
                modelContext.insert(initialParams)
                try? modelContext.save()
                
                selectedItem = initialParams
            }
            
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short

        }
    }
}

#Preview {
    ContentView(selectedItem: .constant(nil))
        .modelContainer(for: Params.self, inMemory: true)
}
