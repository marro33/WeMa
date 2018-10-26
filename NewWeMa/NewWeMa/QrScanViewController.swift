
//
//  ViewController.swift
//  QRScan
//
//  Created by Nimble Chapps on 8/10/17.
//  Copyright © 2017 nimblechapps. All rights reserved.
//

import UIKit
import AVFoundation

//DELEGATE: AVCaptureMetaDataOutputBelegate

class QrScanViewController: UIViewController,  AVCaptureVideoDataOutputSampleBufferDelegate {

    //    @IBOutlet weak var viewPreview: UIView!
    @IBOutlet weak var lblString: UILabel!
    @IBOutlet weak var btnStartStop: UIButton!


    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var isReading: Bool = false
    var scanRect: CGRect!
    var scanView: UIImageView!
    var dataModel: DataModel!

    var res = ""



    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.basicUIinit()
        captureSession = nil;
        btnStartStop.setTitle("点击开始扫描", for: .normal)
        btnStartStop.layer.cornerRadius = 20
        lblString.text = "扫描结果";
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //放的位置不对会引起bug

        //        self.navigationController?.popToRootViewController(animated: true)

        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }



    func basicUIinit(){
        //        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "微码溯源"
        self.view.backgroundColor = UIColor.gray
        // 扫描框范围定义
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let scanRectWidth = width - 100
        let scanRectHeight = scanRectWidth
        let scanRectX = (width - scanRectWidth) / 2
        let scanRectY = (height - scanRectHeight) / 2
        scanRect = CGRect.init(x: scanRectX, y: scanRectY, width: scanRectWidth, height: scanRectHeight)

        //        scanRect = CGRect.init(x: 50, y: 174, width: 220, height: scanRectHeight)


        scanView = UIImageView.init(image: UIImage.init(named: "scanbutton.png"))
        scanView.frame = scanRect
        scanView.layer.cornerRadius = 20
        self.view.addSubview(scanView)
    }

    //    override func didReceiveMemoryWarning() {
    //        super.didReceiveMemoryWarning()
    //        // Dispose of any resources that can be recreated.
    //    }

    // MARK: - IBAction Method

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }


    @IBAction func startStopClick(_ sender: UIButton) {
        if !isReading {
            print("start")
            if (self.startReading()) {
                btnStartStop.setTitle("停止扫描", for: .normal)
                lblString.text = "正在扫描..."
            }
        }
        else {
            print("stop")
            stopReading()
            btnStartStop.setTitle("重新开始扫描", for: .normal)
            lblString.text = "扫描停止"
        }
        isReading = !isReading
    }


    // MARK: - Custom Method
    func startReading() -> Bool {

        // scanningUI init
        //不透明外框
        scanView.removeFromSuperview()

        let maskview = UIView.init(frame: self.view.bounds)
        maskview.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        self.view.addSubview(maskview)
        self.view.sendSubview(toBack: maskview)

        let imageView = UIImageView.init(image: UIImage.init(named: "ic_scanBg.png"))
        imageView.frame = scanRect
        self.view.addSubview(imageView)


        //扫描动画
        //        let animation = CABasicAnimation.init(keyPath: "transform.scale")
        //        animation.duration = 0.25
        //        animation.fromValue = 0
        //        animation.toValue = 1
        //        animation.delegate = self as! CAAnimationDelegate
        //        imageView.layer.add(animation, forKey: nil)
        //扫描显示层

        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            // Do the rest of your work...
        } catch let error as NSError {
            // Handle any errors
            print(error)
            return false
        }

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer.frame = self.view.frame
        self.view.layer.insertSublayer(videoPreviewLayer, at: 0)

        do{
            let videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            let queue = DispatchQueue(label: "vedioDataOutputQueue")
            videoDataOutput.setSampleBufferDelegate(self, queue: queue)
            captureSession?.addOutput(videoDataOutput)
            captureSession?.startRunning()
        }
        return true
    }



    func captureOutput(_ output: AVCaptureOutput, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        print("get image")

        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)

        //        let width = UIScreen.main.bounds.size.width
        //        let height = UIScreen.main.bounds.size.height

        //        print(width, height)

        // 6 plus (414, 736)

        let interestrect = videoPreviewLayer.metadataOutputRectOfInterest(for: scanRect)
        //        print(scanRect.size)
        //        print(scanRect.origin)
        print(interestrect.size.height, interestrect.size.width)

        if let result = ImageBufferHandler.handleTheBuffer(imageBuffer, interestrect){
            self.process(result)
        }
    }

    func process(_ result: String){
        if(result.hasPrefix("result: ")){

            self.stopReading()
            isReading = false


            lblString.text = result
            btnStartStop.setTitle("继续扫描", for: .normal)

            //Handle the dataModel TUDO
            dataModel = DataModel.init()
            let index = result.index(result.startIndex, offsetBy: 7)
            res = result.substring(from: index)
            
            let date = Date()
            let dateFormat = DateFormatter.init()
            dateFormat.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let time = dateFormat.string(from: date)
            print(time)

            dataModel.append(list: HistoryList.init(result: res, time: time))

            let alert = UIAlertController(title: "result", message: result, preferredStyle: .alert)
            let action = UIAlertAction (title: "OK", style: .default, handler: {
                (alerts: UIAlertAction) -> Void in

                let mainStoryboard = UIStoryboard(name:"Main", bundle:nil)
                let vc = mainStoryboard.instantiateViewController(withIdentifier: "1111") as! HistoryDetailViewController
                vc.result = self.res

                //方法1
                self.navigationController?.pushViewController(vc, animated: false)
                //方法2
                //                self.performSegue(withIdentifier: "toResult", sender: nil)

                //方法3
                //                self.present()
            })
            alert.addAction(action)
            present(alert,animated: true,completion: nil)
        }
    }

    @objc func toResult(){

    }

    func stopReading() {
        captureSession?.stopRunning()
        captureSession = nil
        videoPreviewLayer.removeFromSuperlayer()
    }


    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }


    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if (segue.identifier == "toResult"){
    //                let cv = segue.destination as! viewcontroller
    //        }
    //    }

}

