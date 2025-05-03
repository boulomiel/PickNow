//
//  SelectionCountSheet.swift
//  PickNow
//
//  Created by Ruben Mimoun on 23/02/2024.
//

import Foundation
import SwiftUI

struct SelectionCountSheet: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var count: Int
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                plusButton
                countLabel
                minusButton
    
                Spacer()
            }
            okButton
            Spacer()
        }
        .background(Color.black)
    }
    
    var countLabel: some View {
        Text("\(count)")
            .appFontStyle()
            .font(.system(size: 50))
            .padding()
    }
    
    var plusButton: some View {
        Button(action: {
            count += 1
        }, label: {
            imageButton("plus")
        })
        .frame(width: 60, height: 60)
    }
    
    var minusButton: some View {
        Button(action: {
            if count > 1  {
                count -= 1
            }
        }, label: {
            imageButton("minus")
        })
        .frame(width: 60, height: 60)
    }
    
    var okButton: some View {
        Button(action: {
            dismiss.callAsFunction()
        }, label: {
            Text("Ok")
                .appFontStyle()
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.2))
                )
        })
    }
    
    
    func imageButton(_ name: String) -> some View {
        Image(systemName: name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding()
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue)
                    .frame(width: 60, height: 60)
            )
    }
}


#Preview {
    SelectionCountSheet(count: .constant(1))
}
