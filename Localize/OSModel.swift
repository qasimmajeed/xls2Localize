//
//  OSModel.swift
//  Localize
//
//  Created by Mohamed Qasim Mohamed Majeed on 05/04/2020.
//  Copyright © 2020 Mohamed Qasim Majeed. All rights reserved.
//

import Cocoa

enum OSType : Int {
    case iOS
    case Android
}


struct  OSModel {
    var folderExtension : String = ""
    var locailzeFileExtension : String = ""
    var startNotaion : String = ""
    var endNotation : String = ""
    var type : OSType! {
        didSet{
            
            switch type {
            case .Android:
                folderExtension = ""
                locailzeFileExtension = "string.xml"
                startNotaion = "<resources>"
                endNotation = "</resources>"
            case .iOS:
                folderExtension = ".lproj"
                locailzeFileExtension = "Localizations.strings"
                startNotaion = ""
                endNotation = ""
            case .none:
                print("nothing")
            }
            
        }
    }
    
    
    
}
