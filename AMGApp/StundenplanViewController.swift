//
//  StundenplanViewController.swift
//  AMGApp
//
//  Created by Adrian Kathagen on 10.12.20.
//  Copyright © 2020 amg-witten. All rights reserved.
//

import Foundation
import UIKit

class StundenplanViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let testView = makeStunde(stunde:1, fach: "Informatik", lehrer: "Ni", raum: "A104")
        let testView1 = makeStunde(stunde:2, fach: "Informatik", lehrer: "Ni", raum: "A104")
        let testViews = [testView, testView1]
        
        let stackView = UIStackView(arrangedSubviews: testViews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.addHorizontalSeparators(color:.lightGray)
        self.scrollView.addSubview(stackView)
        
        scrollView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: self.scrollView, attribute: .leading, multiplier: 1.0, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal, toItem: self.scrollView, attribute: .trailing, multiplier: 1.0, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: self.scrollView, attribute: .top, multiplier: 1.0, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: self.scrollView, attribute: .bottom, multiplier: 1, constant: 0))

        scrollView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .width, relatedBy: .equal, toItem: self.scrollView, attribute: .width, multiplier: 1.0, constant: 0))
    }
    
    func makeStunde(stunde: Int, fach: String, lehrer: String, raum: String) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let divider = UIView()
        divider.backgroundColor = UIColor.lightGray
        divider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(divider)
        
        view.addConstraint(NSLayoutConstraint(item: divider, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.17, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: divider, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.17, constant: 1))
        view.addConstraint(NSLayoutConstraint(item: divider, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: divider, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
        
        let stundeLabel = UILabel()
        stundeLabel.attributedText = NSAttributedString(string:String(stunde), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25)])
        stundeLabel.textAlignment = .center
        stundeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stundeLabel)
        
        view.addConstraint(NSLayoutConstraint(item: stundeLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: stundeLabel, attribute: .trailing, relatedBy: .equal, toItem: divider, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: stundeLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 5))
        
        let stundenZeitLabel = UILabel()
        stundenZeitLabel.attributedText = NSAttributedString(string:stundeToTime(stunde:stunde), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)])
        stundenZeitLabel.textAlignment = .center
        stundenZeitLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stundenZeitLabel)
        
        view.addConstraint(NSLayoutConstraint(item: stundenZeitLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 3))
        view.addConstraint(NSLayoutConstraint(item: stundenZeitLabel, attribute: .trailing, relatedBy: .equal, toItem: divider, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: stundenZeitLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 0.75, constant: 0))
        
        let fachLabel = UILabel()
        fachLabel.attributedText = NSAttributedString(string:String(fach), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)])
        fachLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fachLabel)
        
        view.addConstraint(NSLayoutConstraint(item: fachLabel, attribute: .leading, relatedBy: .equal, toItem: divider, attribute: .trailing, multiplier: 1, constant: 10))
        view.addConstraint(NSLayoutConstraint(item: fachLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: fachLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: fachLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 10))
        view.addConstraint(NSLayoutConstraint(item: fachLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -10))
        
        let lehrerLabel = UILabel()
        lehrerLabel.attributedText = NSAttributedString(string:String(lehrer), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        lehrerLabel.textAlignment = .right
        lehrerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lehrerLabel)
        
        view.addConstraint(NSLayoutConstraint(item: lehrerLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -10))
        view.addConstraint(NSLayoutConstraint(item: lehrerLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 0.35, constant: 0))
        
        let raumLabel = UILabel()
        raumLabel.attributedText = NSAttributedString(string:String(raum), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        raumLabel.textAlignment = .right
        raumLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(raumLabel)
        
        view.addConstraint(NSLayoutConstraint(item: raumLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -10))
        view.addConstraint(NSLayoutConstraint(item: raumLabel, attribute: .top, relatedBy: .equal, toItem: lehrerLabel, attribute: .centerY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: raumLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
        
        return view
    }
    
    func stundeToTime(stunde:Int) -> String {
        switch(stunde){
        case 1:
            return "7:45-8:30"
        case 2:
            return "8:30-9:15"
        case 3:
            return "9:35-10:20"
        case 4:
            return "10:20-11:05"
        #warning("Implement Zeiten der Stunden 5-10")
        default:
            return "ERROR"
        }
    }
    
}
