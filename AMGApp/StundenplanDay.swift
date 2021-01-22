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
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(wochentag: Int, vertretungsplanModel: VertretungsplanViewController.VertretungModelArrayModel?, editingStundenplan: Bool, delegate: StundenplanViewController){
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        addConstraint(NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: scrollView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        scrollView.addSubview(stackView)
        
        scrollView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1.0, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1, constant: 0))
        
        scrollView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1.0, constant: 0))
        
        
        let jsonString = UserDefaults.standard.string(forKey: "stundenplan"+wochentagToString(wochentag: wochentag)) ?? ""
        print(wochentagToString(wochentag: wochentag)+" = "+jsonString)
        do {
            let stundenStrings = try JSONDecoder().decode([String].self, from: (jsonString.data(using: .utf8)!))
            var stunden = stundenStrings.map{StundenplanViewController.StundenplanEintragModel(allString: $0)}
            stunden.sort(by: {return $0.stunde < $1.stunde})
            
            stackView.removeAllArrangedSubviews()
            stunden.forEach{stunde in
                let vertretungModel = vertretungsplanModel?.getRightRows().first(where: {vModel in
                    if(vModel.getStunde().contains(" - ")){ //erstreckt sich über mehrere Stunden
                        return vModel.getStunde().components(separatedBy: " - ").contains(where: {stundeNr in
                            return (Int(stundeNr) == stunde.stunde && vModel.getFach() == stunde.fach)
                        })
                    }
                    return (Int(vModel.getStunde()) == stunde.stunde && vModel.getFach() == stunde.fach)
                })
                
                stackView.addArrangedSubview(StundenplanEntry(stunde: stunde.stunde, fach: stunde.fachName, fachId: stunde.fach, lehrer: stunde.lehrer, raum: stunde.raum, moveNeunteStunde: stunden.count >= 10, vertretungModel: vertretungModel, delegate: delegate, editingStundenplan: editingStundenplan))
            }
            stackView.addHorizontalSeparators(color:.lightGray)
        } catch {
            return
        }
    }
    
    func wochentagToString(wochentag: Int) -> String{
        switch(wochentag){
        case 0:
            return "Montag"
        case 1:
            return "Dienstag"
        case 2:
            return "Mittwoch"
        case 3:
            return "Donnerstag"
        case 4:
            return "Freitag"
        default:
            return "ERROR"
        }
    }
    
}
