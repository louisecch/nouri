//
//  AnimatedPandaView.swift
//  nouri
//
//  Created by Chan Ching Hei on 04/02/2026.
//

import SwiftUI

#if canImport(UIKit)
import UIKit

struct AnimatedPandaView: View {
    let size: CGFloat
    
    var body: some View {
        AnimatedPandaImageView(size: size)
            .frame(width: size, height: size)
    }
}

private struct AnimatedPandaImageView: UIViewRepresentable {
    let size: CGFloat
    
    func makeUIView(context: Context) -> PandaImageContainerView {
        let containerView = PandaImageContainerView(size: size)
        
        // Load the PNG frames
        let frameImages: [UIImage] = (1...4).compactMap { frameNumber in
            UIImage(named: "panda_frame_\(frameNumber)")
        }
        
        // Configure animation
        containerView.imageView.animationImages = frameImages
        containerView.imageView.animationDuration = 1.0 // 1 second for full cycle
        containerView.imageView.animationRepeatCount = 0 // Infinite loop
        containerView.imageView.startAnimating()
        
        return containerView
    }
    
    func updateUIView(_ uiView: PandaImageContainerView, context: Context) {
        uiView.updateSize(size)
    }
}

private final class PandaImageContainerView: UIView {
    let imageView = UIImageView()
    private var fixedSize: CGFloat
    
    init(size: CGFloat) {
        self.fixedSize = size
        super.init(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: fixedSize, height: fixedSize)
    }
    
    func updateSize(_ size: CGFloat) {
        guard size != fixedSize else { return }
        fixedSize = size
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }
}

#else
// macOS fallback - simple static image
struct AnimatedPandaView: View {
    let size: CGFloat
    
    @State private var currentFrame = 1
    let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Image("panda_frame_\(currentFrame)")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .onReceive(timer) { _ in
                currentFrame = (currentFrame % 4) + 1
            }
    }
}
#endif

// Preview wrapper
struct AnimatedPandaView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedPandaView(size: 80)
            .frame(width: 100, height: 100)
    }
}
