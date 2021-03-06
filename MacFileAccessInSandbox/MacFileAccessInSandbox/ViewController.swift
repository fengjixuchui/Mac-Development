//
//  ViewController.swift
//  MacFileAccessInSandbox
//
//  Created by kongyulu on 2020/6/7.
//  Copyright © 2020 kongyulu. All rights reserved.
//

import Cocoa

let LastSaveFilePathKey = "LastSaveFilePathKey"

class ViewController: NSViewController {

    @IBOutlet weak var btnOpen: NSButton!
    @IBOutlet weak var btnSave: NSButton!
    @IBOutlet weak var filePathField: NSTextField!
    @IBOutlet weak var textScrollView: NSScrollView!
    @IBOutlet var textV: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    @IBAction func openFileAction(_ sender: Any) {
        openFile()
    }
    
    @IBAction func saveFileAction(_ sender: Any) {
        saveFile()
    }
    
}

extension ViewController {
    
    fileprivate func initData() {
        guard let path = UserDefaults.standard.value(forKey: LastSaveFilePathKey) as? String else {
            return
        }
        filePathField.stringValue = path
        let url = URL(fileURLWithPath: path)
        do {
            let text = try String(contentsOf: url)
            textV.string = text
        } catch {
        }
        
    }
    
    /// 打开文件
    fileprivate func openFile() {
        let openPanel = NSOpenPanel()
        openPanel.prompt = "Open"
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = true
        openPanel.resolvesAliases = true
        openPanel.nameFieldLabel = "Open File"
        openPanel.title = "Open"
        openPanel.allowedFileTypes = ["txt"]
        openPanel.begin { (response) in
            if response == .OK {
                let urls = openPanel.urls
                for url in urls {
                    //UserDefaults.standard.set(url, forKey: LastSaveFilePathKey)
                    UserDefaults.standard.set(url.path, forKey: LastSaveFilePathKey)
                    UserDefaults.standard.synchronize()
                    self.filePathField.stringValue = url.path
                    
                    let text = try? String(contentsOf: url, encoding: .utf8 )
                    self.textV.string = text ?? ""
                }
            }
        }
    }
    
    
    /// 保存文件
    fileprivate func saveFile() {
        guard let path = UserDefaults.standard.value(forKey: LastSaveFilePathKey) as? String else {
            return
        }
        
        let text =  textV.string
        debugPrint("text=\(text)")
        let url = URL(fileURLWithPath: path)
        do {
            try text.write(to: url, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
        
    }
}

