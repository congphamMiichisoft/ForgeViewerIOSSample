//
//  BIMItemCollectionViewCell.swift
//  IOSVIEWEROFFLINE
//
//  Created by CONG PHAM on 30/12/2020.
//

import UIKit

class BIMItemCollectionViewCell: UICollectionViewCell {
    var downloading : Bool = false
    var last : Float = 0
    var downloaded : Float!
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
//        contentView.widthAnchor.constraint(equalToConstant: width).isActive = true
        processView = CircularProgressView(frame: CGRect(x: 0, y: 0, width: width/8, height: width/8))
        processView.center = center
        addSubview(processView)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        img.layer.cornerRadius = 10
        img.layer.masksToBounds = true
    }
    
    
}

