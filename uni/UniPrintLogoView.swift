//
//  UniPrintLogoView.swift
//  uni
//
//  Created by zinco.cc on 11/10/2026.
//

import SwiftUI
import AppKit

public struct UniPrintLogoView: View {
    public var size: CGFloat
    
    public init(size: CGFloat = 16) {
        self.size = size
    }
    
    public var body: some View {
        Group {
            if let logoImg = loadLogoImage() {
                Image(nsImage: logoImg)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                        .fill(Color.black)
                        .frame(width: size, height: size)
                    Text("u")
                        .font(.system(size: size * 0.65, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
        }
    }
    
    private func loadLogoImage() -> NSImage? {
        if let img = NSImage(named: "UniLogo"), img.isValid {
            return img
        }
        if let iconURL = Bundle.main.url(forResource: "AppIcon", withExtension: "png"),
           let img = NSImage(contentsOf: iconURL), img.isValid {
            return img
        }
        if let appIcon = NSApplication.shared.applicationIconImage, appIcon.isValid {
            return appIcon
        }
        return nil
    }
}
