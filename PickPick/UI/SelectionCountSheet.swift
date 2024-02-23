//
//  SelectionCountSheet.swift
//  PickNow
//
//  Created by Ruben Mimoun on 23/02/2024.
//

import Foundation
import SwiftUI

struct SelectionCountSheet: View {
    
    @Binding var count: Int
    @Binding var show: Bool
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()

                Button(action: {
                    count += 1
                }, label: {
                    Image(systemName: "plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                        .foregroundStyle(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                        )
                })
                .frame(width: 60, height: 60)
                
                Text("\(count)")
                    .appFontStyle()
                    .font(.system(size: 50))
                    .padding()
                
                Button(action: {
                    if count > 1  {
                        count -= 1
                    }
                }, label: {
                    Image(systemName: "minus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                        .frame(width: 60, height: 60)
                        .foregroundStyle(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                        )
                })
                .frame(width: 60, height: 60)

                Spacer()
                

                
            }
            
            Button(action: {
                show = false
            }, label: {
                Text("Ok")
                    .appFontStyle()
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.2))
                    )
            })
            
            Spacer()

        }
        .background(Color.black)
    }
}


#Preview {
    SelectionCountSheet(count: .constant(1), show: .constant(true))
}
