//
//  LoginViewController.swift
//  AMGApp
//
//  Created by localadmin on 31.01.19.
//  Copyright © 2019 amg-witten. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool){
        if(UserDefaults.standard.string(forKey: "login") != nil){
            UserDefaults.standard.removeObject(forKey: "login")
            UserDefaults.standard.removeObject(forKey: "passwordVertretungsplanSchueler")
            UserDefaults.standard.removeObject(forKey: "loginUsername")
            UserDefaults.standard.removeObject(forKey: "loginPassword")
            
            tabBarController?.showToast(message: "Logout erfolgreich")
            
            navigationController?.popViewController(animated: true)
            
            return
        }
        
        username.delegate = self
        password.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        super.viewWillAppear(animated)
    }
    
    @IBAction func login(_ sender: Any?) {
        let usernameString = username.text!
        let passwordString = password.text!.hashCode()
        
        var url = "https://amgitt.de/AMGAppServlet/amgapp?requestType=Login&request=&username="+usernameString+"&password="+String(passwordString)+"&datum=&gebaeude=&etage=&raum=&wichtigkeit=&fehler=&beschreibung=&status=&bearbeitetVon="
        
        url = url.encodeUrl()!
        
        do {
            let content = try String(contentsOf: URL(string: url)!)
            
            let body = content.components(separatedBy: "<body>")[1].components(separatedBy: "</body>")[0].trimmingCharacters(in: .whitespacesAndNewlines).decodeUrl()!
            
            if(body.components(separatedBy: "//")[0]=="0") {
                showToast(message: "Login fehlgeschlagen, falsches Passwort?")
                return;
            }
            
            UserDefaults.standard.set(body.components(separatedBy: "//")[0], forKey: "login")
            UserDefaults.standard.set(body.components(separatedBy: "//")[1], forKey: "passwordVertretungsplanSchueler")
            UserDefaults.standard.set(usernameString, forKey: "loginUsername")
            UserDefaults.standard.set(passwordString, forKey: "loginPassword")
            
            presentingViewController?.dismiss(animated: true, completion: nil)
            navigationController?.popViewController(animated: true)
            
            tabBarController?.showToast(message: "Login erfolgreich")
            
            return
            
            //TODO AlarmManager für morgendliche Benachrichtigung
            
        }
        catch _ {}
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case username:
            password.becomeFirstResponder()
        default:
            login(nil)
        }
        return false
    }
    
    
}

