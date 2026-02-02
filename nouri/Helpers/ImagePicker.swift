//
//  ImagePicker.swift
//  nouri
//
//  Created by Chan Ching Hei on 17/12/2025.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
import PhotosUI

@available(iOS 16.0, *)
struct ImagePicker: View {
    @Binding var selectedImage: PlatformImage?
    @Binding var isPresented: Bool
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            Text("Select Photo")
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = PlatformImage(data: data) {
                    selectedImage = image
                    isPresented = false
                }
            }
        }
    }
}

#elseif canImport(AppKit)
import AppKit

struct ImagePicker: View {
    @Binding var selectedImage: PlatformImage?
    @Binding var isPresented: Bool
    
    var body: some View {
        Button("Select Photo") {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false
            panel.canChooseFiles = true
            panel.allowedContentTypes = [.image]
            
            if panel.runModal() == .OK, let url = panel.url {
                if let image = NSImage(contentsOf: url) {
                    selectedImage = image
                    isPresented = false
                }
            }
        }
    }
}
#endif


