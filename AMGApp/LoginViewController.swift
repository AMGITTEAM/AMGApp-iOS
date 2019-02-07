//
//  LoginViewController.swift
//  AMGApp
//
//  Created by localadmin on 31.01.19.
//  Copyright © 2019 amg-witten. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if(UserDefaults.standard.string(forKey: "login") != nil){
            UserDefaults.standard.removeObject(forKey: "login")
            UserDefaults.standard.removeObject(forKey: "passwordVertretungsplanSchueler")
            UserDefaults.standard.removeObject(forKey: "loginUsername")
            UserDefaults.standard.removeObject(forKey: "loginPassword")
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyboard.instantiateViewController(withIdentifier: "tabBar")
            self.present(newViewController, animated: true, completion: nil)
            
            Variables.shouldShowLogoutSuccessToast=true
            
            return
        }
        
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
    }
    
    @objc func login(_ sender: UIButton) {
        let usernameString = username.text!
        let passwordString = password.text!.hashCode()
        
        var url = "http://amgitt.de:8080/AMGAppServlet/amgapp?requestType=Login&request=&username="+usernameString+"&password="+String(passwordString)+"&datum=&gebaeude=&etage=&raum=&wichtigkeit=&fehler=&beschreibung=&status=&bearbeitetVon="
        
        url = url.replaceAll(of: " ",with: "%20")
        
        do {
            let content = try String(contentsOf: URL(string: url)!)
            
            var body = content.components(separatedBy: "<body>")[1].components(separatedBy: "</body>")[0].trimmingCharacters(in: .whitespacesAndNewlines)
            
            if(body.components(separatedBy: "\n")[0]=="0") {
                showToast(message: "Login fehlgeschlagen, falsches Passwort?")
                return;
            }
            
            UserDefaults.standard.set(body.components(separatedBy: "\n")[0], forKey: "login")
            UserDefaults.standard.set(body.components(separatedBy: "\n")[1], forKey: "passwordVertretungsplanSchueler")
            UserDefaults.standard.set(usernameString, forKey: "loginUsername")
            UserDefaults.standard.set(passwordString, forKey: "loginPassword")
            
            Variables.shouldShowLoginSuccessToast = true
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyboard.instantiateViewController(withIdentifier: "tabBar")
            self.present(newViewController, animated: true, completion: nil)
            
            //TODO AlarmManager für morgendliche Benachrichtigung
            
        }
        catch _ {}
    }
    
    
}

