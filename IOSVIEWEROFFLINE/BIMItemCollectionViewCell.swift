//
//  BIMItemCollectionViewCell.swift
//  IOSVIEWEROFFLINE
//
//  Created by CONG PHAM on 30/12/2020.
//

import UIKit

class BIMItemCollectionViewCell: UICollectionViewCell {
    
    var indexPath : IndexPath!
    var rate : Float = 0
    var delegate : ((DispatchSemaphore)->Void)?
    private let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        return formatter
    }()
    var processView : CircularProgressView!
    @IBOutlet weak var img: UIImageView!
    static let identifile : String! = {
        return "BIMItemCollectionViewCell"
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        let width = (UIScreen.main.bounds.width - 10) / 2
        contentView.widthAnchor.constraint(equalToConstant: width).isActive = true
        processView = CircularProgressView(frame: CGRect(x: 0, y: 0, width: width/8, height: width/8))
        processView.center = center
        addSubview(processView)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        img.layer.cornerRadius = 10
        img.layer.masksToBounds = true
    }
    func downloadFiles(listFile: [String]){
        let url = URL(string: "https://photojournal.jpl.nasa.gov/jpeg/PIA08506.jpg")!
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        // Don't specify a completion handler here or the delegate won't be called
        session.downloadTask(with: url).resume()
        
        
    }
    
}
extension BIMItemCollectionViewCell: URLSessionDelegate, URLSessionDownloadDelegate{
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print(location)
        
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
            try fileManager.moveItem(at: location, to: pathDow.appendingPathComponent("\(indexPath.item)" + filenew!))
        } catch {
            
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let written = byteFormatter.string(fromByteCount: totalBytesWritten)
        let expected = byteFormatter.string(fromByteCount: totalBytesExpectedToWrite)
        print("Downloaded \(indexPath.item) \(written) / \(expected)")
        
        DispatchQueue.main.async {
            
            let new =  Float(totalBytesWritten/totalBytesExpectedToWrite)
            self.processView.progressAnimation(duration: 0.1, from: 0, percent: new)
            self.rate = new
            //                self.rate = new
            //                self.progressView.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        }
    }
    
    
}

