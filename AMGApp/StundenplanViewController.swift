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
    @IBOutlet weak var wochentagSelector: UISegmentedControl!
    
    @IBOutlet weak var mainEditButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var doneLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var plusStundeButton: UIButton!
    @IBOutlet weak var plusStundeLabel: UILabel!
    
    var stackView = UIStackView()
    var menuOpen = false
    var editingStundenplan = false
    var stundenModels = [[StundenplanEintragModel]]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadStundenplanFromUserdata()
        
        var weekday = Calendar(identifier: .gregorian).component(.weekday, from: Date())
        weekday-=1
        if(weekday == 0){
            weekday = 7
        } //1=monday, not sunday
        createStundenplan(wochentag: weekday-1)
        wochentagSelector.selectedSegmentIndex = weekday-1
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        self.scrollView.addSubview(stackView)
        
        scrollView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: self.scrollView, attribute: .leading, multiplier: 1.0, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal, toItem: self.scrollView, attribute: .trailing, multiplier: 1.0, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: self.scrollView, attribute: .top, multiplier: 1.0, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: self.scrollView, attribute: .bottom, multiplier: 1, constant: 0))

        scrollView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .width, relatedBy: .equal, toItem: self.scrollView, attribute: .width, multiplier: 1.0, constant: 0))
        
        
        doneButton.alpha = 0
        deleteButton.alpha = 0
        doneLabel.alpha = 0
        deleteLabel.alpha = 0
        plusStundeButton.alpha = 0
        plusStundeLabel.alpha = 0
        plusStundeLabel.layer.shadowOpacity = 0.5
    }
    
    func loadStundenplanFromUserdata(){
        for i in 0...4 {
            let jsonString = UserDefaults.standard.string(forKey: "stundenplan"+wochentagToString(wochentag: i+1))
            if(jsonString == nil){
                return
            }
            let stundenStrings: [String] = try! JSONDecoder().decode([String].self, from: (jsonString!.data(using: .utf8)!))
            stundenModels.append(stundenStrings.map{StundenplanEintragModel(allString: $0)})
        }
    }
    
    @IBAction func openCloseMenu(_ sender: Any?) {
        if(!editingStundenplan) {
            editStundenplan(nil)
        } else {
            menuOpen = !menuOpen
        }
        updateMenu()
    }
    
    func updateMenu() {
        let alpha: CGFloat = menuOpen ? 1:0
        doneButton.alpha = alpha
        deleteButton.alpha = alpha
        plusStundeButton.alpha = alpha
        doneLabel.alpha = alpha
        deleteLabel.alpha = alpha
        plusStundeLabel.alpha = alpha
        
        if(menuOpen){
            mainEditButton.setBackgroundImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        } else if(editingStundenplan){
            mainEditButton.setBackgroundImage(UIImage(systemName: "ellipsis.circle.fill"), for: .normal)
        } else {
            mainEditButton.setBackgroundImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        }
    }
    
    @IBAction func editStundenplan(_ sender: Any?) {
        editingStundenplan = !editingStundenplan
        changeWochentag(nil)
        menuOpen = false
        updateMenu()
    }
    
    @IBAction func deleteStundenplan(_ sender: Any) {
        #warning("do a confirmation before?")
        let alert = UIAlertController(title: "Stundenplan löschen", message: "Bist du sicher, dass du deinen ganzen Stundenplan löschen willst?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ja", style: .destructive, handler: { [self]_ in
            stundenModels = [[StundenplanEintragModel]]()
            for _ in 1...5 {
                stundenModels.append([StundenplanEintragModel]())
            }
            saveStundenModels()
            changeWochentag(nil)
            openCloseMenu(nil)
        }))
        present(alert, animated: true)
    }
    
    @IBAction func changeWochentag(_ sender: Any?) {
        let wochentag = wochentagSelector.selectedSegmentIndex
        
        createStundenplan(wochentag: wochentag)
    }
    
    func createStundenplan(wochentag: Int) {
        stackView.removeAllArrangedSubviews()
        stundenModels[wochentag].map{
            stackView.addArrangedSubview(makeStunde(stunde: $0.stunde, fach: $0.fachName, lehrer: $0.lehrer, raum: $0.raum, moveNeunteStunde: stundenModels[wochentag].count >= 10))
        }
        stackView.addHorizontalSeparators(color:.lightGray)
    }
    
    func makeStunde(stunde: Int, fach: String, lehrer: String, raum: String, moveNeunteStunde: Bool) -> UIView {
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
        stundenZeitLabel.attributedText = NSAttributedString(string:stundeToTime(stunde:stunde, moveNeunteStunde: moveNeunteStunde), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)])
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
        
        let editButton = UIButton()
        editButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(editButton)
        
        view.addConstraint(NSLayoutConstraint(item: editButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -10))
        view.addConstraint(NSLayoutConstraint(item: editButton, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 12))
        view.addConstraint(NSLayoutConstraint(item: editButton, attribute: .width, relatedBy: .equal, toItem: editButton, attribute: .height, multiplier: 1, constant: 0))
        
        if(editingStundenplan){
            editButton.setImage(UIImage(named: "table_edit"), for: .normal)
            editButton.contentMode = .scaleAspectFit
            editButton.contentVerticalAlignment = .fill
            editButton.contentHorizontalAlignment = .fill
            editButton.clipsToBounds = true
            editButton.layer.shadowOpacity = 0.6
            view.addConstraint(NSLayoutConstraint(item: editButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -12))
            
            editButton.addTarget(self, action: #selector(editStunde(_:)), for: .touchUpInside)
            editButton.tag = stunde
        } else {
            view.addConstraint(NSLayoutConstraint(item: editButton, attribute: .width, relatedBy: .equal, toItem: editButton, attribute: .height, multiplier: 0, constant: 0))
        }
        
        let lehrerLabel = UILabel()
        lehrerLabel.attributedText = NSAttributedString(string:String(lehrer), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        lehrerLabel.textAlignment = .right
        lehrerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lehrerLabel)
        
        view.addConstraint(NSLayoutConstraint(item: lehrerLabel, attribute: .trailing, relatedBy: .equal, toItem: editButton, attribute: .leading, multiplier: 1, constant: -10))
        view.addConstraint(NSLayoutConstraint(item: lehrerLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 0.35, constant: 0))
        
        let raumLabel = UILabel()
        raumLabel.attributedText = NSAttributedString(string:String(raum), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        raumLabel.textAlignment = .right
        raumLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(raumLabel)
        
        view.addConstraint(NSLayoutConstraint(item: raumLabel, attribute: .trailing, relatedBy: .equal, toItem: editButton, attribute: .leading, multiplier: 1, constant: -10))
        view.addConstraint(NSLayoutConstraint(item: raumLabel, attribute: .top, relatedBy: .equal, toItem: lehrerLabel, attribute: .centerY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: raumLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
        
        return view
    }
    
    var stunde: StundenplanEintragModel? = nil
    @objc func editStunde(_ sender:Any){
        stunde = stundenModels[wochentagSelector.selectedSegmentIndex][(sender as! UIButton).tag-1]
        
        self.performSegue(withIdentifier: "editStunde", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destVC = segue.destination as? StundenplanEntryViewController else{return}
        destVC.stunde = stunde
        destVC.delegate = self
    }
    
    func delete(){
        let stundeNeu = StundenplanEintragModel(stunde: stunde!.stunde, fachName: " ", fachAbk: " ", lehrer: " ", raum: " ")
        override(stundeNeu: stundeNeu)
    }
    func override(stundeNeu: StundenplanEintragModel){
        stundenModels[wochentagSelector.selectedSegmentIndex][stunde!.stunde-1] = stundeNeu
        saveStundenModels()
        changeWochentag(nil)
    }
    
    func saveStundenModels(){
        var i=0
        for tag in stundenModels {
            let jsonString = "["+tag.map{$0.toJSONString()}.joined(separator:",")+"]"
            UserDefaults.standard.set(jsonString, forKey: "stundenplan"+wochentagToString(wochentag: i+1))
            i+=1
        }
    }
    
    @IBAction func addStunde(_ sender: Any) {
        let wochentag = wochentagSelector.selectedSegmentIndex
        
        stunde = StundenplanEintragModel(stunde: stundenModels[wochentag].count+1, fachName: "", fachAbk: "", lehrer: "", raum: "")
        stundenModels[wochentag].append(stunde!)
        
        self.performSegue(withIdentifier: "editStunde", sender: self)
        openCloseMenu(nil)
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
    
    func wochentagToString(wochentag: Int) -> String{
        switch(wochentag){
        case 1:
            return "Montag"
        case 2:
            return "Dienstag"
        case 3:
            return "Mittwoch"
        case 4:
            return "Donnerstag"
        case 5:
            return "Freitag"
        default:
            return "ERROR"
        }
    }
    
    class StundenplanEintragModel {
        let stunde: Int
        let fach: String
        let lehrer: String
        let raum: String
        let fachName: String
        
        init(allString: String) {
            let all = allString.components(separatedBy: "||")
            stunde = Int(all[0]) ?? 1
            fach = all[1]
            lehrer = all[2]
            raum = all[3]
            fachName = all[4]
        }
        
        init(stunde: Int, fachName: String, fachAbk: String, lehrer: String, raum: String){
            self.stunde = stunde
            self.fachName = fachName
            self.fach = fachAbk
            self.lehrer = lehrer
            self.raum = raum
        }
        
        func toJSONString() -> String {
            var returns = "\""
            returns += String(stunde)+"||"
            returns += fach+"||"
            returns += lehrer+"||"
            returns += raum+"||"
            returns += fachName+"\""
            return returns
        }
    }
    
}
