//
//  BarcodeViewController.swift
//  Test
//
//  Created by Danielle on 1/27/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import UIKit
import AVFoundation


protocol BarcodeDelegate {
    
    func barcodeWasRead(itemDesc: String, carbohydrates: Double, quantity: Double, units: String)
}

class BarcodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var delegate: BarcodeDelegate?
    var captureSession = AVCaptureSession()
    
    var foodList = [String]()
    
    var code: String?
    var itemName: String?
    var totalCarbs: Double?
    var servingQty: Double?
    var servingUnit: String?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let videoCaptureDevice: AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
            if(self.captureSession.canAddInput(videoInput))
            {
                self.captureSession.addInput(videoInput)
            } else {
                print("Could not access camera to get video input")
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            if (self.captureSession.canAddOutput(metadataOutput))
            {
                self.captureSession.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes =
                [AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code,
                AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeQRCode]
            } else {
                print("Could not add metadata output from camera")
            }
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            let screenSize: CGRect = UIScreen.main.bounds
            let width = (screenSize.width) * 0.9
            let height = (screenSize.height) * 0.8
            let xOffset = (screenSize.width) * 0.05
            let yOffset = 80
            
            self.view.layer.addSublayer(previewLayer!)
            previewLayer?.frame = CGRect(x: xOffset, y: CGFloat(yOffset), width: width, height: height)
            self.view.layer.addSublayer(previewLayer!)
            self.captureSession.startRunning()
            
        } catch {
            print("ERROR while creating video input device")
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        for metadata in metadataObjects
        {
            let readableObject = metadata as! AVMetadataMachineReadableCodeObject
            let code = readableObject.stringValue
            
            if !(code?.isEmpty)!
            {
                self.captureSession.stopRunning()
                self.dismiss(animated: true, completion: nil)
                
                let start = code?.characters.index((code?.startIndex)!, offsetBy: 2)
                let end = code?.endIndex
                let nutritionixCode = code?[start!..<end!]
                let requestURL = URL(string: "https://api.nutritionix.com/v1_1/item?upc=\(nutritionixCode!)&appId=2e1ad004&appKey=744f09ee806ceea50112f27ef99440d3")!
                var urlRequest = URLRequest(url: requestURL)
                urlRequest.httpMethod = "GET"
                let session = URLSession.shared
                let task = session.dataTask(with: urlRequest)
                {
                    (data, response, error) -> Void in
                    
                    do
                    {
                        let jsonString = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                        self.itemName = jsonString["item_name"] as? String
                        self.servingUnit = jsonString["nf_serving_size_unit"] as? String
                        self.servingQty = jsonString["nf_serving_size_qty"] as? Double
                        self.totalCarbs = jsonString["nf_total_carbohydrate"] as? Double
                        
                        if self.itemName != nil
                        {
                            DispatchQueue.main.async
                                {
                                    self.delegate?.barcodeWasRead(itemDesc: self.itemName!, carbohydrates: self.totalCarbs!, quantity: self.servingQty!, units: self.servingUnit!)
                            }
                            print("HERE")
                        }
                        else
                        {
                            let alertNoBC = UIAlertController(title: "Barcode Scan",
                                                                 message: "Item not in food database",
                                                                 preferredStyle: .alert)
                            let ok = UIAlertAction(title: "OK", style: .default, handler: {alert -> Void in})
                            alertNoBC.addAction(ok)
                            self.present(alertNoBC, animated: true, completion: nil)
                            
                            self.performSegue(withIdentifier: "noScan", sender: self)
                            print("NOT HERE")
                        }
        
                    }catch {
                        print("json error")
                        self.performSegue(withIdentifier: "noScan", sender: self)
                    }
                }
                task.resume()
            }
        }
    }

}
