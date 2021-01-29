//
//  TeleViewController.swift
//  IOSVIEWEROFFLINE
//
//  Created by CONG PHAM on 29/12/2020.
//

import UIKit
import Telegraph
import WebKit
import MobileCoreServices
class TeleViewController: UIViewController, UIDocumentPickerDelegate {
    var html : String!
    var tele : TelegraphDemo!
    var webview : WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        webview = WKWebView(
            frame: self.view.bounds,
            configuration: WKWebViewConfiguration()
        )
        view.addSubview(webview)
        let path = Bundle.main.path(forResource: "www/index", ofType: "html")
        html = try! String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        copyFolders()
        tele = TelegraphDemo()
        tele.start()
        loadModel()
          
    }
    func loadModel(){
        var listURL = [URL]()
        let fileMan = FileManager.default
        let docPath = fileMan.urls(for: .documentDirectory, in: .userDomainMask)
        let modelPath = docPath[0].appendingPathComponent("www/models/", isDirectory: true)
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: modelPath, includingPropertiesForKeys: nil, options: [])
            let subdirs = directoryContents.filter{ $0.hasDirectoryPath }
            let name = subdirs.first?.path.replacingOccurrences(of: modelPath.path, with: "")
            for item in subdirs {
                let files = try FileManager.default.contentsOfDirectory(at: item, includingPropertiesForKeys: nil, options: [])
                let fileSvf = files.filter{$0.pathExtension == "svf"}
                print(fileSvf)
                listURL.append(fileSvf.first!)
            }
            
            if !subdirs.isEmpty {
                let nameDraw = listURL[0].path.replacingOccurrences(of: modelPath.path, with: "")
                print(nameDraw)
                loadWebView(name: nameDraw)
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func loadWebView(name : String) {
        let htmlString = html.replacingOccurrences(of: "$$$path", with: name)
        guard let url = URL(string: "http://localhost:8080/www") else { return }
        webview.loadHTMLString(htmlString, baseURL: url)
    }
    func copyFolders() {
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory,
                                            in: .userDomainMask)
        guard documentsUrl.count != 0 else {
            return
        }
        let finalDatabaseURL = documentsUrl.first!.appendingPathComponent("www")
        print("DB does not exist in documents folder")
        let documentsURL = Bundle.main.resourceURL?.appendingPathComponent("www")
        do {
            if !FileManager.default.fileExists(atPath:(finalDatabaseURL.path))
            {
                try FileManager.default.createDirectory(atPath: (finalDatabaseURL.path), withIntermediateDirectories: false, attributes: nil)
            }
            copyFiles(pathFromBundle: (documentsURL?.path)!, pathDestDocs: finalDatabaseURL.path)
        } catch let error as NSError {
            print("Couldn't copy file to final location! Error:\(error.description)")
        }
        
    }
    
    func copyFiles(pathFromBundle : String, pathDestDocs: String) {
        let fileManagerIs = FileManager.default
        do {
            let filelist = try fileManagerIs.contentsOfDirectory(atPath: pathFromBundle)
            try? fileManagerIs.copyItem(atPath: pathFromBundle, toPath: pathDestDocs)
            
            for filename in filelist {
                try? fileManagerIs.copyItem(atPath: "\(pathFromBundle)/\(filename)", toPath: "\(pathDestDocs)/\(filename)")
            }
        } catch {
            print("\nError\n")
        }
    }
    
}
