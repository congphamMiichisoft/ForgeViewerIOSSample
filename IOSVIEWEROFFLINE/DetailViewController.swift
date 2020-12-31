//
//  DetailViewController.swift
//  IOSVIEWEROFFLINE
//
//  Created by CONG PHAM on 29/12/2020.
//

import UIKit
import WebKit
class DetailViewController: UIViewController {
    var initialLoadAction: WKNavigation?

    
    var webview : WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = WKWebViewConfiguration()
         let wkProcessPool = WKProcessPool()
            config.processPool = wkProcessPool
        webview = WKWebView(frame: view.bounds, configuration: config)
        view.addSubview(webview)
        runWebProject()
    }
    func runWebProject(){
        let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "BIM")!
        webview.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
                let request = URLRequest(url: url)
                webview.load(request)
    }
    

}

