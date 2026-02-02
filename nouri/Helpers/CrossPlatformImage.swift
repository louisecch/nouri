//
//  CrossPlatformImage.swift
//  nouri
//
//  Created by Chan Ching Hei on 17/12/2025.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#endif

#if canImport(AppKit)
// NSImage doesn't have jpegData natively, so we add it
extension NSImage {
    func jpegData(compressionQuality: CGFloat) -> Data? {
        guard let tiffData = self.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        return bitmap.representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
    }
}
#endif

// UIImage already has jpegData(compressionQuality:) natively, so no extension needed

