//
//  SilivaneApp.swift
//  Silivane
//
//  Created by kbt on 2025/07/02.
//

import SwiftUI
import SwiftData

@main
struct SFXRApp: App {
    @State private var soundPlayer = SoundPlayer()
    @State var selectedItem: Params?
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Params.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    var body: some Scene {
        WindowGroup {
            ContentView(selectedItem: $selectedItem)
        }
        .commands {
            CommandGroup(before: .saveItem) { // saveItemの前、通常は新規作成は保存より前にあるのでbeforeで指定
                Button("新規作成") {
                    let newParams = Params(timestamp: Date(), params: .init())
                    sharedModelContainer.mainContext.insert(newParams)
                    try? sharedModelContainer.mainContext.save()
                    selectedItem = newParams
                }
                .keyboardShortcut("N", modifiers: [.command]) // Cmd + N
            }
            // 削除
            CommandGroup(after: .undoRedo) {
                Divider()
                Button("削除") {
                    guard let selectedItem else { return }
                    sharedModelContainer.mainContext.delete(selectedItem)
                    try? sharedModelContainer.mainContext.save()
                    self.selectedItem = nil
                }
                .disabled( selectedItem == nil)
                .keyboardShortcut(.delete) // Cmd + Delete
            }
            CommandGroup(after: .saveItem) {
                Divider()
                Menu("インポート") {
                    Button("sfxr") {
                        Task {
                            if let data = await importSfr() {
                                let sfxr = SFXRParameters(from: data)
                                let newParams = Params(timestamp: Date(), params: sfxr)
                                sharedModelContainer.mainContext.insert(newParams)
                                try? sharedModelContainer.mainContext.save()
                                selectedItem = newParams
                            }
                        }
                    }
                    .keyboardShortcut("S", modifiers: [.command])
                }.disabled(selectedItem == nil)
                Divider()
                Menu("エキスポート") {
                    Button("WAV") {
                        if let selectedItem {
                            Task {
                                await Exporter.shared.export(wav: selectedItem.sfxrParameters.exportWav())
                            }
                        }
                    }
                    .keyboardShortcut("E", modifiers: [.command])
                    Button("sfxr") {
                        if let selectedItem {
                            Task {
                                await Exporter.shared.export(sfxr: selectedItem.params)
                            }
                        }
                    }
                    .keyboardShortcut("S", modifiers: [.command])
                }.disabled(selectedItem == nil)
            }
        }
        .modelContainer(sharedModelContainer)
        .environment(soundPlayer)
    }
}

@MainActor
class Exporter {
    static let shared = Exporter()
    func export(wav: Data) async {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.wav]
        panel.nameFieldStringValue = "output.wav"
        
        let response = await panel.begin()
        
        if response == .OK, let url = panel.url {
            // ここであなたの作ったWAVデータを書き込みます
            do {
                try wav.write(to: url)
                print("WAV書き出し成功: \(url)")
            } catch {
                print("エクスポート失敗: \(error)")
            }
        }
    }
    func export(sfxr: Data) async {
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["sfxr"]
        panel.nameFieldStringValue = "output.sfxr"
        
        let response = await panel.begin()
        
        if response == .OK, let url = panel.url {
            // ここであなたの作ったWAVデータを書き込みます
            do {
                try sfxr.write(to: url)
                print("WAV書き出し成功: \(url)")
            } catch {
                print("エクスポート失敗: \(error)")
            }
        }
    }
}

@MainActor
func importSfr() async  -> Data? {
    let panel = NSOpenPanel()
    panel.allowedFileTypes = ["sfxr"]
    panel.allowsMultipleSelection = true
    
    let response = await panel.begin()
    if response == .OK, let url = panel.url {
        do {
            let data = try Data(contentsOf: url)
            print("sfxrファイル読み込み成功: \(url)")
            return data
        } catch {
            print("読み込み失敗: \(error)")
        }
    }
    return nil
}
