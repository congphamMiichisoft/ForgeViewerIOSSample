//
//  ViewController.swift
//  IOSVIEWEROFFLINE
//
//  Created by CONG PHAM on 28/12/2020.
//

import UIKit
import WebKit
import MobileCoreServices
class ViewController: UIViewController, UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print(urls.first)
    }
    
    private var webview : WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        URLProtocol.registerClass(Interceptor.self)
        configWebView()
        configButton()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runWebProject()
    }
    override func didReceiveMemoryWarning() {
        print("Memory out")
    }
    @objc func leftAction(){
        let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText),String(kUTTypeContent),String(kUTTypeItem),String(kUTTypeData)], in: .import)
            importMenu.delegate = self
            importMenu.modalPresentationStyle = .formSheet
            self.present(importMenu, animated: true, completion: nil)
    }
    func runWebProject(){
       
        let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "BIM")!
        webview.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
                let request = URLRequest(url: url)
                webview.load(request)
        
    }
    func configButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Load", style: .done, target: self, action: #selector(leftAction))
    }
    func configWebView(){
        let preference = WKPreferences()
        preference.javaScriptCanOpenWindowsAutomatically = true
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        config.allowsAirPlayForMediaPlayback = true
        config.preferences = preference
        webview = WKWebView(frame: view.bounds,configuration: config)
        webview.navigationDelegate = self
        view.addSubview(webview)
    }
    
}
extension ViewController: WKNavigationDelegate, WKUIDelegate {
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        print("URL : \(webview.url)","Request : \(navigationAction.request)")
//        let request = navigationAction.request
//
//        decisionHandler(.allow)
//    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {

        if navigationResponse.canShowMIMEType {
            if let mimtype = navigationResponse.response.mimeType {
                print(mimtype)
            }
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
            // do something else with `navigationResponse.response`
        }
    }
    
    
}
class Interceptor: URLProtocol {
     class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        return request
    }

     class func canInitWithRequest(request: NSURLRequest) -> Bool {
        // returns true for the requests we want to intercept (*.png)
        return request.url!.pathExtension == "png"
    }

    override func startLoading() {
        // a request for a png file starts loading
        // custom response
        let response = URLResponse(url: request.url!, mimeType: "image/png", expectedContentLength: -1, textEncodingName: nil)

        if let client = self.client {
            client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

            // reply with data from a local file
            client.urlProtocol(self, didLoad: NSData(contentsOfFile: "local file path")! as Data)

            client.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {
    }
}
