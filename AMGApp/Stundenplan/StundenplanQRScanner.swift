//
//  StundenplanQRScanner.swift
//  AMGApp
//
//  Created by Adrian Kathagen on 30.12.20.
//  Copyright © 2020 amg-witten. All rights reserved.
//

import AVFoundation
import UIKit

class StundenplanQRScanner: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }

    func found(code: String) {
        let decoded = NSMutableData(base64Encoded: code, options: .ignoreUnknownCharacters)
        do {
            let decompressed = (try decoded?.decompressed(using: .zlib))!
            let string = String(decoding: decompressed, as: UTF8.self)
            let stundenplan = string.components(separatedBy: "&").map{return $0.decodeUrl()}
            
            let alert = UIAlertController(title: "Stundenplan ersetzen", message: "Bist du sicher, dass du deinen aktuellen Stundenplan komplett ersetzen möchtest?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Ja", style: .destructive, handler: { [self]_ in
                UserDefaults.standard.setValue(stundenplan[0], forKey: "stundenplanMontag")
                UserDefaults.standard.setValue(stundenplan[1], forKey: "stundenplanDienstag")
                UserDefaults.standard.setValue(stundenplan[2], forKey: "stundenplanMittwoch")
                UserDefaults.standard.setValue(stundenplan[3], forKey: "stundenplanDonnerstag")
                UserDefaults.standard.setValue(stundenplan[4], forKey: "stundenplanFreitag")
                
                dismiss(animated: true)
                self.presentingViewController?.beginAppearanceTransition(true, animated: false)
                self.presentingViewController?.endAppearanceTransition()
            }))
            present(alert, animated: true)
        } catch {
            print(error.localizedDescription)
        }
        
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
