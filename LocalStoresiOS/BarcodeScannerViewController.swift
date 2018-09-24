//
//  BarcodeScannerViewController.swift
//  LocalStoresiOS
//
//  Created by Juan Murillo on 4/10/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var found: Bool?
    let supportedCodeTypes = [AVMetadataObjectTypeUPCECode,
                              AVMetadataObjectTypeCode39Code,
                              AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeCode93Code,
                              AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypeEAN8Code,
                              AVMetadataObjectTypeEAN13Code,
                              AVMetadataObjectTypeAztecCode,
                              AVMetadataObjectTypePDF417Code,
                              AVMetadataObjectTypeQRCode,
                              AVMetadataObjectTypeITF14Code,
                              AVMetadataObjectTypeInterleaved2of5Code,
                              AVMetadataObjectTypeDataMatrixCode]
    @IBOutlet weak var msgLabel: UILabel!
    override func viewWillAppear(_ animated: Bool) {
        self.found = false
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        

        let firstTime = UserDefaults.standard.bool(forKey: "firstTime")
        if firstTime == false {
            self.showAlertWithTitle(title: "Add product", message: "Here you can add a product scanning its barcode or qr code")
            UserDefaults.standard.set(true, forKey: "firstTime")
        }
        
        // Do any additional setup after loading the view.
        found = false
        
        //SET AUTO FOCUS
        
        //get instance of phone camera
        //try to enable auto focus
       
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if(captureDevice!.isFocusModeSupported(.continuousAutoFocus)) {
            try! captureDevice!.lockForConfiguration()
            captureDevice!.focusMode = .continuousAutoFocus
            captureDevice!.unlockForConfiguration()
        }
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
//            AVMetadataObjectTypeUPCECode
            
            //READING THE QR CODE

            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            showAlertWithTitle(title: "Camera Error", message: "An error occurred using your camera, Please make sure your camera is working and that you allowed our app to use it. If you did not allowed the app to use your Camera you have to do manually in Settings>General>LocalStores and enable the Camera.")
            return
        }
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        // Start video capture.
        captureSession?.startRunning()
        // Move the message label and top bar to the front
        self.view.bringSubview(toFront: msgLabel)
        
    
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if currentReachabilityStatus != .notReachable {
            // Check if the metadataObjects array is not nil and it contains at least one object.
            if metadataObjects == nil || metadataObjects.count == 0 || found! {
                qrCodeFrameView?.frame = CGRect.zero
                msgLabel.text = "No QR/barcode is detected"
                return
            }
            
            // Get the metadata object.
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if supportedCodeTypes.contains(metadataObj.type) {
                // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
                let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
                qrCodeFrameView?.frame = barCodeObject!.bounds
                
                if metadataObj.stringValue != nil {
                    
                    msgLabel.text = metadataObj.stringValue
                    do {
                        if (msgLabel.text?.contains("//"))! {
                            showAlertWithTitle(title: "Error", message: "URLs are not allowed. Try again with a valid Barcode or QRCode.")
                            return
                        }
                        if let len = msgLabel.text?.count {
                            if len > 15  {
                                showAlertWithTitle(title: "Error", message: "Please scan a valid barcode/qrcode. This one is too large and has \(len) digits. Try again with a valid barcode with less than 16 digits.")
                                return
                            }
                            else if len == 0{
                                showAlertWithTitle(title: "Error", message: "Please scan a valid barcode/qrcode. This one is empty and has \(len) digits. Try again with a valid barcode with less than 16 digits and more than 0.")
                                return
                            }
                        }
                        print("before probably crash")
                        let code = msgLabel.text!
                        print("after probably crash")
                        
                        
                        let i = checkGPSPermission()
                        if i != 1 {
                            showAlertWithTitle(title: "Error", message: "There are no GPS permissions. Enable the GPS permission in Settings/General/LocalStores")
                        }
                        else {
                            self.performSegue(withIdentifier: "showProductDetails", sender: String(describing: code))
                            found = true
                        }
                    } catch {
                        showAlertWithTitle(title: "Error", message: "\(error)" )
                        return
                        
                    }
                    
                }
            }
        } else {
            msgLabel.text = "Your network status is not reachable."
            self.showAlertWithTitle(title: "Error", message: "Your network status is not available. So, you are not able to edit or add products. Check your mobile network or your wifi connection.")
            
            return
        }
        
    }
    
    func showAlertWithTitle(title: String, message: String){
        let alertVC = UIAlertController(title: title,message: message, preferredStyle: .alert )
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertVC.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProductDetails" {
            let destinationCtrl = segue.destination as! SetProductViewController
            destinationCtrl.textCode = sender as? String
        }
    }
    @IBAction func info(_ sender: Any) {
         self.showAlertWithTitle(title: "Add product", message: "Here you can add a product scanning its barcode or qr code")
    }
    

}
