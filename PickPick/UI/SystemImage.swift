//
//  SystemImage.swift
//  PickPick
//
//  Created by Ruben Mimoun on 02/05/2025.
//

import SwiftUI

public struct SystemImage: View {
    
    let systemName: String
    let image: Image?
    
    public init(systemName: String) {
        self.systemName = systemName
        self.image = nil
    }
    
    public init(image: Image) {
        self.image = image
        self.systemName = ""
    }
    
    public var body: some View {
        if let image {
            image
                .scaledToFit()
                .foregroundColor(.white)
                .padding(4)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue)
                }
        } else {
            Image(systemName: systemName)
                .scaledToFit()
                .foregroundColor(.white)
                .padding(4)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue)
                }
        }
    }
}
