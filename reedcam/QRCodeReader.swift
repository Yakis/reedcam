//
//  QRCodeReader.swift
//  reedcam
//
//  Created by Mugurel Moscaliuc on 11/03/2022.
//

import SwiftUI
import AVFoundation
import UIKit

struct ScannerView: UIViewRepresentable {
    
    @Binding var value: String
    @State private var captureSession: AVCaptureSession? = AVCaptureSession()
    @State private var previewLayer: AVCaptureVideoPreviewLayer? = AVCaptureVideoPreviewLayer()
    
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        view.backgroundColor = UIColor.black
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return view }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return view
        }
        if let captureSession = captureSession {
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return view
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean13]
        } else {
            failed()
            return view
        }
            previewLayer?.session = captureSession
            previewLayer!.frame = view.layer.bounds
            previewLayer!.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer!)
            
            captureSession.startRunning()
        }
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {

    }
    
    
    func failed() {
        print("Your device does not support scanning a code from an item. Please use a device with a camera.")
        captureSession = nil
    }
    
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        
        @Binding var value: String
        var captureSession: AVCaptureSession?
        
        
        init(value: Binding<String>, captureSession: AVCaptureSession?) {
            self._value = value
            self.captureSession = captureSession
        }
        
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            captureSession?.stopRunning()
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                found(code: stringValue)
            }
        }
        
        
        func found(code: String) {
            value = code
        }
        
    }
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(value: $value, captureSession: captureSession)
    }
    
    
}
