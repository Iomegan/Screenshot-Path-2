//
//  ScreenshotSettings.swift
//  Screenshot Path
//
//  Created by Daniel Witt on 04.03.24.
//

import Foundation
import UniformTypeIdentifiers.UTType

extension UTType: Identifiable {
    public var id: String {
        return identifier
    }
}

class ScreenshotSettings: ObservableObject, CustomStringConvertible {
    static var defaultURL = URL(fileURLWithPath: "~/Desktop", isDirectory: true)
    
    @Published var fileType = UTType.png
    @Published var shaddow = true
    @Published var timeStamp = true
    @Published var useDefaultName = true
    @Published var name = ""
    @Published var pathURL = ScreenshotSettings.defaultURL
    
    var description: String {
        String("<ScreenshotSettings> pathURL: \(pathURL), fileType: \(fileType.identifier), shaddow: \(shaddow), timeStamp: \(timeStamp), useDefaultName: \(useDefaultName), name:\(name)")
    }
    
    func readUserDefaults() {
        let userDefaults = UserDefaults(suiteName: "com.apple.screencapture")!
        //        print("userDefaults: \(userDefaults.dictionaryRepresentation())")
        
        if let pathLocation = userDefaults.string(forKey: "location") {
            pathURL = URL(string: pathLocation) ?? Self.defaultURL
        }
        if let type = userDefaults.string(forKey: "type") {
            fileType = UTType(filenameExtension: type) ?? .pdf
        }
        
        shaddow = !userDefaults.bool(forKey: "disable-shadow")
        timeStamp = userDefaults.bool(forKey: "include-date")
        
        let savedName = userDefaults.string(forKey: "name")
        if let savedName {
            name = savedName
            useDefaultName = true
        }
        else {
            name = String(localized: "Screenshot")
            useDefaultName = false
        }
    }
    
    func setUpdatedUserDefaults() {
        let defaults = UserDefaults.standard
        let fileType = self.fileType.preferredFilenameExtension ?? "png"
        //    switch fileType {
        //    case "openexr":
        //        fileType = "exr"
        //    case "jpeg 2000":
        //        fileType = "jp2"
        //    case "heif":
        //        fileType = "heic"
        //    default:
        //        break
        //    }
        
        var persistentDomain: [String: Any] = ["location": pathURL.path(percentEncoded: false), "type": fileType, "include-date": timeStamp, "disable-shadow": !shaddow]
        
        if useDefaultName && name.isEmpty == false {
            persistentDomain["name"] = name
        }
        defaults.setPersistentDomain(persistentDomain, forName: "com.apple.screencapture")
        
        restartSystemUIServer()
    }
    
    func restartSystemUIServer() {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "/usr/bin/killall SystemUIServer"]
        task.launch()
    }
}

extension URL {
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
