//
//  SelectionViewController.swift
//  Localize
//
//  Created by Mohamed Qasim Mohamed Majeed on 07/04/2020.
//  Copyright © 2020 Mohamed Qasim Majeed. All rights reserved.
//

import Cocoa

class SelectionViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    @IBAction func stringsToXLSXAction(_ sender : Any){
        
    }
    
    @IBAction func xlsxToStringsAction(_ sender : Any){
        
        if let myViewController = self.storyboard?.instantiateController(withIdentifier: "ViewController") as? ViewController {
            self.view.window?.contentViewController = myViewController
        }
        
    }
    
}
