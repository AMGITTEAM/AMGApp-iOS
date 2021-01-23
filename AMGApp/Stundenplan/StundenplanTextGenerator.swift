//
//  StundenplanTextGenerator.swift
//  AMGApp
//
//  Created by Adrian Kathagen on 22.01.20.
//  Copyright © 2021 amg-witten. All rights reserved.
//

import Foundation
import UIKit

class StundenplanTextGenerator: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
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
            textView.text = compressedBase
            print(textView.frame.size.debugDescription+" : "+textView.contentSize.height.description)
            heightConstraint.constant = textView.contentSize.height
        } catch {
            print(error.localizedDescription)
        }
    }
    @IBAction func share(_ sender: UIView) {
        let activityViewController = UIActivityViewController(activityItems: [textView.text!], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sender
        self.present(activityViewController, animated: true, completion: nil)
    }
}
