
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

class QrScanViewController: UIViewController,  AVCaptureVideoDataOutputSampleBufferDelegate,
    AVCaptureMetadataOutputObjectsDelegate{

    //    @IBOutlet weak var viewPreview: UIView!
    @IBOutlet weak var lblString: UILabel!
    @IBOutlet weak var btnStartStop: UIButton!
    @IBOutlet weak var sw: UISwitch!
//    @IBOutlet weak var scanButton: UIButton!

    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var isReading: Bool = false
    var scanRect: CGRect!
    var scanView: UIImageView!
    var dataModel: DataModel!

    var res = ""
    var scanMode = "QR"
    var message = "可选择二维码或隐形码进行扫描"


    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

//        UserDefaults.standard.set(false, forKey: "loging")

        self.basicUIinit()
        captureSession = nil;
        btnStartStop.setTitle("点击开始扫描", for: .normal)
        btnStartStop.layer.cornerRadius = 20
        lblString.text = message;
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //放的位置不对会引起bug
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }



    func basicUIinit(){
        //        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "微码溯源"
        self.view.backgroundColor = UIColor.gray


        // 扫描框范围定义
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let scanRectWidth = width - 150
        let scanRectHeight = scanRectWidth
        let scanRectX = (width - scanRectWidth) / 2
        let scanRectY = (height - scanRectHeight) / 2 - 50
        scanRect = CGRect.init(x: scanRectX, y: scanRectY, width: scanRectWidth, height: scanRectHeight)

        //        scanRect = CGRect.init(x: 50, y: 174, width: 220, height: scanRectHeight)


////        scanButton = UIButton.init(frame: scanRect)
//        scanButton.frame = scanRect
////        scanButton.setImage(UIImage.init(named: "ic_scanBg.png"), for: UIControl.State.normal)
//        scanButton.addTarget(self, action: #selector(self.startStopClick(_:)), for: UIControl.Event.touchUpInside)
//        scanButton.backgroundColor = UIColor.white
//        scanButton.backgroundColor?.withAlphaComponent(0.6)
//        self.view.addSubview(scanButton)

        scanView = UIImageView.init(image: UIImage.init(named: "ic_scanBg.png"))
        scanView.frame = scanRect
        scanView.layer.cornerRadius = 50
        self.view.addSubview(scanView)

        //switch button
        sw.transform = CGAffineTransform(scaleX: 2, y: 2)
//        sw.sizeToFit()
        sw.setOn(true, animated: true)
        sw.addTarget(self, action: #selector(self.switchChanged(_:)), for: UIControl.Event.valueChanged)
        
        self.view.addSubview(sw)

    }

    @objc func switchChanged(_ uiSwitch: UISwitch){
//        self.stopReading()
        var message = "二维码"
        scanMode = "QR"
        if(!uiSwitch.isOn){
            message = "隐形码"
            scanMode = "IV"
        }
        lblString.text = message
        print(message)
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

//    @objc func startStopClick(_ sender: UIButton) {
//        if !isReading {
//            print("start")
//            if (self.startReading()) {
//                btnStartStop.setTitle("停止扫描", for: .normal)
//                lblString.text = "正在扫描..."
//            }
//        }
//        else {
//            print("stop")
//            stopReading()
//            btnStartStop.setTitle("重新开始扫描", for: .normal)
//            lblString.text = "扫描停止"
//        }
//        isReading = !isReading
//    }


    // MARK: - Custom Method
    func startReading() -> Bool {

        // scanningUI init
        //不透明外框
//        let scanMaskLeft = CGRect.init(x: 0, y: 0, width: 100/2, height: UIScreen.main.bounds.size.height)
//        let scanMaskView = UIView.init(frame: scanMaskLeft)
//        scanMaskView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
//        //        scanMaskView.backgroundColor?.withAlphaComponent(0.6)
//
//        self.view.addSubview(scanMaskView)

//        scanView.removeFromSuperview()


//        let maskview = UIView.init(frame: self.view.bounds)
//        maskview.backgroundColor = UIColor.black.withAlphaComponent(0.1)
//        self.view.addSubview(maskview)
//        self.view.sendSubview(toBack: maskview)
//        let imageView = UIImageView.init(image: UIImage.init(named: "ic_scanBg.png"))
//        imageView.frame = scanRect
//        self.view.addSubview(imageView)


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


        if(scanMode == "QR"){
            /* Check for metadata */
            print(">>>>>>>>>>>>QRMode")
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            captureMetadataOutput.metadataObjectTypes = captureMetadataOutput.availableMetadataObjectTypes
            print(captureMetadataOutput.availableMetadataObjectTypes)

            //set delegate

            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureSession?.startRunning()
        }else{
            print(">>>>>>>>>>>IVMode")
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


    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {

        for data in metadataObjects {
            let metaData = data as! AVMetadataObject
            print(metaData.description)

            //解码接口
            let transformed = videoPreviewLayer?.transformedMetadataObject(for: metaData) as? AVMetadataMachineReadableCodeObject
            if let unwraped = transformed {
                print("unwraped:" + unwraped.stringValue)
                lblString.text = unwraped.stringValue
                btnStartStop.setTitle("开始扫描", for: .normal)
                self.performSelector(onMainThread: #selector(stopReading), with: nil, waitUntilDone: false)
                isReading = false;
                self.performSegue(withIdentifier: "qr", sender:  unwraped.stringValue)
            }
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
            let index = result.index(result.startIndex, offsetBy: 8)
            res = result.substring(from: index)
            
            let date = Date()
            let dateFormat = DateFormatter.init()
            dateFormat.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let time = dateFormat.string(from: date)
            print(time)

            dataModel.append(list: HistoryList.init(result: res, time: time))

            let alert = UIAlertController(title: "结果", message: result, preferredStyle: .alert)
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

//    @objc func toResult(){
//
//    }



//    func convert(cmage:CIImage) -> UIImage
//    {
//        let context:CIContext = CIContext.init(options: nil)
//        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
//        let image:UIImage = UIImage.init(cgImage: cgImage)
//        return image
//    }


        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if (segue.identifier == "qr"){
                let vc = segue.destination as! WebViewController
                vc.url = URL(string: sender as! String)
            }
        }

}

