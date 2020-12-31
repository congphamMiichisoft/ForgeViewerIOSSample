//
//  ListBIMViewController.swift
//  IOSVIEWEROFFLINE
//
//  Created by CONG PHAM on 30/12/2020.
//

import UIKit

class ListBIMViewController: UIViewController {
    let semaphore = DispatchSemaphore(value: 2)
    let serial = DispatchQueue(label: "serial",attributes: .init())
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
    


}
extension ListBIMViewController: UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BIMItemCollectionViewCell.identifile, for: indexPath) as! BIMItemCollectionViewCell
        cell.indexPath = indexPath
        
//        cell.processView.progressAnimation(duration: 10, from: 0.5, percent: 1)
        serial.sync {
            cell.downloadFiles(listFile: ["https://photojournal.jpl.nasa.gov/jpeg/PIA08506.jpg"])
        }
        cell.delegate?(semaphore)
        return cell
    }
    
    
}
