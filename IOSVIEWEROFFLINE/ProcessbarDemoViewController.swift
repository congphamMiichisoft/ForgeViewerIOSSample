//
//  ProcessbarDemoViewController.swift
//  IOSVIEWEROFFLINE
//
//  Created by CONG PHAM on 30/12/2020.
//

import UIKit

class ProcessbarDemoViewController: UIViewController,URLSessionDelegate, URLSessionDownloadDelegate {
    private let byteFormatter: ByteCountFormatter = {
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useKB, .useMB]
            return formatter
        }()
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            let written = byteFormatter.string(fromByteCount: totalBytesWritten)
            let expected = byteFormatter.string(fromByteCount: totalBytesExpectedToWrite)
            print("Downloaded \(written) / \(expected)")

            DispatchQueue.main.async {
                let new =  Float(totalBytesWritten/totalBytesExpectedToWrite)
                self.circularView.progressAnimation(duration: 0, from: self.rate, percent: new)
                self.rate = new
//                self.progressView.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            }
        }
    
    var rate : Float = 0
    var circularView: CircularProgressView!
    var duration: TimeInterval!
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadImage()
        //
        circularView = CircularProgressView()
        circularView.center = view.center
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        view.addSubview(circularView)
//        circularView.progressLayer.add(<#T##anim: CAAnimation##CAAnimation#>, forKey: <#T##String?#>)
        // Do any additional setup after loading the view.
        
        
    }
    @objc func handleTap() {
        
        duration = 0   //Play with whatever value you want :]
        circularView.progressAnimation(duration: duration, from: rate, percent: rate + 0.05)
        if rate > 1 {
            rate = 0
        }else {
            rate += 0.05
        }
    }
    func downloadImage(){
        let url = URL(string: "https://photojournal.jpl.nasa.gov/jpeg/PIA08506.jpg")!

                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)

                // Don't specify a completion handler here or the delegate won't be called
                session.downloadTask(with: url).resume()
    }
    
}
import UIKit
class CircularProgressView: UIView {
    
    // First create two layer properties
    private var circleLayer = CAShapeLayer()
     var progressLayer = CAShapeLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircularPath(frameProcess: CGSize(width: frame.width, height: frame.height))
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createCircularPath(frameProcess: CGSize(width: frame.width, height: frame.height))
    }
    func createCircularPath(frameProcess : CGSize) {
        let radiusProcess = frameProcess.width
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2 ), radius: radiusProcess/2, startAngle: -.pi / 2, endAngle: 3 * .pi / 2, clockwise: true)
        let circularPath2 = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2 ), radius: radiusProcess, startAngle: -.pi / 2, endAngle: 3 * .pi / 2, clockwise: true)
        circleLayer.path = circularPath2.cgPath
        circleLayer.fillColor = (UIColor.white.withAlphaComponent(0.4)).cgColor
        circleLayer.lineCap = .round
        circleLayer.lineWidth = 0
        progressLayer.path = circularPath.cgPath
        progressLayer.lineCap = .butt
        progressLayer.lineWidth = radiusProcess
        progressLayer.fillMode = .removed
        progressLayer.strokeEnd = 0
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(circleLayer)
        layer.addSublayer(progressLayer)
    }
    func progressAnimation(duration: TimeInterval, from : Float , percent : Float) {
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        circularProgressAnimation.duration = duration
        circularProgressAnimation.fromValue = from
        circularProgressAnimation.toValue = percent
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = true
        progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
    }
}
