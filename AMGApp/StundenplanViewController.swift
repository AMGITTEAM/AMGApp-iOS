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
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var wochentagSelector: UISegmentedControl!
    
    @IBOutlet weak var mainEditButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var doneLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var plusStundeButton: UIButton!
    @IBOutlet weak var plusStundeLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sendLabel: UILabel!
    
    var menuOpen = false
    var editingStundenplan = false
    var stundenModels = [[StundenplanEintragModel]]()
    
    var vertretungHeute: VertretungsplanViewController.VertretungModelArrayModel? = nil
    var vertretungFolgetag: VertretungsplanViewController.VertretungModelArrayModel? = nil
    
    var days = [StundenplanDay]()
    let dayView = UIView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        stundenModels.removeAll()
        loadStundenplanFromUserdata()
        
        var weekday = getWeekday()
        if(weekday >= 5) {
            weekday = 0
        }
        
        rebuildDays()
        mainView.insertSubview(dayView, belowSubview: mainEditButton)
        mainView.addConstraint(NSLayoutConstraint(item: dayView, attribute: .top, relatedBy: .equal, toItem: wochentagSelector, attribute: .bottom, multiplier: 1, constant: 0))
        mainView.addConstraint(NSLayoutConstraint(item: dayView, attribute: .leading, relatedBy: .equal, toItem: mainView, attribute: .leading, multiplier: 1, constant: 0))
        mainView.addConstraint(NSLayoutConstraint(item: dayView, attribute: .trailing, relatedBy: .equal, toItem: mainView, attribute: .trailing, multiplier: 1, constant: 0))
        mainView.addConstraint(NSLayoutConstraint(item: dayView, attribute: .bottom, relatedBy: .equal, toItem: mainView, attribute: .bottom, multiplier: 1, constant: 0))
        
        dayView.translatesAutoresizingMaskIntoConstraints = false
        wochentagSelector.selectedSegmentIndex = weekday
        changeWochentag(nil)
        //to bottom of weekday
        
        updateMenu()
        
        if(UserDefaults.standard.string(forKey: "login") != nil && UserDefaults.standard.string(forKey: "klasse") != nil){
            DispatchQueue.init(label: "network").async { [self] in
                editStundenplanByVertretungsplan(username: UserDefaults.standard.string(forKey: "loginUsername")!, password: UserDefaults.standard.string(forKey: "loginPassword")!, klasse: UserDefaults.standard.string(forKey: "klasse")!)
                DispatchQueue.main.async {
                    changeWochentag(nil)
                }
            }
        }
    }
    
    func rebuildDays() {
        days.removeAll()
        for i in 0...4 {
            days.append(createStundenplan(wochentag: i))
        }
    }
    
    func getWeekday() -> Int {
        var weekday = Calendar(identifier: .gregorian).component(.weekday, from: Date())
        weekday-=1
        if(weekday == 0){
            weekday = 7
        } //1=monday, not sunday
        return weekday-1 //indexing starts at 0
    }
    
    func editStundenplanByVertretungsplan(username: String, password: String, klasse: String){
        let dataHeute = loadVertretungsplan(date: "Heute", username: username, password: password)
        let dataFolgetag = loadVertretungsplan(date: "Folgetag", username: username, password: password)
        
        vertretungHeute = dataHeute.first(where: {$0.klasse == klasse})
        vertretungFolgetag = dataFolgetag.first(where: {$0.klasse == klasse})
    }
    
    func loadStundenplanFromUserdata(){
        for i in 1...5 {
            let jsonString = UserDefaults.standard.string(forKey: "stundenplan"+StundenplanDay.wochentagToString(wochentag: i)) ?? ""
            do {
                let stundenStrings: [String] = try JSONDecoder().decode([String].self, from: (jsonString.data(using: .utf8)!))
                stundenModels.append(stundenStrings.map{StundenplanEintragModel(allString: $0)})
            } catch {
                stundenModels.append([])
                continue
            }
            stundenModels[i-1].sort(by: {return $0.stunde < $1.stunde})
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
        sendButton.alpha = alpha
        doneLabel.alpha = alpha
        deleteLabel.alpha = alpha
        plusStundeLabel.alpha = alpha
        sendLabel.alpha = alpha
        
        doneLabel.addShadow()
        deleteLabel.addShadow()
        plusStundeLabel.addShadow()
        sendLabel.addShadow()
        
        
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
        rebuildDays()
        changeWochentag(nil)
        menuOpen = false
        updateMenu()
    }
    
    @IBAction func deleteStundenplan(_ sender: Any) {
        let alert = UIAlertController(title: "Stundenplan löschen", message: "Bist du sicher, dass du deinen ganzen Stundenplan löschen willst?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ja", style: .destructive, handler: { [self]_ in
            UserDefaults.standard.removeObject(forKey: "stundenplanMontag")
            UserDefaults.standard.removeObject(forKey: "stundenplanDienstag")
            UserDefaults.standard.removeObject(forKey: "stundenplanMittwoch")
            UserDefaults.standard.removeObject(forKey: "stundenplanDonnerstag")
            UserDefaults.standard.removeObject(forKey: "stundenplanFreitag")
            changeWochentag(nil)
            openCloseMenu(nil)
        }))
        present(alert, animated: true)
    }
    
    @IBAction func changeWochentag(_ sender: Any?) {
        let wochentag = wochentagSelector.selectedSegmentIndex
        
        while(dayView.subviews.count > 0){
            dayView.subviews[0].removeFromSuperview()
        }
        let newSubview = days[wochentag]
        addChild(newSubview)
        dayView.addSubview(newSubview.view!)
        dayView.addConstraint(NSLayoutConstraint(item: newSubview.view!, attribute: .top, relatedBy: .equal, toItem: dayView, attribute: .top, multiplier: 1, constant: 0))
        dayView.addConstraint(NSLayoutConstraint(item: newSubview.view!, attribute: .bottom, relatedBy: .equal, toItem: dayView, attribute: .bottom, multiplier: 1, constant: 0))
        dayView.addConstraint(NSLayoutConstraint(item: newSubview.view!, attribute: .leading, relatedBy: .equal, toItem: dayView, attribute: .leading, multiplier: 1, constant: 0))
        dayView.addConstraint(NSLayoutConstraint(item: newSubview.view!, attribute: .trailing, relatedBy: .equal, toItem: dayView, attribute: .trailing, multiplier: 1, constant: 0))
        newSubview.didMove(toParent: self)
    }
    
    func createStundenplan(wochentag: Int) -> StundenplanDay {
        var vertretungsplanModel: VertretungsplanViewController.VertretungModelArrayModel? = nil
        if(wochentag == getWeekday()){
            vertretungsplanModel = vertretungHeute
        } else if(wochentag == getWeekday()+1){
            vertretungsplanModel = vertretungFolgetag
        }
        let day = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StundenplanDay") as! StundenplanDay
        day.create(wochentag: wochentag, vertretungsplanModel: vertretungsplanModel, editingStundenplan: editingStundenplan)
        return day
    }
    
    var stunde: StundenplanViewController.StundenplanEintragModel? = nil
    
    func saveStundenModels(){
        var i=0
        for tag in stundenModels {
            let jsonString = "["+tag.map{$0.toJSONString()}.joined(separator:",")+"]"
            UserDefaults.standard.set(jsonString, forKey: "stundenplan"+StundenplanDay.wochentagToString(wochentag: i))
            i+=1
        }
    }
    
    @IBAction func addStunde(_ sender: Any) {
        let wochentag = wochentagSelector.selectedSegmentIndex
        
        days[wochentag].addStunde(sender: sender)
        openCloseMenu(nil)
    }
    
    func loadVertretungsplan(date: String, username: String, password: String) -> Array<VertretungsplanViewController.VertretungModelArrayModel>{
        var urlEndings = Array<String>()
        var tables = Array<String>()
        var klassen = Array<String>()
        var realEintraege = Array<String>()
        var vertretungModels = Array<VertretungsplanViewController.VertretungModel>()
        var fertigeMulti = Array<VertretungsplanViewController.VertretungModel>()
        var data = Array<VertretungsplanViewController.VertretungModelArrayModel>()
        var fertigeKlassen = Array<String>()
        
        let main = "https://amgitt.de/AMGAppServlet/amgapp?requestType=HTMLRequest&request=http://sus.amg-witten.de/"+date+"/"
        
        urlEndings = VertretungsplanViewController.getAllEndings(argmain: main, username: username, password: password)
        
        (_,_,tables) = VertretungsplanViewController.getTablesWithProcess(main: main, urlEndings: urlEndings, progressBar: nil, username: username, password: password)
        
        klassen = VertretungsplanViewController.getKlassenListWithProcess(tables: tables,progressBar: nil)
        
        realEintraege = VertretungsplanViewController.getOnlyRealKlassenListWithProcess(tables: tables,progressBar: nil)
        
        var i=0
        
        for s in realEintraege {
            i+=1
            (vertretungModels,fertigeMulti) = VertretungsplanViewController.tryMatcher(s: s,fertigeMulti: fertigeMulti,vertretungModels: vertretungModels)
        }
        
        (data, fertigeKlassen) = VertretungsplanViewController.parseKlassenWithProcess(klassen: klassen, fertigeKlassen: fertigeKlassen, vertretungModels: vertretungModels, data: data, progressBar: nil)
        
        return data
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
