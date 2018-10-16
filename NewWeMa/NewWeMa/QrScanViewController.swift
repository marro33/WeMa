
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


    // @IBOutlet weak var btnStartStop: UIButton!
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var isReading: Bool = false
    var scanRect: CGRect!

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        viewPreview.layer.cornerRadius = 5;
//        btnStartStop.layer.cornerRadius = 5;
        self.UIinit()
        captureSession = nil;
        lblString.text = "Barcode discription...";
    }

    func UIinit(){
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

//         return buttorn
//        let btn = UIButton.init(type: UIButtonType.custom)
//        btn.frame = CGRect.init(x: 15, y: 80, width: 30, height: 30)
////        btn.setImage(UIImage.init(named: "ic_back.png"), for: UIControlState.normal)
//        btn.setTitleColor(UIColor.white, for: UIControlState.normal)
//        btn.setTitle("退出", for: UIControlState.normal)

//        btn.addTarget(self, action: , for: <#T##UIControlEvents#>)
//        self.view.addSubview(btn)
//        self.navigationController?.setNavigationBarHidden(true, animated: false)


    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBAction Method
    
    @IBAction func startStopClick(_ sender: UIButton) {
        if !isReading {
            print("start")
            if (self.startReading()) {
                btnStartStop.setTitle("Stop", for: .normal)
                lblString.text = "Scanning for QR Code..."
            }
        }
        else {
            print("stop")
            stopReading()
            btnStartStop.setTitle("Start", for: .normal)
        }
        isReading = !isReading
    }

    
    // MARK: - Custom Method
    func startReading() -> Bool {

        //不透明外框
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


    func stopReading() {
        captureSession?.stopRunning()
        captureSession = nil
        videoPreviewLayer.removeFromSuperlayer()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        print("get image")

        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)

        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height

        print(width, height)

        let scanRect_width = width - 100
        let scanRect_height = scanRect_width
        let scanRect_OrgX = (width - scanRect_width)/2
        let scanRect_OrgY = (height - scanRect_height)/2

        var scanRect = CGRect.init(x: scanRect_OrgX, y: scanRect_OrgY, width: width, height: height)

        let rect = videoPreviewLayer.metadataOutputRectOfInterest(for: scanRect)

        if let result = ImageBufferHandler.handleTheBuffer(imageBuffer, rect){
            self.process(result)
        }
    }

    func process(_ result: String){
        if(result.hasPrefix("result: ")){
            self.performSelector(onMainThread: #selector(stopReading), with: nil, waitUntilDone: false)
            isReading = false;
            lblString.text = result
            btnStartStop.setTitle("Start", for: .normal)
        }
    }


    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }

//    func handle(_ sampleBuffer: CMSampleBuffer){
//        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer){
//            //            CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0)
//            //            //  wid = 1920;  hei = 1080
//            let width = 1920
//            let height = 1080
//            //            print("%d + %d",width,height)
//            //
//            let ySize = width * height
//            let uvSize = ySize / 2
//            let yuvFrame = uvSize + ySize
//            let yFrame = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
//            let uvFrame = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1)
//
//            let yuvSize = ySize + uvSize
//            let tempDataSize = yuvSize
//
//            //            let tempData = ImageBufferHandler.handleTheBuffer(imageBuffer);
//            let tempData = ImageBufferHandler.handleTheBuffer(imageBuffer);
//
//            print("temp", tempDataSize, tempData!)
//            //            decode part
//            //            let rect = viewPreview.bounds
//            //            let targetRect = videoPreviewLayer.metadataOutputRectOfInterest(for: rect)
//            let dstLeftT:Int = 588
//            let dstTopT:Int = 168
//            let dstWidthT = 743
//            let dstHeight = 742
//
//
//            let source: MyZXPlanarYUVLuminanceSource = MyZXPlanarYUVLuminanceSource.init(yuvData: tempData, yuvDataLen: Int32(tempDataSize), dataWidth: Int32(width), dataHeight: Int32(height), left: Int32(dstLeftT), top: Int32(dstTopT), width: Int32(dstWidthT), height: Int32(height))
//
//            //            ZXBinaryBitmap bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:               [[ZXHybridBinarizer alloc] initWithSource:source]];
//
//            let bitmap = ZXBinaryBitmap.binaryBitmap(with: ZXHybridBinarizer.init(source: source))
//
//            let decoder = DecodeUtils.init(side: 5, andDataSize: 10)
//            //            let result = decoder?.decodeBitMap(bitmap as! ZXBinaryBitmap)
//
//            free(tempData)
//
//            if let result = decoder?.decodeBitMap(bitmap as! ZXBinaryBitmap){
//                lblString.text = result
//                btnStartStop.setTitle("Start", for: .normal)
//                self.performSelector(onMainThread: #selector(stopReading), with: nil, waitUntilDone: false)
//                isReading = false;
//            }
//        }
//    }

// delegate method of Metadata
//    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
//
//        for data in metadataObjects {
//            let metaData = data as! AVMetadataObject
//            print(metaData.description)
//
//            //解码接口
//            let transformed = videoPreviewLayer?.transformedMetadataObject(for: metaData) as? AVMetadataMachineReadableCodeObject
//
//            if let unwraped = transformed {
//                print("unwraped:" + unwraped.stringValue)
//                lblString.text = unwraped.stringValue
//                btnStartStop.setTitle("Start", for: .normal)
//                self.performSelector(onMainThread: #selector(stopReading), with: nil, waitUntilDone: false)
//                isReading = false;
//            }
//        }
//    }


}

