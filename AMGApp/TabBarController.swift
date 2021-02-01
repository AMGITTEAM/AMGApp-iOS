//
//  TabBarController.swift
//  AMGApp
//
//  Created by Adrian Kathagen on 08.12.20.
//  Copyright © 2020 amg-witten. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if(UserDefaults.standard.string(forKey: "version") != Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String){
            let alert = UIAlertController(title: "Changelog", message: "", preferredStyle: UIAlertController.Style.alert)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            let font = UIFont.preferredFont(forTextStyle: .body).withSize(14)
             
            let messageText = NSMutableAttributedString(
                /*string(1.0.1): """
                                          - \"Beschreibung\" in Feedback verbreitert, schließe die Tastatur auf Enter und beim umherklicken
                                          - Eigene Farbe für Unter-, Mittel- und Oberstufe
                                          - Login-Hinweis spezifiziert
                                          - \"Login\" mit Enter steuern
                                          - Zeige \"Login\", wenn im Vertretungsplan nicht eingeloggt
                                          - Indikator für Vertretungsplan-Seite hinzugefügt
                                          - Changelog hinzugefügt
                                          """,*/
                string: """
                                          - \"Stundenplan\" hinzugefügt
                                          - Stundenpläne können per QR-Code geteilt werden
                                          - \"Vertretungsplan\" unterstützt \"Swipe to Refresh\"
                                          - Kalender auf der Startseite hinzugefügt
                                          - amgitt.de als associated-link: Öffnet mit der App
                                          - Vertretungsplan-Icons können in den Einstellungen abgeschaltet werden
                                          - Vertretungsplan: Umlaute repariert
                                          """,
                attributes: [
                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
                    NSAttributedString.Key.font : font,
                    NSAttributedString.Key.foregroundColor : UIColor.black
                ]
            )
             
            alert.setValue(messageText, forKey: "attributedMessage")
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            UserDefaults.standard.setValue(Bundle.main.infoDictionary!["CFBundleShortVersionString"], forKey: "version")
        }
    }
    
}
