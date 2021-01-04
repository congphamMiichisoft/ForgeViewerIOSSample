//
//  ListBIMViewController.swift
//  IOSVIEWEROFFLINE
//
//  Created by CONG PHAM on 30/12/2020.
//

import UIKit

class ListBIMViewController: UIViewController {
    let groupQueue = DispatchGroup()
    let downloader = DownloaderBim()
    let semaphore = DispatchSemaphore(value: 1)
    let serial = DispatchQueue(label: "swiftlee.serial.queue")
    let queue = DispatchQueue.global()
    var collection : UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        collection = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        view.addSubview(collection)
        collection.backgroundColor = .white
        collection.delegate = self
        collection.dataSource = self
        collection.register(UINib(nibName: BIMItemCollectionViewCell.identifile, bundle: nil), forCellWithReuseIdentifier: BIMItemCollectionViewCell.identifile)
    }
    func updateProcessIndex(indexPath : IndexPath, percent : Float){
        let cell = collection.cellForItem(at: indexPath) as! BIMItemCollectionViewCell
        cell.processView.progressAnimation(duration: 0.5, from: 0, percent: percent)
    }
    func downloadFiles(listFile: [String], totalSize : @escaping (Float)->Void){
        var nums : Int = 0
        var totalSizeFiles : Int64 = 0
        self.downloader.group = groupQueue
        self.downloader.sizeGet = {size in
            totalSizeFiles += size
            print(size, totalSizeFiles)
        }
        self.downloader.state = {index in
            nums += 1
            print("Done File",nums)
            DispatchQueue.main.async {
                self.updateProcessIndex(indexPath: IndexPath(item: 0, section: 0), percent: Float(nums/4))
            }
            
        }
        
        
        serial.sync {
            self.queue.sync {
                for item in listFile {
                    self.groupQueue.enter()
                    let url = URL(string: item)!
                    let config = URLSessionConfiguration.default
                    let session = URLSession(configuration: config, delegate: self.downloader, delegateQueue: nil)
                    downloader.getFileSize(for: url)
                    // Don't specify a completion handler here or the delegate won't be called
//                    session.downloadTask(with: url).resume()
                }
            }
        }
        
        
        
    }
    
    func downloadFileAtIndex(indexPath: IndexPath){
        let cell = collection.cellForItem(at: indexPath) as? BIMItemCollectionViewCell
        cell?.processView.progressAnimation(duration: 0, from: 0, percent: 1)
        downloadFiles(listFile: ["https://images.unsplash.com/photo-1545140976-8c17471ba12d?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D","https://www.wallpaperup.com/wallpaper/download/228439/d68a205bc54f261140fba5747fea2e7b","https://images.unsplash.com/photo-1545140976-8c17471ba12d?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D","https://www.wallpaperup.com/wallpaper/download/228439/d68a205bc54f261140fba5747fea2e7b"]) { (totalSize) in
            
        }
        groupQueue.notify(queue: .main){
            print("Done")
            cell?.processView.isHidden = true
            
        }
    }
    
    
}
extension ListBIMViewController: UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BIMItemCollectionViewCell.identifile, for: indexPath) as! BIMItemCollectionViewCell
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        downloadFileAtIndex(indexPath: indexPath)
    }
    
}
class DownloaderBim: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    var group : DispatchGroup!
    var state : ((Bool)->Void)?
    var sizeGet: ((Int64)->Void)?
    private let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        return formatter
    }()
    func getFileSize(for url: URL) {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"

        URLSession.shared.dataTask(with: request) { [weak self] (_, response, _) in
            if let response = response {
                let size = response.expectedContentLength
                self!.sizeGet?(size)
            }
        }.resume()
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print(location)
        state?(true)
        group.leave()
        let fileManager = FileManager.default
        let pathDoc = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let pathDow = pathDoc.first!.appendingPathComponent("www/models/M1",isDirectory: true)
        do
        {
            try FileManager.default.createDirectory(atPath: pathDow.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
        let filenew = downloadTask.originalRequest?.url?.lastPathComponent
        //        let savefile = pathDow.appendingPathComponent(filenew)
        do {
            //            try fileManager.moveItem(at: location, to: pathDow.appendingPathComponent("\(indexPath.item)" + filenew!))
        } catch {
            
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let written = byteFormatter.string(fromByteCount: totalBytesWritten)
        let expected = byteFormatter.string(fromByteCount: totalBytesExpectedToWrite)
        print("\(written)/\(totalBytesWritten)")
        
        DispatchQueue.main.async {
            //            self.progressView.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        }
    }
    
    
}
