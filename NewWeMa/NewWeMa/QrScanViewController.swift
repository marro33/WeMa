
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
    
    @IBOutlet weak var viewPreview: UIView!
    //@IBOutlet weak var viewPreview: UIView!
    //@IBOutlet weak var lblString: UILabel!
    
    @IBOutlet weak var lblString: UILabel!
   
    @IBOutlet weak var btnStartStop: UIButton!
    // @IBOutlet weak var btnStartStop: UIButton!
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var isReading: Bool = false
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewPreview.layer.cornerRadius = 5;
        btnStartStop.layer.cornerRadius = 5;
        captureSession = nil;
        lblString.text = "Barcode discription...";
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
        videoPreviewLayer.frame = viewPreview.layer.bounds
        viewPreview.layer.addSublayer(videoPreviewLayer)
        
//        /* Check for metadata */
//        let captureMetadataOutput = AVCaptureMetadataOutput()
//        captureSession?.addOutput(captureMetadataOutput)
//        captureMetadataOutput.metadataObjectTypes = captureMetadataOutput.availableMetadataObjectTypes
//        print(captureMetadataOutput.availableMetadataObjectTypes)
//
//        //set delegate
//
//        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
//        captureSession?.startRunning()


        //set videoDataOutput
        do{
            let videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            let queue = DispatchQueue(label: "vedioDataOutputQueue")
            videoDataOutput.setSampleBufferDelegate(self, queue: queue)
//            guard captureSession.canAddOutput(videoDataOutput) else {
//                fatalError()
//            }
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
//        self.handle1(sampleBuffer)

//        let result = ImageBufferHandler.handleTheBuffer(sampleBuffer as! CVImageBuffer)

        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        if let result = ImageBufferHandler.handleTheBuffer(imageBuffer){
//            lblString.text = result
//            btnStartStop.setTitle("Start", for: .normal)
//            self.performSelector(onMainThread: #selector(stopReading), with: nil, waitUntilDone: false)
//            isReading = false;
            print("result" + result)
        }
    }

    func handle1(_ sampleBuffer: CMSampleBuffer){
//        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        let image : UIImage = self.convert(cmage: ciimage)

//        ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:qrImage.CGImage];
//        ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
        let source = ZXCGImageLuminanceSource.init(cgImage: image.cgImage)
        let bitmap = ZXBinaryBitmap.binaryBitmap(with: ZXHybridBinarizer.init(source: source))

        let decoder = DecodeUtils.init(side: 5, andDataSize: 10)

        if let result = decoder?.decodeBitMap(bitmap as! ZXBinaryBitmap){
            lblString.text = result
            btnStartStop.setTitle("Start", for: .normal)
            self.performSelector(onMainThread: #selector(stopReading), with: nil, waitUntilDone: false)
            isReading = false;
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

