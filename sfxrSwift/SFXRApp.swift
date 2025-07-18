//
//  SilivaneApp.swift
//  Silivane
//
//  Created by kbt on 2025/07/02.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import SFXRSwiftLib


extension SFXRParameters.WaveType: @retroactive CaseIterable {
    public static var allCases: [SFXRParameters.WaveType] {
        return [.square, .sawtooth, .sine, .noise]
    }
    var label: String {
        switch self {
        case .square: return "Square"
        case .sawtooth: return "Sawtooth"
        case .sine: return "Sine"
        case .noise: return "Noise"
        }
    }
}

extension SFXRParameters.GeneratorType: @retroactive CaseIterable {
    public static var allCases: [SFXRParameters.GeneratorType] {
        return [
            .pickupCoin,
            .laserShoot,
            .explosion,
            .powerup,
            .hitHurt,
            .jump,
            .blipSelect,
        ]
    }
     var label: String {
        switch self {
        case .pickupCoin: return "Pickup/Coin"
        case .laserShoot: return "Laser/Shoot"
        case .explosion: return "Explosion"
        case .powerup: return "Powerup"
        case .hitHurt: return "Hit/Hurt"
        case .jump: return "Jump"
        case .blipSelect: return "Blip/Select"
        }
    }
     var systemImage: String {
        switch self {
        case .pickupCoin: return "dollarsign.circle.fill"
        case .laserShoot: return "bolt.fill"
        case .explosion: return "flame.fill"
        case .powerup: return "star.fill"
        case .hitHurt: return "seal.fill"
        case .jump: return "shoe.fill"
        case .blipSelect: return "checkmark.circle.fill"
        }
    }
}

@main
struct SFXRApp: App {
    @State private var soundPlayer = SoundPlayer()
    @State var selectedItem: Params?
    @State private var showingWAVExporter = false
    @State private var showingSFXRExporter = false
    @State private var showingSFXRImporter = false
    @State private var wavDocumentToExport: WAVDocument?
    @State private var sfxrDocumentToExport: SFXRDocument?
    @State private var documentToExport: AnyFileDocument?
    
    // ファイルエクスポートの種類を管理
    enum ExportType {
        case wav, sfxr
    }
    @State private var exportType: ExportType = .wav
    @State private var showingExporter = false
    
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
                .fileExporter(
                    isPresented: $showingExporter,
                    document: documentToExport,
                    contentType: exportType == .wav ? .wav : .sfxr,
                    defaultFilename: exportType == .wav ? "output.wav" : "output.sfxr",
                    onCompletion: { result in
                        print("fileExporter onCompletion called")
                        print("documentToExport at completion: \(documentToExport != nil)")
                        switch result {
                        case .success(let url):
                            print("\(exportType == .wav ? "WAV" : "SFXR")書き出し成功: \(url)")
                        case .failure(let error):
                            print("エクスポート失敗: \(error)")
                        }
                        documentToExport = nil
                    }
                )
                .onChange(of: showingExporter) { _, isShowing in
                    print("showingExporter changed to: \(isShowing)")
                    print("documentToExport is nil: \(documentToExport == nil)")
                    if isShowing && documentToExport == nil {
                        print("Warning: Trying to show exporter with nil document!")
                    }
                }
                .fileImporter(
                    isPresented: $showingSFXRImporter,
                    allowedContentTypes: [.sfxr],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let urls):
                        if let url = urls.first {
                            do {
                                let data = try Data(contentsOf: url)
                                let sfxr = SFXRParameters(from: data)
                                let newParams = Params(timestamp: Date(), sfxrParameters: sfxr)
                                sharedModelContainer.mainContext.insert(newParams)
                                try? sharedModelContainer.mainContext.save()
                                selectedItem = newParams
                                print("sfxrファイル読み込み成功: \(url)")
                            } catch {
                                print("読み込み失敗: \(error)")
                            }
                        }
                    case .failure(let error):
                        print("インポート失敗: \(error)")
                    }
                }
        }
        .commands {
            CommandGroup(before: .saveItem) { // saveItemの前、通常は新規作成は保存より前にあるのでbeforeで指定
                Button("新規作成") {
                    let newParams = Params(timestamp: Date(), sfxrParameters: .init())
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
                        showingSFXRImporter = true
                    }
                    .keyboardShortcut("I", modifiers: [.command])
                }
                Divider()
                Menu("エクスポート") {
                    Button("WAV") {
                        print("WAV書き出し")
                        if let selectedItem {
                            print("WAV書き出し2")
                            print("WAVデータ生成開始")
                            let waveData = selectedItem.wave
                            print("WAVデータサイズ: \(waveData.count) bytes")
                            print("WAVデータが空かどうか: \(waveData.isEmpty)")
                            
                            // ドキュメントを作成
                            let document = AnyFileDocument(data: waveData, contentType: .wav)
                            print("AnyFileDocument作成完了: \(document.data.count) bytes")
                            
                            // 状態を設定
                            exportType = .wav
                            documentToExport = document
                            print("documentToExport設定完了: \(documentToExport != nil)")
                            print("showingExporter設定前: \(showingExporter)")
                            
                            // エクスポーターを表示
                            DispatchQueue.main.async {
                                showingExporter = true
                                print("showingExporter設定後: \(showingExporter)")
                                print("最終確認 - documentToExport: \(documentToExport != nil)")
                            }
                        }
                    }
                    .keyboardShortcut("E", modifiers: [.command])
                    Button("sfxr") {
                        if let selectedItem {
                            print("SFXR書き出し開始")
                            documentToExport = AnyFileDocument(data: selectedItem.params, contentType: .sfxr)
                            exportType = .sfxr
                            print("SFXRデータサイズ: \(selectedItem.params.count) bytes")
                            showingExporter = true
                            print("showingExporter設定: \(showingExporter)")
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

// iOS/macOS両対応のためSwiftUIのfileExporter/fileImporterを使用

extension UTType {
    static var sfxr: UTType {
        UTType(exportedAs: "me.ulalu.type.sfxr")
    }
}

// FileDocumentプロトコルに準拠したドキュメントクラス
struct AnyFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.wav, .sfxr] }
    static var writableContentTypes: [UTType] { [.wav, .sfxr] }
    
    var data: Data
    var contentType: UTType
    
    init(data: Data, contentType: UTType) {
        self.data = data
        self.contentType = contentType
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
        self.contentType = configuration.contentType
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}

struct WAVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.wav] }
    static var writableContentTypes: [UTType] { [.wav] }
    
    var data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}

struct SFXRDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.sfxr] }
    static var writableContentTypes: [UTType] { [.sfxr] }
    
    var data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}
