//
//  WebServerDemoViewController.swift
//  IOSVIEWEROFFLINE
//
//  Created by CONG PHAM on 29/12/2020.
//

import UIKit
import WebKit
import GCDWebServer
class WebServerDemoViewController: UIViewController {
    var webview : WKWebView!
    var gcdWebServer : GCDWebServer!
    override func viewDidLoad() {
        super.viewDidLoad()
        gcdWebServer = GCDWebServer()
        webview = WKWebView(frame: view.bounds)
        view.addSubview(webview)
        webview.navigationDelegate = self
        loadDefaultIndexFile()
        
    }
    private func loadDefaultIndexFile() {
        let mainBundle = Bundle.main
        let folderPath = mainBundle.path(forResource: "www", ofType: nil)
        print("HTML base folder Path: \(folderPath!)")
//        self.gcdWebServer.addGETHandler(forBasePath: "/", directoryPath: folderPath!, indexFilename: "index.html", cacheAge: 0, allowRangeRequests: true)
        do {
            try gcdWebServer.start(options: [
                "Port": 8080,
                "BindToLocalhost": true
                ])
        } catch {
            // handle error
        }
//        self.webview.load(NSURLRequest(url: self.gcdWebServer.serverURL!) as URLRequest)
//        webview.loadFileURL(<#T##URL: URL##URL#>, allowingReadAccessTo: <#T##URL#>)
        
        let urlString = "http://localhost:8080/www/"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
//        webview.load(request)
//        webview.loadHTMLString(html, baseURL: url)
        runWebProject()
        
    }
    func runWebProject(){
        let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "www")!
        webview.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
                let request = URLRequest(url: url)
                webview.load(request)
    }
    

}
extension WebServerDemoViewController : WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(webview.url)
       
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print(navigationAction.request.url)
        decisionHandler(.allow)
    }
}

