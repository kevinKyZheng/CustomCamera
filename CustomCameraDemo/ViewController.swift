//
//  ViewController.swift
//  CustomCameraDemo
//
//  Created by ios on 2018/10/19.
//  Copyright © 2018年 KY. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var session:AVCaptureSession?
    var videoInput:AVCaptureDeviceInput?
    var photoOutput:AVCaptureStillImageOutput?
    var previewLayer:AVCaptureVideoPreviewLayer?
    let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        session?.startRunning()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        session?.stopRunning()
    }
    func setupCamera(){
        do{
            //初始化输入,输出
            session = AVCaptureSession()
            
            let device = AVCaptureDevice.default(for: .video)
            videoInput = try AVCaptureDeviceInput(device: device!)
            
            photoOutput = AVCaptureStillImageOutput()
            let outPutsetting = [AVVideoCodecKey : AVVideoCodecJPEG]
            photoOutput?.outputSettings = outPutsetting
            
            session?.addInput(videoInput!)
            session?.addOutput(photoOutput!)
            //预览图层
            previewLayer = AVCaptureVideoPreviewLayer(session: session!)
            previewLayer?.videoGravity = .resizeAspectFill
            previewLayer?.frame = view.bounds
            view.layer.addSublayer(previewLayer!)
            //初始化工具条
            setupToolbar()
        }catch{
           //没有摄像头权限
            print("没有摄像头权限")
        }
    }
    
    func setupToolbar(){
        let snapBtn = UIButton.init(type: .custom)
        snapBtn.setImage(UIImage.init(named: "snap_button"), for: .normal)
        snapBtn.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        snapBtn.frame = CGRect(x: 0, y: 0, width: 49, height: 49)
        view.addSubview(snapBtn)
    }
    
    @objc func takePhoto(){
        let photoConnect = photoOutput?.connection(with: .video)
        photoOutput?.captureStillImageAsynchronously(from: photoConnect!, completionHandler: { (imageData, error) in
            let jpegData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageData!)
            let image = UIImage(data: jpegData!)?.fixOrientation()
            
            //剪裁图片
            let resultImageView = UIImageView.init(image: image)
            resultImageView.frame = CGRect(x:0,y:0,width:self.SCREEN_WIDTH,height:self.SCREEN_HEIGHT - 64 - 70)
            resultImageView.isHidden = true
            self.view.addSubview(resultImageView)
            
            var rect = CGRect(x:0,y:0,width:self.SCREEN_WIDTH,height:self.SCREEN_HEIGHT - 64 - 70)
            rect.origin.y += 10
            rect.size.height -= 20
            let clipImage = self.cropImage(resultImageView.image!, toRect: rect, baseImgView: resultImageView)
        })
    }
    
    //剪裁图片
    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect,baseImgView:UIView) -> UIImage?{
        let imageViewScale = max(inputImage.size.width/baseImgView.frame.size.width, inputImage.size.height/baseImgView.frame.size.height)
        
        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                              y:cropRect.origin.y * imageViewScale,
                              width:cropRect.size.width * imageViewScale,
                              height:cropRect.size.height * imageViewScale)
        
        let cgImage = inputImage.cgImage
        let resultImage = cgImage?.cropping(to: cropZone)
        return UIImage(cgImage: resultImage!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

