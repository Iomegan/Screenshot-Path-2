//
//  FilePathView.swift
//  Screenshot Path
//
//  Created by Daniel Witt on 04.03.24.
//

import SwiftUI

struct FilePathView: View {
    @Binding var url: URL
    @State private var folderIcon = NSImage(named: "BigSur_Desktop")!
    @State private var targetsPath = false
    @State private var pasteProgress: Progress?

    var body: some View {
        HStack {
            Label(
                title: {
                    Text(self.url.deletingPathExtension().path(percentEncoded: false))
                },
                icon: {
                    Image(nsImage: self.folderIcon)
                        .resizable()
                        .frame(width: 32, height: 32)
                }
            )
            .opacity(targetsPath ? 0.25 : 1.0)
            .animation(.easeInOut, value: targetsPath)
            Spacer()
        }
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity)
        .onDrop(of: [.fileURL], isTargeted: self.$targetsPath, perform: { itemProviders, _ in
            for item in itemProviders {
                self.pasteProgress = item.loadObject(ofClass: URL.self) { url, error in
                    if let error {
                        NSLog("WARNING: #rgutfEsd -\(error.localizedDescription)")
                        __NSBeep()

                        return
                    }
                    if let url {
                        DispatchQueue.main.sync {
                            if url.isDirectory {
                                self.url = url
                            }
                            else {
                                __NSBeep()
                            }
                        }
                    }
                    else {
                        __NSBeep()
                    }
                }
            }
            return true
        })
        .onAppear {
            self.folderIcon = NSWorkspace.shared.icon(forFile: self.url.path(percentEncoded: false))
        }
        .onChange(of: self.url) { _ in
            self.folderIcon = NSWorkspace.shared.icon(forFile: self.url.path(percentEncoded: false))
        }
    }
}
