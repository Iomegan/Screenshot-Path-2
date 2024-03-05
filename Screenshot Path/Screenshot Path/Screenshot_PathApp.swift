//
//  Screenshot_PathApp.swift
//  Screenshot Path
//
//  Created by Daniel Witt on 04.03.24.
//

import AboutView
import SwiftUI
import TipKit

@main
struct Screenshot_PathApp: App {
    let aboutViewModel = AboutViewModel(productPageURL: URL(string: "https://www.witt-software.com/screenshotpath")!, appIconCreator: nil, appIconCreatorURL: nil, appStoreID: nil, showAppStoreRateButton: false)

    
    init() {
        if #available(macOS 14.0, *) {
            try? Tips.configure()
        }
    }

    
    var body: some Scene {
        Window("Screenshot Path", id: "main-window") {
            VStack(spacing: 0) {
                Text(verbatim: "Screenshot Path")
                    .font(.title2.bold())
//
                ContentView()
            }
            .fixedSize()
            .background(Color.specialWindowBackground)
            .padding(.top, -10)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button("About \(Bundle.main.appName)") {
                    aboutViewModel.showAboutWindow()
                }
            }
        }
    }
}
