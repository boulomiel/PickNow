//
//  RemoveTip.swift
//  PickNow
//
//  Created by Ruben Mimoun on 23/02/2024.
//

import Foundation
import TipKit

struct RemoveTip: Tip {
        
    var title: Text {
        Text("Remove participant")
    }
    
    var message: Text? {
        Text("You can remove a participant by long pressing on a color.")
    }
}
