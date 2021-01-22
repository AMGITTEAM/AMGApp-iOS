//
//  StundenplanDay.swift
//  AMGApp
//
//  Created by Adrian Kathagen on 22.01.21.
//  Copyright © 2021 amg-witten. All rights reserved.
//

import Foundation
import UIKit

class StundenplanDay: UIView {
    
    var delegate: StundenplanViewController
    
    required init?(coder: NSCoder) {
        delegate = StundenplanViewController() //should not happen
        super.init(coder: coder)
    }
    
    init(stunde: Int, fach: String, fachId: String, lehrer: String, raum: String, moveNeunteStunde: Bool, vertretungModel: VertretungsplanViewController.VertretungModel?, delegate: StundenplanViewController, editingStundenplan: Bool) {
        self.delegate = delegate
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 120))
        translatesAutoresizingMaskIntoConstraints = false
        let vertretungStrikethrough: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.fromHexString(hexString: "#FE2E2E"), .strikethroughStyle: NSUnderlineStyle.single.rawValue, .baselineOffset: 0]
        let vertretungNew: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.fromHexString(hexString: "#04B404")]
        
        let divider = UIView()
        divider.backgroundColor = UIColor.lightGray
        divider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(divider)
        
        addConstraint(NSLayoutConstraint(item: divider, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 0.17, constant: 0))
        addConstraint(NSLayoutConstraint(item: divider, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 0.17, constant: 1))
        addConstraint(NSLayoutConstraint(item: divider, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: divider, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        
        let stundeLabel = UILabel()
        stundeLabel.attributedText = NSAttributedString(string:String(stunde), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25)])
        stundeLabel.textAlignment = .center
        stundeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stundeLabel)
        
        addConstraint(NSLayoutConstraint(item: stundeLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: stundeLabel, attribute: .trailing, relatedBy: .equal, toItem: divider, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: stundeLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 5))
        
        let stundenZeitLabel = UILabel()
        stundenZeitLabel.attributedText = NSAttributedString(string:stundeToTime(stunde:stunde, moveNeunteStunde: moveNeunteStunde), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)])
        stundenZeitLabel.textAlignment = .center
        stundenZeitLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stundenZeitLabel)
        
        addConstraint(NSLayoutConstraint(item: stundenZeitLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 3))
        addConstraint(NSLayoutConstraint(item: stundenZeitLabel, attribute: .trailing, relatedBy: .equal, toItem: divider, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: stundenZeitLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.75, constant: 0))
        
        let fachLabel = UILabel()
        let fachLabelText = NSMutableAttributedString(string:String(fach))
        if(vertretungModel != nil && fachId != vertretungModel?.getErsatzFach()){
            fachLabelText.addAttributes(vertretungStrikethrough, range: NSRange(location: 0, length: fachLabelText.length))
            if(vertretungModel?.getErsatzFach() != "---"){
                fachLabelText.append(NSAttributedString(string: (vertretungModel?.getErsatzFach())!, attributes: vertretungNew))
            }
        }
        fachLabelText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)], range: NSRange(location: 0, length: fachLabelText.length))
        fachLabel.attributedText = fachLabelText
        fachLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(fachLabel)
        
        addConstraint(NSLayoutConstraint(item: fachLabel, attribute: .leading, relatedBy: .equal, toItem: divider, attribute: .trailing, multiplier: 1, constant: 10))
        addConstraint(NSLayoutConstraint(item: fachLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: fachLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: fachLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 10))
        addConstraint(NSLayoutConstraint(item: fachLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -10))
        
        let editButton = UIButton()
        editButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(editButton)
        
        addConstraint(NSLayoutConstraint(item: editButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -10))
        addConstraint(NSLayoutConstraint(item: editButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 12))
        addConstraint(NSLayoutConstraint(item: editButton, attribute: .width, relatedBy: .equal, toItem: editButton, attribute: .height, multiplier: 1, constant: 0))
        
        if(editingStundenplan){
            editButton.setImage(UIImage(named: "table_edit"), for: .normal)
            editButton.contentMode = .scaleAspectFit
            editButton.contentVerticalAlignment = .fill
            editButton.contentHorizontalAlignment = .fill
            editButton.clipsToBounds = true
            editButton.layer.shadowOpacity = 0.6
            addConstraint(NSLayoutConstraint(item: editButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -12))
            
            editButton.addTarget(self, action: #selector(editStunde(_:)), for: .touchUpInside)
            editButton.tag = stunde
        } else {
            addConstraint(NSLayoutConstraint(item: editButton, attribute: .width, relatedBy: .equal, toItem: editButton, attribute: .height, multiplier: 0, constant: 0))
        }
        
        let lehrerLabel = UILabel()
        let lehrerLabelText = NSMutableAttributedString(string:String(lehrer))
        if(vertretungModel != nil && lehrer != vertretungModel?.getVertretungslehrer()){
            lehrerLabelText.addAttributes(vertretungStrikethrough, range: NSRange(location: 0, length: lehrerLabelText.length))
            if(vertretungModel?.getVertretungslehrer() != "---"){
                lehrerLabelText.append(NSAttributedString(string: (vertretungModel?.getVertretungslehrer())!, attributes: vertretungNew))
            }
        }
        lehrerLabelText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], range: NSRange(location: 0, length: lehrerLabelText.length))
        lehrerLabel.attributedText = lehrerLabelText
        lehrerLabel.textAlignment = .right
        lehrerLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lehrerLabel)
        
        addConstraint(NSLayoutConstraint(item: lehrerLabel, attribute: .trailing, relatedBy: .equal, toItem: editButton, attribute: .leading, multiplier: 1, constant: -10))
        addConstraint(NSLayoutConstraint(item: lehrerLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.35, constant: 0))
        
        let raumLabel = UILabel()
        let raumLabelText = NSMutableAttributedString(string:String(raum))
        if(vertretungModel != nil && raum != vertretungModel?.getRaum()){
            raumLabelText.addAttributes(vertretungStrikethrough, range: NSRange(location: 0, length: raumLabelText.length))
            if(vertretungModel?.getRaum() != "---"){
                raumLabelText.append(NSAttributedString(string: (vertretungModel?.getRaum())!, attributes: vertretungNew))
            }
        }
        raumLabelText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], range: NSRange(location: 0, length: raumLabelText.length))
        raumLabel.attributedText = raumLabelText
        raumLabel.textAlignment = .right
        raumLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(raumLabel)
        
        addConstraint(NSLayoutConstraint(item: raumLabel, attribute: .trailing, relatedBy: .equal, toItem: editButton, attribute: .leading, multiplier: 1, constant: -10))
        addConstraint(NSLayoutConstraint(item: raumLabel, attribute: .top, relatedBy: .equal, toItem: lehrerLabel, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: raumLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
    }
    
    @objc func editStunde(_ sender:Any){
        delegate.performSegue(withIdentifier: "editStunde", sender: self)
    }
    
    func stundeToTime(stunde:Int, moveNeunteStunde:Bool) -> String {
        switch(stunde){
        case 1:
            return "7:45-8:30"
        case 2:
            return "8:30-9:15"
        case 3:
            return "9:35-10:20"
        case 4:
            return "10:20-11:05"
        case 5:
            return "11:25-12:10"
        case 6:
            return "12:15-13:00"
        case 7:
            return "13:15-14:00"
        case 8:
            return "14:00-14:45"
        case 9:
            if(moveNeunteStunde){
                return "15:00-15:45"
            } else {
                return "14:45-15:30"
            }
        case 10:
            return "15:45-16:30"
        default:
            return "ERROR"
        }
    }
}
