//
//  Startseite.swift
//  AMGApp
//
//  Created by Adrian Kathagen on 01.01.21.
//  Copyright © 2021 amg-witten. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class Startseite: UIViewController {
    
    @IBOutlet weak var calendarView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.load(URLRequest(url: URL(string: "https://calendar.google.com/calendar/embed?title=Demn%C3%A4chst%20am%20AMG&showPrint=0&showTabs=0&showCalendars=0&showDate=0&showTz=0&showNav=0&mode=AGENDA&src=lvcbajbvce91hrj2cg531ess60@group.calendar.google.com&height=1000")!))
        calendarView.isUserInteractionEnabled = true
        calendarView.scrollView.isScrollEnabled = true
    }
}
