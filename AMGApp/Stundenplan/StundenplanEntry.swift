//
//  StundenplanDay.swift
//  AMGApp
//
//  Created by Adrian Kathagen on 22.01.21.
//  Copyright © 2021 amg-witten. All rights reserved.
//

import Foundation
import UIKit

class StundenplanEntry: UIView {
    
    var delegate: StundenplanDay
    var currentEditButtonWidthConstraint: NSLayoutConstraint? = nil
    var editButton: UIButton
    let vertretungStrikethrough: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.fromHexString(hexString: "#FE2E2E"), .strikethroughStyle: NSUnderlineStyle.single.rawValue, .baselineOffset: 0]
    let vertretungNew: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.fromHexString(hexString: "#04B404")]
    
    required init?(coder: NSCoder) {
        delegate = StundenplanDay() //should not happen
        editButton = UIButton()
        currentEditButtonWidthConstraint = NSLayoutConstraint()
        super.init(coder: coder)
    }
    
    init(stunde: StundenplanDay.StundenplanEintragModel, moveNeunteStunde: Bool, vertretungModel: VertretungsplanViewController.VertretungModel?, delegate: StundenplanDay, editingStundenplan: Bool) {
        self.delegate = delegate
        editButton = UIButton()
        super.init(frame: .zero)
        
        let fach = fix(stunde.fachName)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let divider = UIView()
        divider.backgroundColor = UIColor.lightGray
        divider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(divider)
        
        addConstraint(NSLayoutConstraint(item: divider, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 0.17, constant: 0))
        addConstraint(NSLayoutConstraint(item: divider, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 0.17, constant: 1))
        addConstraint(NSLayoutConstraint(item: divider, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: divider, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        
        let stundeLabel = UILabel()
        stundeLabel.attributedText = NSAttributedString(string:String(stunde.stunde), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25)])
        stundeLabel.textAlignment = .center
        stundeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stundeLabel)
        
        addConstraint(NSLayoutConstraint(item: stundeLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: stundeLabel, attribute: .trailing, relatedBy: .equal, toItem: divider, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: stundeLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 5))
        
        let stundenZeitLabel = UILabel()
        stundenZeitLabel.attributedText = NSAttributedString(string:stundeToTime(stunde:stunde.stunde, moveNeunteStunde: moveNeunteStunde), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)])
        stundenZeitLabel.textAlignment = .center
        stundenZeitLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stundenZeitLabel)
        
        addConstraint(NSLayoutConstraint(item: stundenZeitLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 3))
        addConstraint(NSLayoutConstraint(item: stundenZeitLabel, attribute: .trailing, relatedBy: .equal, toItem: divider, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: stundenZeitLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.75, constant: 0))
        
        let fachLabel = UILabel()
        let fachLabelText = NSMutableAttributedString(string:String(fach))
        if(vertretungModel != nil && stunde.fach != vertretungModel?.getErsatzFach()){
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
        
        editButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(editButton)
        
        addConstraint(NSLayoutConstraint(item: editButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -10))
        addConstraint(NSLayoutConstraint(item: editButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 12))
        addConstraint(NSLayoutConstraint(item: editButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -12))
        
        editButton.setImage(UIImage(named: "table_edit"), for: .normal)
        editButton.addTarget(self, action: #selector(editStunde(_:)), for: .touchUpInside)
        editButton.tag = stunde.stunde
        editButton.contentMode = .scaleAspectFit
        editButton.contentVerticalAlignment = .fill
        editButton.contentHorizontalAlignment = .fill
        editButton.clipsToBounds = true
        editButton.layer.shadowOpacity = 0.6
        setEditMode(editingStundenplan, animated: false)
        
        let lehrerLabel = UILabel()
        let lehrerLabelText = generateStundenText(original: stunde.lehrer, edited: vertretungModel?.getVertretungslehrer())
        lehrerLabelText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], range: NSRange(location: 0, length: lehrerLabelText.length))
        lehrerLabel.attributedText = lehrerLabelText
        lehrerLabel.textAlignment = .right
        lehrerLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lehrerLabel)
        
        addConstraint(NSLayoutConstraint(item: lehrerLabel, attribute: .trailing, relatedBy: .equal, toItem: editButton, attribute: .leading, multiplier: 1, constant: -10))
        addConstraint(NSLayoutConstraint(item: lehrerLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.35, constant: 0))
        
        let raumLabel = UILabel()
        let raumLabelText = generateStundenText(original: stunde.raum, edited: vertretungModel?.getRaum())
        raumLabelText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], range: NSRange(location: 0, length: raumLabelText.length))
        raumLabel.attributedText = raumLabelText
        raumLabel.textAlignment = .right
        raumLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(raumLabel)
        
        addConstraint(NSLayoutConstraint(item: raumLabel, attribute: .trailing, relatedBy: .equal, toItem: editButton, attribute: .leading, multiplier: 1, constant: -10))
        addConstraint(NSLayoutConstraint(item: raumLabel, attribute: .top, relatedBy: .equal, toItem: lehrerLabel, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: raumLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
    }
    
    func generateStundenText(original:String, edited:String?) -> NSMutableAttributedString {
        let string = NSMutableAttributedString(string:String(original))
        if(edited != nil && original != edited){
            string.addAttributes(vertretungStrikethrough, range: NSRange(location: 0, length: string.length))
            if(edited != "---"){
                string.append(NSAttributedString(string: edited!, attributes: vertretungNew))
            }
        }
        return string
    }
    
    func setEditMode(_ editingStundenplan: Bool, animated: Bool=true){
        if(currentEditButtonWidthConstraint != nil){
            removeConstraint(currentEditButtonWidthConstraint!)
        }
        if(editingStundenplan){
            currentEditButtonWidthConstraint = NSLayoutConstraint(item: editButton, attribute: .width, relatedBy: .equal, toItem: editButton, attribute: .height, multiplier: 1, constant: 0)
        } else {
            currentEditButtonWidthConstraint = NSLayoutConstraint(item: editButton, attribute: .width, relatedBy: .equal, toItem: editButton, attribute: .height, multiplier: 0, constant: 0)
        }
        addConstraint(currentEditButtonWidthConstraint!)
        if(animated){
            UIView.animate(withDuration: 0.5, animations: {
                self.layoutIfNeeded()
            })
        }
    }
    
    func fix(_ string: String?) -> String{
        if string != nil {
            return (string != "") ? string! : " "
        }
        return " "
    }
    
    @objc func editStunde(_ sender:Any){
        delegate.performSegue(withIdentifier: "editStunde", sender: sender)
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
