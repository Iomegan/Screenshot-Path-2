//
//  ContentView.swift
//  Screenshot Path
//
//  Created by Daniel Witt on 04.03.24.
//

import SwiftUI
import TipKit
import UniformTypeIdentifiers.UTType

@available(iOS 17, macOS 14, *)
struct ScreenshotFolderTip: Tip {
    var title: Text {
        Text("Create a dedicated Screenshot Folder")
    }

    var message: Text? {
        Text(String(localized: "This action creates a new folder named Screenshots in your home directory. It also adds the folder to the Dock for convenient access to your screenshots.").replacingOccurrences(of: ". ", with: "\n"))
    }
}

// @available(macOS 14.0, *)
// struct MyTipViewStyle: TipViewStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        VStack(alignment: .leading) {
//            HStack(alignment: .top) {
//                HStack {
//                    configuration.image
//                    configuration.title
//                        .multilineTextAlignment(.leading)
//                }
//                .font(.headline)
//
//                Spacer()
//                Button(action: {
//                    configuration.tip.invalidate(reason: .tipClosed)
//                }, label: {
//                    Image(systemName: "xmark")
//                })
//                .mask(Circle())
//            }
//
//            configuration.message?
//                .font(.body)
//                .foregroundStyle(.secondary)
//                .multilineTextAlignment(.leading)
//
//                .frame(maxWidth: 300, maxHeight: .infinity)
//
//
//
//        }
//        .padding()
//        .fixedSize()
//
//    }
// }
struct ContentView: View {
    let avaialbleFileTypies = [UTType.png, .jpeg, .bmp, .heic, .gif, .pdf, .tiff]

    @ObservedObject private var screenshotSettings = ScreenshotSettings()

    var body: some View {
        Form {
            Section {
                Button {
                    chooseScreenshotPath()
                } label: {
                    FilePathView(url: self.$screenshotSettings.pathURL)
                }
                .buttonStyle(.plain)
            }
            header: {
                Text("Path")
            }
            footer: {
                HStack {
                    Spacer()

                    Button("Reveal in Finder") {
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: screenshotSettings.pathURL.path(percentEncoded: false))
                    }

                    Button("Select Folder") {
                        chooseScreenshotPath()
                    }

                    if #available(iOS 17, macOS 14, *) {
                        Button("Create Screenshot Folder") {
                            addApplicationToDock()
                        }
                        .help("This action creates a new folder named Screenshots in your home directory. It also adds the folder to the Dock for convenient access to your screenshots.")
                        .popoverTip(ScreenshotFolderTip(), arrowEdge: .trailing)
//                        .tipViewStyle(MyTipViewStyle())
                    }
                    else {
                        Button("Create Screenshot Folder") {
                            addApplicationToDock()
                        }
                        .help("This action creates a new folder named Screenshots in your home directory. It also adds the folder to the Dock for convenient access to your screenshots.")
                    }
                }
                .buttonStyle(.bordered)
            }
            Section("Settings") {
                Picker("File Type", selection: self.$screenshotSettings.fileType) {
                    ForEach(self.avaialbleFileTypies) { type in
                        Text(type.localizedDescription ?? "Untitled").tag(type)
                    }
                }
                Toggle("Add Shadow to Image", isOn: self.$screenshotSettings.shaddow)
                Toggle("Use Timestamp in File Name", isOn: self.$screenshotSettings.timeStamp)
                Toggle("Use Custom Name", isOn: self.$screenshotSettings.useDefaultName)
                if self.screenshotSettings.useDefaultName {
                    TextField("Name", text: self.$screenshotSettings.name)
                        .textFieldStyle(.squareBorder)
                }
            }
            .tint(.accentColor)
        }
        .scrollDisabled(true)
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .onAppear { screenshotSettings.readUserDefaults() }
        .onChange(of: screenshotSettings.description) { newValue in
            NSLog("New screenshot settings: \(newValue)")
            screenshotSettings.setUpdatedUserDefaults()
        }
    }

    private func chooseScreenshotPath() {
        let choosePanel = NSOpenPanel()
        // Configure your panel the way you want it
        choosePanel.canChooseFiles = false
        choosePanel.canChooseDirectories = true
        choosePanel.allowsMultipleSelection = false
        choosePanel.directoryURL = screenshotSettings.pathURL
        choosePanel.prompt = NSLocalizedString("CHOOSE", comment: "")

        choosePanel.beginSheetModal(for: NSApp.mainWindow!) { result in
            if result == NSApplication.ModalResponse.OK {
                screenshotSettings.pathURL = choosePanel.url ?? ScreenshotSettings.defaultURL
            }
        }
    }

    private func addApplicationToDock() {
        let defaults = UserDefaults.standard
        let url = URL(fileURLWithPath: NSString(format: "~/%@", "Screenshots.localized").expandingTildeInPath)
        let urlLoc = url.appending(path: ".localized")
        let path = "file:///\(url.path(percentEncoded: false))"
        do {
//            try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(atPath: urlLoc.path, withIntermediateDirectories: true, attributes: nil)

            // Localized Folder:  https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemAdvancedPT/LocalizingtheNameofaDirectory/LocalizingtheNameofaDirectory.html
            let jaScreenshotNameFile = URL(filePath: Bundle.main.path(forResource: "ja", ofType: "strings")!)
            let frScreenshotNameFile = URL(filePath: Bundle.main.path(forResource: "fr", ofType: "strings")!)
            let itScreenshotNameFile = URL(filePath: Bundle.main.path(forResource: "it", ofType: "strings")!)
            let esScreenshotNameFile = URL(filePath: Bundle.main.path(forResource: "es", ofType: "strings")!)
            let deScreenshotNameFile = URL(filePath: Bundle.main.path(forResource: "de", ofType: "strings")!)

            try FileManager.default.copyItem(at: frScreenshotNameFile, to: urlLoc.appending(path: "fr.strings"))
            try FileManager.default.copyItem(at: jaScreenshotNameFile, to: urlLoc.appending(path: "ja.strings"))
            try FileManager.default.copyItem(at: itScreenshotNameFile, to: urlLoc.appending(path: "it.strings"))
            try FileManager.default.copyItem(at: esScreenshotNameFile, to: urlLoc.appending(path: "es.strings"))
            try FileManager.default.copyItem(at: deScreenshotNameFile, to: urlLoc.appending(path: "de.strings"))
        }
        catch {
            print("error: \(error)")
        }

        NSWorkspace.shared.setIcon(NSImage(named: "BigSur_Icon"), forFile: url.path(percentEncoded: false))

        guard let domain = defaults.persistentDomain(forName: "com.apple.dock"),
              let folders = domain["persistent-others"] as? [[String: Any]] else { return }

        var newDomain = domain
        var newFolders = folders
        let folder: [String: Any] = ["tile-type": "directory-tile",
                                     "tile-data": ["file-data": ["_CFURLString": path, "_CFURLStringType": 15]],
                                     "showas": 0,
                                     "file-type": 2,
                                     "displayas": 0,
                                     "file-label": "Screenshots",
                                     "arrangement": 2,
                                     "is-beta": 0,
                                     "preferreditemsize": -1]
        newFolders.append(folder)
        newDomain["persistent-others"] = newFolders
        defaults.setPersistentDomain(newDomain, forName: "com.apple.dock")
        defaults.synchronize()
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "/usr/bin/killall Dock"]
        task.launch()

        screenshotSettings.pathURL = url
    }
}

// #Preview {
//    ContentView()
//        .fixedSize()
// }
