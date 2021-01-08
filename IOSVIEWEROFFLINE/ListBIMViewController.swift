//
//  ListBIMViewController.swift
//  IOSVIEWEROFFLINE
//
//  Created by CONG PHAM on 30/12/2020.
//

import UIKit

class ListBIMViewController: UIViewController {
    let downloader = DownloaderBim()
    var collection : UICollectionView!
    var global = DispatchQueue(label: "con",attributes: .concurrent)
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        collection = UICollectionView(frame: view.bounds, collectionViewLayout: createLayoutCollection())
        view.addSubview(collection)
        collection.backgroundColor = .white
        collection.delegate = self
        collection.dataSource = self
        collection.register(UINib(nibName: BIMItemCollectionViewCell.identifile, bundle: nil), forCellWithReuseIdentifier: BIMItemCollectionViewCell.identifile)
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    @objc func rotated() {
        
    }
    func createLayoutCollection()->UICollectionViewLayout{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.25))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSizeOritation(), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
       
//        let layout = UICollectionViewFlowLayout()
//        layout.minimumInteritemSpacing = 5
//        layout.minimumLineSpacing = 5
//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return layout
    }
    func groupSizeOritation()->NSCollectionLayoutSize{
        if UIDevice.current.orientation.isLandscape{
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalHeight(1.0), heightDimension: .fractionalWidth(0.25))
            return groupSize
        }else {
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.25))
            return groupSize
        }
    }
    
    func updateProcessIndex(indexPath : IndexPath, percent : Float){
        let cell = collection.cellForItem(at: indexPath) as! BIMItemCollectionViewCell
        cell.processView.progressAnimation(duration: 0.5, from: 0, percent: percent)
    }
    func downloadFiles(urlString: String, totalSize : @escaping (Float)->Void){
        let url = URL(string: urlString)!
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: downloader, delegateQueue: .main)
        session.downloadTask(with: url).resume()
    }
    
    func downloadFileAtIndex(indexPath: IndexPath){
        let cell = collection.cellForItem(at: indexPath) as? BIMItemCollectionViewCell
        if cell?.downloading == true {
            let alert = UIAlertController(title: "DDang dow", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (btnOK) in
                self.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }else {
            global.async {
                self.downloadFiles(urlString: "https://ftp.mozilla.org/pub/firefox/releases/56.0/mac/en-US/Firefox%2056.0.dmg") { (totalSize) in
                    
                   
                }
                cell?.downloading = true
            }
            downloader.pecent = {rate in
                
                cell?.rate = rate
                DispatchQueue.main.async {
                    cell?.processView.setPercentLoading(from: cell!.last, percent: cell!.rate)
                    cell?.last = rate
                    if rate == 1 {
                        cell?.downloading = false
                    }
                }
                print(rate)
                
            }
        }
        
        
    }
    
    
}
extension ListBIMViewController: UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 40
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BIMItemCollectionViewCell.identifile, for: indexPath) as! BIMItemCollectionViewCell
        cell.processView.setPercentLoading(from: cell.last, percent: cell.rate)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        downloadFileAtIndex(indexPath: indexPath)
    }
    
}
class DownloaderBim: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    var pecent : ((Float)->Void)?
    private let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        return formatter
    }()
    
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
            //            try fileManager.moveItem(at: location, to: pathDow.appendingPathComponent("\(indexPath.item)" + filenew!))
        } catch {
            
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let written = byteFormatter.string(fromByteCount: totalBytesWritten)
        let expected = byteFormatter.string(fromByteCount: totalBytesExpectedToWrite)
//        print("\(written)/\(expected)")
        if totalBytesExpectedToWrite != 0 {
            let rate = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            pecent?(rate)
        }
        
    }
    
    
}
