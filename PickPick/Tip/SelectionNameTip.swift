//
//  SelectionNameTip.swift
//  PickPick
//
//  Created by Ruben Mimoun on 03/05/2025.
//

import TipKit
import SwiftUI

struct SelectionNameTip: Tip {
    
//    @Parameter(.transient)
//    static var canShow: Bool = false
    
    var title: Text {
        Text("Selection")
    }
    
    var message: Text? {
        Text("Add the names of the participants.")
    }
    
    var image: Image? {
        Image(systemName: "person.3")
    }
    
//    var rules: [Rule] {
//        #Rule(Self.$canShow) { $0 == true }
//    }
}
