//
//  StundenplanQRGenerator.swift
//  AMGApp
//
//  Created by Adrian Kathagen on 30.12.20.
//  Copyright © 2020 amg-witten. All rights reserved.
//

import Foundation
import UIKit

class StundenplanQRGenerator: UIViewController {
    
    @IBOutlet weak var QRCodeImageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var string = (UserDefaults.standard.string(forKey: "stundenplanMontag")?.encodeUrl() ?? "")+"&"
        string += (UserDefaults.standard.string(forKey: "stundenplanDienstag")?.encodeUrl() ?? "")+"&"
        string += (UserDefaults.standard.string(forKey: "stundenplanMittwoch")?.encodeUrl() ?? "")+"&"
        string += (UserDefaults.standard.string(forKey: "stundenplanDonnerstag")?.encodeUrl() ?? "")+"&"
        string += (UserDefaults.standard.string(forKey: "stundenplanFreitag")?.encodeUrl() ?? "")
        
        do {
            let compressedData = try NSMutableData(data: string.data(using: .utf8)!).compressed(using: .zlib)
            let compressedBase = compressedData.base64EncodedString()
            let qr = generateQRCode(from: compressedBase)
            QRCodeImageView.image = qr
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 100, y: 100)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
}
