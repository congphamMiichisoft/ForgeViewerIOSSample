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
    func fetchImage(with imageName: String)  {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        if let path = paths.first {
            let imageURL = URL(fileURLWithPath: path).appendingPathComponent(imageName)
           print("Fetch: ",imageURL)
        }
        
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print(urls.first)
        webview.evaluateJavaScript("viewer.loadModel('\(urls.first?.absoluteString)')")
        webview.reload()
    }
    func configButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Load", style: .done, target: self, action: #selector(leftAction))
    }
    var tele : TelegraphDemo!
    var webview : WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = Bundle.main.path(forResource: "www/index", ofType: "html")
         html = try! String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        copyFolders()
        configButton()
        tele = TelegraphDemo()
        tele.start()
//        loadWebView()
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
    @objc func leftAction(){
        let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText),String(kUTTypeContent),String(kUTTypeItem),String(kUTTypeData)], in: .import)
            importMenu.delegate = self
            importMenu.modalPresentationStyle = .formSheet
            self.present(importMenu, animated: true, completion: nil)
    }
    func loadWebView(name : String) {
        let htmlString = html.replacingOccurrences(of: "$$$path", with: name)
        print("File chọn : \(name)")
        webview = WKWebView(
            frame: self.view.bounds,
            configuration: WKWebViewConfiguration()
        )
        view.addSubview(webview)
        webview.navigationDelegate = self
        
        guard let url = URL(string: "http://localhost:8080/www") else { return }
        webview.loadHTMLString(htmlString, baseURL: url)
//        webview.load(URLRequest(url: url))
       
        
    }
    func copyFolders() {
        let fileManager = FileManager.default

        let documentsUrl = fileManager.urls(for: .documentDirectory,
                                            in: .userDomainMask)

        guard documentsUrl.count != 0 else {
            return // Could not find documents URL
        }

        let finalDatabaseURL = documentsUrl.first!.appendingPathComponent("www")

//        if !( (try? finalDatabaseURL.checkResourceIsReachable()) ?? false) {
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

//        } else {
//            print("Database file found at path: \(finalDatabaseURL.path)", "Bundle : \(Bundle.main)")
//
//        }

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
extension TeleViewController: WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
}

