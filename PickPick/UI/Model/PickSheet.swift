//
//  PickSheet.swift
//  PickPick
//
//  Created by Ruben Mimoun on 02/05/2025.
//


enum PickSheet: String, Identifiable {
    
    var id: String {
        self.rawValue
    }
    
    case selectionCount
    case selectionName
}


extension String {
    func equals(pickSheet: PickSheet) -> Bool {
        self == pickSheet.rawValue
    }
    
    var sheet: PickSheet {
        guard let sheet = PickSheet(rawValue: self) else {
            fatalError("Unknown sheet \(self)")
        }
        return sheet
    }
}
