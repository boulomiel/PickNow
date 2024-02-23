//
//  SelectionCountTip.swift
//  PickNow
//
//  Created by Ruben Mimoun on 23/02/2024.
//

import Foundation
import TipKit

struct SelectionCountTip: Tip {
    
    @Parameter(.transient)
    static var canShow: Bool = false
    
    var title: Text {
        Text("Selection")
    }
    
    var message: Text? {
        Text("Define how many participant should be selected.")
    }
    
    var image: Image? {
        Image(systemName: "person.3")
    }
    
    var rules: [Rule] {
        #Rule(Self.$canShow) { $0 == true }
    }
}
