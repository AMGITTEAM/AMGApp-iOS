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
    
    var stackView: UIStackView = UIStackView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        var weekday = Calendar(identifier: .gregorian).component(.weekday, from: Date())
        weekday-=1
        if(weekday == 0){
            weekday = 7
        } //1=monday, not sunday
        createStundenplan(wochentag: weekday)
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
    }
    
    @IBAction func changeWochentag(_ sender: Any) {
        let wochentag = (sender as! UISegmentedControl).selectedSegmentIndex
        
        createStundenplan(wochentag: wochentag+1)
    }
    
    func createStundenplan(wochentag: Int) {
        stackView.removeAllArrangedSubviews()
        let jsonString = UserDefaults.standard.string(forKey: "stundenplan"+wochentagToString(wochentag: wochentag))
        if(jsonString == nil){
            return
        }
        let stundenStrings: [String] = try! JSONDecoder().decode([String].self, from: (jsonString!.data(using: .utf8)!))
        let stundenModels = stundenStrings.map{StundenplanEintragModel(allString: $0)}
        stundenModels.map{
            stackView.addArrangedSubview(makeStunde(stunde: $0.stunde, fach: $0.fachName, lehrer: $0.lehrer, raum: $0.raum, moveNeunteStunde: stundenModels.count >= 10))
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
    }
    
}
