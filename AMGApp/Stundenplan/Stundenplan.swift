//
//  StundenplanViewController.swift
//  AMGApp
//
//  Created by Adrian Kathagen on 10.12.20.
//  Copyright © 2020 amg-witten. All rights reserved.
//

import Foundation
import UIKit

class StundenplanViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
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
    
    var vertretungHeute: VertretungsplanViewController.VertretungModelArrayModel? = nil
    var vertretungFolgetag: VertretungsplanViewController.VertretungModelArrayModel? = nil
    
    var pageController: UIPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var currentPageControllerPage = 0
    var days = [StundenplanDay]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneLabel.addShadow()
        deleteLabel.addShadow()
        plusStundeLabel.addShadow()
        sendLabel.addShadow()
        
        for i in 0...4 {
            let day = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StundenplanDay") as! StundenplanDay
            createStundenplan(wochentag: i, day: day)
            days.append(day)
        }
        createPageViewController()
        
        var weekday = getWeekday()
        if(weekday >= 5) {
            weekday = 0
        }
        wochentagSelector.selectedSegmentIndex = weekday
        forceUpdateView()
        
        updateMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(UserDefaults.standard.string(forKey: "login") != nil && UserDefaults.standard.string(forKey: "klasse") != nil){
            DispatchQueue.init(label: "network").async { [self] in
                editStundenplanByVertretungsplan(username: UserDefaults.standard.string(forKey: "loginUsername")!, password: UserDefaults.standard.string(forKey: "loginPassword")!, klasse: UserDefaults.standard.string(forKey: "klasse")!)
                DispatchQueue.main.async {
                    rebuildDays()
                    forceUpdateView()
                }
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let day = viewController as? StundenplanDay else {return nil}
        guard day.wochentag-1 >= 0 else {return nil}
        return days[day.wochentag-1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let day = viewController as? StundenplanDay else {return nil}
        guard day.wochentag+1 < days.count else {return nil}
        return days[day.wochentag+1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else {return}
        guard let day = pageViewController.viewControllers?.first as? StundenplanDay else {return}
        guard day.wochentag != wochentagSelector.selectedSegmentIndex else {return}
        wochentagSelector.selectedSegmentIndex = day.wochentag
        currentPageControllerPage = day.wochentag
    }
    
    func rebuildDays() {
        for i in 0...4 {
            createStundenplan(wochentag: i, day: days[i])
        }
    }
    
    func createPageViewController(){
        pageController.dataSource = self
        pageController.delegate = self
        
        addChild(pageController)
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        mainView.insertSubview(pageController.view, belowSubview: mainEditButton)
        mainView.addConstraint(NSLayoutConstraint(item: pageController.view!, attribute: .top, relatedBy: .equal, toItem: wochentagSelector, attribute: .bottom, multiplier: 1, constant: 0))
        mainView.addConstraint(NSLayoutConstraint(item: pageController.view!, attribute: .leading, relatedBy: .equal, toItem: mainView, attribute: .leading, multiplier: 1, constant: 0))
        mainView.addConstraint(NSLayoutConstraint(item: pageController.view!, attribute: .trailing, relatedBy: .equal, toItem: mainView, attribute: .trailing, multiplier: 1, constant: 0))
        mainView.addConstraint(NSLayoutConstraint(item: pageController.view!, attribute: .bottom, relatedBy: .equal, toItem: mainView, attribute: .bottom, multiplier: 1, constant: 0))
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
        for i in 0...4 {
            days[i].setEditMode(editingStundenplan)
        }
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
            UserDefaults.standard.synchronize()
            rebuildDays()
            forceUpdateView()
            openCloseMenu(nil)
        }))
        present(alert, animated: true)
    }
    
    @IBAction func changeWochentag(_ sender: Any?) {
        changeWochentag(wochentag: wochentagSelector.selectedSegmentIndex)
    }
    
    func changeWochentag(wochentag: Int){
        if(wochentag > currentPageControllerPage){
            changeWochentag(wochentag: wochentag, direction: .forward)
        } else if(wochentag < currentPageControllerPage){
            changeWochentag(wochentag: wochentag, direction: .reverse)
        }
    }
    
    func forceUpdateView(){
        changeWochentag(wochentag: wochentagSelector.selectedSegmentIndex, direction: .forward, animated: false)
    }
    
    func changeWochentag(wochentag: Int, direction: UIPageViewController.NavigationDirection, animated: Bool=true){
        currentPageControllerPage = wochentag
        pageController.setViewControllers([days[wochentag]], direction: direction, animated: animated, completion: nil)
    }
    
    func createStundenplan(wochentag: Int, day: StundenplanDay) {
        var vertretungsplanModel: VertretungsplanViewController.VertretungModelArrayModel? = nil
        if(wochentag == getWeekday()){
            vertretungsplanModel = vertretungHeute
        } else if(wochentag == getWeekday()+1){
            vertretungsplanModel = vertretungFolgetag
        }
        day.create(wochentag: wochentag, vertretungsplanModel: vertretungsplanModel, editingStundenplan: editingStundenplan)
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
        
        for s in realEintraege {
            (vertretungModels,fertigeMulti) = VertretungsplanViewController.tryMatcher(s: s,fertigeMulti: fertigeMulti,vertretungModels: vertretungModels)
        }
        
        (data, fertigeKlassen) = VertretungsplanViewController.parseKlassenWithProcess(klassen: klassen, fertigeKlassen: fertigeKlassen, vertretungModels: vertretungModels, data: data, progressBar: nil)
        
        return data
    }
    
}
