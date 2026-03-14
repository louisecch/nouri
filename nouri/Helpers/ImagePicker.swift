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
    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Photo")
                .font(.headline)
                .padding(.top)
            
            // Camera button
            Button(action: {
                showingCamera = true
            }) {
                HStack {
                    Image(systemName: "camera.fill")
                        .font(.title2)
                    Text("Take Photo")
                        .font(.body)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            // Photo Library button
            Button(action: {
                showingPhotoPicker = true
            }) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title2)
                    Text("Choose from Library")
                        .font(.body)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            // Cancel button
            Button(action: {
                isPresented = false
            }) {
                Text("Cancel")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
            }
        }
        .padding()
        .sheet(isPresented: $showingCamera) {
            CameraPicker(selectedImage: $selectedImage, isPresented: $isPresented)
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoLibraryPicker(selectedImage: $selectedImage, isPresented: $isPresented)
        }
    }
}

// Camera picker using UIImagePickerController
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: PlatformImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

// Photo library picker using PhotosUI
struct PhotoLibraryPicker: View {
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


