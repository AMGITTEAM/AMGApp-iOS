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
    @IBOutlet weak var stundeLabel: UILabel!
    @IBOutlet weak var stundeZeitLabel: UILabel!
    @IBOutlet weak var fachLabel: UILabel!
    @IBOutlet weak var lehrerLabel: UILabel!
    @IBOutlet weak var raumLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    var delegate: StundenplanDay? = nil
    var currentEditButtonWidthConstraint: NSLayoutConstraint? = nil
    let vertretungStrikethrough: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.fromHexString(hexString: "#FE2E2E"), .strikethroughStyle: NSUnderlineStyle.single.rawValue, .baselineOffset: 0]
    let vertretungNew: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.fromHexString(hexString: "#04B404")]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setData(stunde: StundenplanDay.StundenplanEintragModel, moveNeunteStunde: Bool, vertretungModel: VertretungsplanViewController.VertretungModel?, delegate: StundenplanDay, editingStundenplan: Bool){
        let fach = fix(stunde.fachName)
        self.delegate = delegate
        
        stundeLabel.text = stunde.stunde.description
        
        stundeZeitLabel.attributedText = NSAttributedString(string:stundeToTime(stunde:stunde.stunde, moveNeunteStunde: moveNeunteStunde), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)])
        
        let fachLabelText = NSMutableAttributedString(string:String(fach))
        if(vertretungModel != nil && stunde.fach != vertretungModel?.getErsatzFach()){
            fachLabelText.addAttributes(vertretungStrikethrough, range: NSRange(location: 0, length: fachLabelText.length))
            if(vertretungModel?.getErsatzFach() != "---"){
                fachLabelText.append(NSAttributedString(string: (vertretungModel?.getErsatzFach())!, attributes: vertretungNew))
            }
        }
        fachLabelText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)], range: NSRange(location: 0, length: fachLabelText.length))
        fachLabel.attributedText = fachLabelText
        
        editButton.tag = stunde.stunde
        editButton.contentVerticalAlignment = .fill
        editButton.contentHorizontalAlignment = .fill
        editButton.layer.shadowOpacity = 0.6
        setEditMode(editingStundenplan, animated: false)
        
        let lehrerLabelText = generateStundenText(original: stunde.lehrer, edited: vertretungModel?.getVertretungslehrer())
        lehrerLabelText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], range: NSRange(location: 0, length: lehrerLabelText.length))
        lehrerLabel.attributedText = lehrerLabelText
        
        let raumLabelText = generateStundenText(original: stunde.raum, edited: vertretungModel?.getRaum())
        raumLabelText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], range: NSRange(location: 0, length: raumLabelText.length))
        raumLabel.attributedText = raumLabelText
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
            currentEditButtonWidthConstraint = NSLayoutConstraint(item: editButton!, attribute: .width, relatedBy: .equal, toItem: editButton, attribute: .height, multiplier: 1, constant: 0)
        } else {
            currentEditButtonWidthConstraint = NSLayoutConstraint(item: editButton!, attribute: .width, relatedBy: .equal, toItem: editButton, attribute: .height, multiplier: 0, constant: 0)
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
    @IBAction func editStunde(_ sender: Any) {
        delegate!.performSegue(withIdentifier: "editStunde", sender: sender)
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
