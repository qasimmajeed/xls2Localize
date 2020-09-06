//
//  ViewController.swift
//  Localize
//
//  Created by Mohamed Qasim Mohamed Majeed on 05/04/2020.
//  Copyright © 2020 Mohamed Qasim Majeed. All rights reserved.
//

import Cocoa
import CoreXLSX

extension NSTextView {
    func append(string: String, withColor : NSColor = NSColor.white) {
       
        let attributeString = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor : withColor])
        self.textStorage?.append(attributeString)
        self.scrollToEndOfDocument(nil)
    }
}

extension String {
    
    
    fileprivate func attributed(with name:String) -> NSMutableAttributedString {
        let  attribute = [NSAttributedString.Key.foregroundColor : NSColor.red]
        let output = NSMutableAttributedString(string: name + ":   ", attributes: attribute)
        output.append(NSMutableAttributedString(string: self))
        return output
    }
}



class ViewController: NSViewController {
    
    
    @IBOutlet var stack : NSStackView!
    @IBOutlet var fileNameLabel : NSTextField!
    @IBOutlet var osSelectionControl : NSSegmentedControl!
   
    
    @IBOutlet var outputTextView : NSTextView!
    @IBOutlet var outputTextViewHeightConstraint : NSLayoutConstraint!
    
    private var os : OSModel = OSModel()
    
    private var seletedFilePath : URL!
    private var savePath : URL!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        
        // Do any additional setup after loading the view.
    }
    
    private func setupUI(){
        self.stack.isHidden = true
        self.osSelectionControl.selectedSegment = 0
        self.osSelectionControl.action = #selector(osSegmentControlAction(_:))
        self.os.type = OSType(rawValue: self.osSelectionControl.selectedSegment)
        self.outputTextView.string = ""
        
        
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func osSegmentControlAction(_ sender : NSButton!){
        self.os.type = OSType(rawValue: self.osSelectionControl.selectedSegment)
        
    }
    
    
    @IBAction func openFileAction(_ sender : NSButton!){
        let openFileDialoge = NSOpenPanel()
        openFileDialoge.allowedFileTypes = ["xlsx"]
        
        if (openFileDialoge.runModal() == .OK) {
            let result = openFileDialoge.url
            if (result != nil) {
                self.seletedFilePath = result
                self.fileNameLabel.stringValue = self.seletedFilePath.lastPathComponent
                self.stack.isHidden = false
                
            }
        } else {
            // User clicked on "Cancel"
            return
        }
        
    }
    
    @IBAction func convertAction(_ sender : NSButton!){
        
        let openFileDialoge = NSOpenPanel()
        openFileDialoge.canChooseDirectories = true
        openFileDialoge.canCreateDirectories = true
        
        if (openFileDialoge.runModal() == .OK) {
            let result = openFileDialoge.url
            if (result != nil) {
                self.savePath = result
                self.performXLS(self.seletedFilePath)
                
                
            }
        } else {
            
            return
        }
        
        
    }
    
    func isValide(rows : Row) -> (Bool , Int) {
        let count = rows.cells.count - 1
        var flag = true
        
        if count < 1 {
            flag = false
        }
        return (flag, count)
        
    }
    
    
    func performXLS(_ filePath : URL)  {
        guard let file = XLSXFile(filepath: filePath.path) else {
            fatalError("XLSX file corrupted or does not exist")
        }
        self.outputTextView.string = ""
        var osStringFiles : [[String]] = [[String]]()
        var stringFileNames : [String] = [String]()
        for path in try! file.parseWorksheetPaths() {
            let ws = try! file.parseWorksheet(at: path)
            let sharedStrings = try! file.parseSharedStrings()
            
            let validate = self.isValide(rows: (ws.data?.rows.first)!)
            if validate.0 == true {
                osStringFiles = [[String]](repeating: [String](), count: validate.1)
                var rowIndex = 0
                
                for row in ws.data?.rows ?? [] {
                    let columnCStrings = row.cells
                        .filter { $0.type == "s" }
                        .compactMap { $0.value }
                        .compactMap { Int($0) }
                        .compactMap { sharedStrings.items[$0].text }
                    if rowIndex != 0 {
                        if columnCStrings.count > 0 && ( (columnCStrings.count - 1) == validate.1 ){
                            for i  in 1...validate.1 {
                                osStringFiles[i - 1].append(makeStringByType(columnCStrings[0], valueParam: columnCStrings[i]))
                            }
                        }else{
                            self.outputTextView.append(string: "missing translation at row -> " + "\(rowIndex + 1)" + "\n",withColor: NSColor.red)
                        }
                        
                        
                    }else{
                        self.outputTextView.append(string: "...............In Progress...............\n" ,withColor: NSColor.green)
                       
                        for i in 1..<columnCStrings.count {
                            stringFileNames.append(columnCStrings[i])
                        }
                    }
                    
                    rowIndex += 1
                    
                }
                
            }else {
                let alert = NSAlert()
                alert.messageText = "InValid! XLSX file format"
                alert.runModal()
                return
            }
            
            
        }
        
        
        
        
        var isFail : Bool = false
        for i in 0..<stringFileNames.count {
            let filePath = self.savePath.path + "/" +  stringFileNames[i] + self.os.folderExtension
            if self.writeDirectoryWithName(filePath){
                if self.os.startNotaion != "" {
                    osStringFiles[i].insert(self.os.startNotaion, at: 0)
                }
                
                if self.os.endNotation != "" {
                    osStringFiles[i].append(self.os.endNotation)
                }
                
                
                let strings = osStringFiles[i].joined(separator: "\n")
                self.writeFileWithName( filePath + "/\(self.os.locailzeFileExtension)", data: strings.data(using: .utf8)!)
            }else {
                
                self.outputTextView.append(string: "...............problem while directory creating...............\n" ,withColor: NSColor.red)
                isFail = true
                break
            }
        }
        
        
         //self.outputTextView.string += "...............Finish...............\n"
        self.outputTextView.append(string: "...............Finish...............",withColor: NSColor.green)
        self.outputTextViewHeightConstraint.constant = 150
        if !isFail{
            NSWorkspace.shared.open(self.savePath)
        }
        
        
        
    }
    
   
    
    
    func makeStringByType(_ keyParam : String , valueParam : String) -> String {
        if self.os.type == .iOS {
            var key = "\""
            key +=  keyParam
            key += "\""
            var value  = "\""
            value +=  valueParam
            value += "\""
            return key + " = " + value + ";"
            
            
        }else {
            var outputString = "<string name="
            outputString += "\""
            outputString +=  keyParam
            outputString += "\""
            outputString += ">"
            outputString += valueParam
            outputString += "</string>"
            return outputString
            
        }
        
        
        
    }
    
    func writeFileWithName(_ path : String , data : Data){
        let  manager = FileManager.default
        do
        {
            
            manager.createFile(atPath: path, contents: data, attributes: nil)
            
            
            
        }
        
    }
    
    
    func writeDirectoryWithName(_ path : String) -> Bool{
        
        do {
            try FileManager.default.createDirectory(atPath:path, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            print(error.localizedDescription);
             return false
        }
       
        
    }
    
}

