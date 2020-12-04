//
//  SecondViewController.swift
//  AMGApp
//
//  Created by localadmin on 15.12.18.
//  Copyright © 2018 amg-witten. All rights reserved.
//

//CODE 200: ARRAYINDEXOUTOFBOUNDSERROR

import UIKit
import WebKit

class VertretungsplanViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var progressBarText: UITextField!
    
    var klasse: String = ""
    var day: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view, typically from a nib.
        
        klasse = UserDefaults.standard.string(forKey: "klasse") ?? ""
        let username = UserDefaults.standard.string(forKey: "loginUsername")
        let password = UserDefaults.standard.string(forKey: "loginPassword")
        if(password==nil){
            Variables.shouldShowLoginToast=true
            tabBarController!.selectedIndex = 0
            return
        }
        DispatchQueue(label: "network").async {
            let html = self.action(date: self.day, username: username!, password: password!)
            
            DispatchQueue.main.async {
                self.webView.loadHTMLString(html, baseURL: nil)
            }
        }
    }
    
    func action(date: String, username: String, password: String)-> (String) {
        var fuerDatum: String
        var stand: String
        var urlEndings = Array<String>()
        var tables = Array<String>()
        var klassen = Array<String>()
        var realEintraege = Array<String>()
        var vertretungModels = Array<VertretungModel>()
        var fertigeMulti = Array<VertretungModel>()
        var data = Array<VertretungModelArrayModel>()
        var fertigeKlassen = Array<String>()
        
        DispatchQueue.main.async {
            self.progressBar.isHidden=false
            self.progressBarText.isHidden=false
            self.webView.loadHTMLString("", baseURL: nil)
            self.progressBarText.text="Dateien werden gezählt..."
            self.progressBar.setProgress(0.0, animated: true)
        }
        
        let main = "https://amgitt.de/AMGAppServlet/amgapp?requestType=HTMLRequest&request=http://sus.amg-witten.de/"+date+"/"
        
        urlEndings = getAllEndings(argmain: main, username: username, password: password)
        
        DispatchQueue.main.async {
            self.progressBarText.text="Dateien werden heruntergeladen..."
        }
        
        (stand,fuerDatum,tables) = getTablesWithProcess(main: main, urlEndings: urlEndings, progressBar: progressBar, username: username, password: password)
        
        DispatchQueue.main.async {
            self.progressBar.setProgress(0.0, animated: true)
            self.progressBarText.text="Dateien werden eingelesen..."
        }
        
        klassen = getKlassenListWithProcess(tables: tables,progressBar: progressBar)
        
        DispatchQueue.main.async {
            self.progressBar.setProgress(0.0, animated: true)
            self.progressBarText.text="Einträge werden überprüft..."
        }
        
        realEintraege = getOnlyRealKlassenListWithProcess(tables: tables,progressBar: progressBar)
        
        DispatchQueue.main.async {
            self.progressBar.setProgress(0.0, animated: true)
            self.progressBarText.text="Einträge werden extrahiert..."
        }
        
        var i=0
        
        for s in realEintraege {
            i+=1
            (vertretungModels,fertigeMulti) = tryMatcher(s: s,fertigeMulti: fertigeMulti,vertretungModels: vertretungModels)
            DispatchQueue.main.async {
                self.progressBar.setProgress((Float(i))/(Float(realEintraege.count-1)), animated: true)
            }
        }
        
        DispatchQueue.main.async {
            self.progressBar.setProgress(0.0, animated: true)
            self.progressBarText.text="Einträge werden zusammengestellt..."
        }
        
        (data, fertigeKlassen) = parseKlassenWithProcess(klassen: klassen, fertigeKlassen: fertigeKlassen, vertretungModels: vertretungModels, data: data, progressBar: progressBar)
        
        DispatchQueue.main.async {
            self.progressBar.setProgress(0.0, animated: true)
            self.progressBarText.text="Tabelle wird erstellt..."
        }
        
        let html = buildHTMLWithProcess(progressBar: progressBar, finalFuerDatum: fuerDatum, finalStand: stand, data: data, fertigeKlassen: fertigeKlassen)
        
        DispatchQueue.main.async {
            self.progressBar.isHidden=true
            self.progressBarText.isHidden=true
        }
        
        
        return html
    }
    
    func buildHTMLWithProcess(progressBar: UIProgressView, finalFuerDatum: String, finalStand: String, data: Array<VertretungModelArrayModel>, fertigeKlassen:Array<String>) -> String{
        var string = "<!DOCTYPE html>\n"+"<html>\n"
        string = string+htmlhead()
        DispatchQueue.main.async {
            progressBar.setProgress(1/Float(fertigeKlassen.count), animated: true)
        }
        string = string + "\t<body>\n" +
            "  <div class=\"container\">\n" +
            "  <div class=\"aktuell\">"+"Für "+finalFuerDatum+"</div>\n" +
            "    <div id=\"accordion\">\n" +
        "      <ul class=\"panels\">\n"
        var i=0
        while(i<fertigeKlassen.count) {
            string = string + data[i].getHTMLListItems(id: i, ownKlasse: klasse)
            i=i+1
        }
        string = string + "      </ul>\n" +
            "    </div>\n" +
            "   </div>\n" +
            "   <div class=\"stand\">"+"Stand: "+finalStand+"</div>\n" +
            "  </body>\n" +
        "</html>"
        return string
    }
    
    func htmlhead() -> String {
        var string = "<head>\n" +
            "<meta charset=\"UTF-8\">\n" +
            "<title>Accordion</title>\n" +
            "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n" +
            "<link href='http://fonts.googleapis.com/css?family=roboto:400,600,700' rel='stylesheet' type='text/css'>\n" +
            "\n" +
            "<script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js\"></script> \n" +
            "<script type = \"text/javascript\"> \n" +
            "$(function() {\n" +
            "\n" +
            "\tvar $navLink = $('#accordion').find('li');\n" +
            "\n" +
            "\n" +
            "\n" +
            "\t$navLink.on('click', function() {\n" +
            "\t\tvar panelToShow = $(this).data('panel-id');\n" +
            "\t\tvar $activeLink = $('#accordion').find('.active');\n" +
            "\n" +
            "\t\t// show new panel\n" +
            "\t\t// .stop is used to prevent the animation from repeating if you keep clicking the same link\n" +
            "\t\t$('.' + panelToShow).stop().slideDown();\n" +
            "\t\t$('.' + panelToShow).addClass('active');\n" +
            "\n" +
            "\n" +
            "\t\t// hide the previous panel \n" +
            "\t\t$activeLink.stop().slideUp()\n" +
            "\t\t.removeClass('active');\n" +
            "\t});\n" +
            "\n" +
            "});\n" +
            "\n" +
            "    var xOffset = 30;\n" +
            "    var yOffset = 10;\n" +
            "    $(document).ready(function() {\n" +
            "        $(\"body\").append(\"<div id='tooltip'>\");\n" +
            "\n" +
            "  var $navLink = $('#accordion').find('img');\n" +
            "  console.log($navLink);\n" +
            "  $navLink.on('click', function(e) {\n" +
            "  console.log(\"CLICKED\");\n" +
            "            e.preventDefault();\n" +
            "            $(\"#tooltip\")\n" +
            "                .text($(this).attr('title'))\n" +
            "                .css(\"top\",(e.pageY - xOffset) + \"px\")\n" +
            "                .css(\"left\",(e.pageX + yOffset) + \"px\")\n" +
            "                .show().fadeIn(\"fast\");\n" +
            "        })\n" +
            "            .on('mouseout',function(){\n" +
            "                $(\"#tooltip\").fadeOut(\"slow\").hide();\n" +
            "            })\n" +
            "    })\n" +
        "</script>\n"
        string = string + "\n" +
            "<style>\n" +
            "body {\n" +
            "  background-color: #ccc;\n" +
            "  margin: auto auto;\n" +
            "  padding: 0;\n" +
            "  width:100%;\n" +
            "}\n" +
            "/**/\n" +
            "#accordion {\n" +
            //"  width: 80%;\n" +
            "  margin: 10px auto;\n" +
            "  height: 50%;\n" +
            "  position: relative;\n" +
            "}\n" +
            "\n" +
            "#accordion ul {\n" +
            "  text-align: center;\n" +
            "  margin: 0;\n" +
            "}\n" +
            "\n" +
            "#accordion ul li {\n" +
            "  list-style-type: none;\n" +
            "  cursor: pointer;\n" +
            "  font-family: \"roboto\", sans-serif;\n" +
            "  padding: 0.4em;\n" +
            "  font-size: 1.4em;\n" +
            "  color: white;\n" +
            "  letter-spacing: 0.2em;\n" +
            "  transition: 0.3s ease all;\n" +
            "  text-shadow: -1px 0 grey, 0 1px grey, 1px 0 grey, 0 -1px grey;\n" +
            "}\n" +
            "\n" +
            "#accordion ul li:hover { color: #ccc; }\n" +
            "\n" +
        "#accordion ul a { color: #333; }\n"
        string = string + "/**/\n" +
            ".panels {\n" +
            "padding: 0;\n" +
            "}\n" +
            "\n" +
            " \n" +
            ".panel {\n" +
            "  display: none;\n" +
            "   padding: 25px;\n" +
            "  font-family: \"roboto\", sans-serif;\n" +
            "  padding: 0.3em;\n" +
            "  font-size: 1.0em;\n" +
            "  color: white;\n" +
            "  background-color: white;\n" +
            "  color: #333;\n" +
            "}\n" +
            "@media only screen and (max-width:480px) and (orientation:portrait) {\n" +
            "      nav { display:none;}\n" +
            "\n" +
            ".panel {\n" +
            "  padding: 0.2em;\n" +
            "  font-size: 0.7em;\n" +
            " }   \n" +
            " }\n" +
            "\n" +
            "    #tooltip{\n" +
            "        position:absolute;\n" +
            "        border:1px solid #222;\n" +
            "        border-radius: 6px; \n" +
            "        background:#444;\n" +
            "        padding:3px 6px;\n" +
            "        color:#fff;\n" +
            "        font-family:verdana, sans-serif;\n" +
            "        display:none;\n" +
            "    }\n" +
            "    \n" +
            "   table {\n" +
            "    border-collapse: collapse;\n" +
            "    width:100%;" +
            "}\n" +
            "\n" +
            "   table, td, th {\n" +
            "    border: 1px solid black;\n" +
        "} \n"
        string = string + ".aktuell {\n" +
            "font-family: roboto, sans-serif; \n" +
            "padding-top: 10px;\n" +
            "font-size: 1.4em; \n" +
            "font-weight:bold;\n" +
            "text-align: center;\n" +
            "color: white;\n" +
            "text-shadow: -1px 0 grey, 0 1px grey, 1px 0 grey, 0 -1px grey;\n" +
            "}\n" +
            "\n" +
            ".stand {\n" +
            "font-family: verdana, sans-serif; \n" +
            "padding: 0 20px 10px 0;\n" +
            "font-size: 0.8em; \n" +
            "text-align: right;\n" +
            "color: #232323;\n" +
            "}\n" +
            "</style>\n" +
        "\t</head>\n"
        return string
    }
    
    func parseKlassenWithProcess(klassen: Array<String>, fertigeKlassen: Array<String>, vertretungModels: Array<VertretungModel>, data: Array<VertretungModelArrayModel>, progressBar: UIProgressView) -> (Array<VertretungModelArrayModel>, Array<String>){
        var newData = data
        var newFertigeKlassen = fertigeKlassen
        
        var i=0
        while(i<klassen.count) {
            if(!newFertigeKlassen.contains(klassen[i])) {
                var ie = 0
                var rightRows = Array<VertretungModel>()
                while(ie<vertretungModels.count) {
                    if(vertretungModels[ie].getKlasse() == klassen[i]) {
                        rightRows.append(vertretungModels[ie])
                    }
                    ie=ie+1
                }
                newData.append(VertretungModelArrayModel(rights: rightRows, kl: klassen[i]))
                newFertigeKlassen.append(klassen[i])
            }
            DispatchQueue.main.async {
                progressBar.setProgress((Float(i))/(Float(klassen.count-1)), animated: true)
            }
            i=i+1
        }
        return (newData, newFertigeKlassen)
    }
    
    func tryMatcher(s: String, fertigeMulti: Array<VertretungModel>, vertretungModels: Array<VertretungModel>) -> (Array<VertretungModel>,Array<VertretungModel>){
        
        var neueFertigeMulti = fertigeMulti
        var neueVertretungModels = vertretungModels
        
        var allMatches = Array<String>()
        
        do {
            var regex = try NSRegularExpression(pattern: "<td class=\"list\"(?s)(.*?)</td>")
            let results = regex.matches(in: s, range: NSRange(s.startIndex..., in: s))
            let finalResult = results.map {
                String(s[Range($0.range, in: s)!])
            }
            for match in finalResult {
                allMatches.append(match.replaceAll(of: "<td class=\"list\" align=\"center\">", with: "").replaceAll(of: "<td class=\"list\" align=\"center\" style=\"background-color: #FFFFFF\">", with: "").replaceAll(of: "<td class=\"list\" align=\"center\" style=\"background-color: #FFFFFF\" >", with: "").replaceAll(of: "<td class=\"list\">", with: "").replaceAll(of: "</td>", with: "").replaceAll(of: "<b>", with: "").replaceAll(of: "</b>", with: "").replaceAll(of: "<span style=\"color: #800000\">", with: "").replaceAll(of: "<span style=\"color: #0000FF\">", with: "").replaceAll(of: "<span style=\"color: #010101\">", with: "").replaceAll(of: "<span style=\"color: #008040\">", with: "").replaceAll(of: "<span style=\"color: #008000\">", with: "").replaceAll(of: "<span style=\"color: #FF00FF\">", with: "").replaceAll(of: "</span>", with: "").replaceAll(of: "&nbsp;", with: "").replaceFirst(of: ">",with: ""))
            }
            
            let model = VertretungModel(St: allMatches[0],Kl: allMatches[1], Ar: allMatches[2], Fa: allMatches[3], ErsatzFa: allMatches[4], Vertlehrer: allMatches[5], Ra: allMatches[6], Hin: allMatches[7])
            
            regex = try NSRegularExpression(pattern: "\\d([a-d]){2,4}")
            if(allMatches[1].range(of: "\\d([a-d]){2,4}", options: .regularExpression, range: nil, locale: nil) != nil){
                var found = false
                for existModel in fertigeMulti {
                    if(existModel.allForCheck()==model.allForCheck()){
                        found = true
                    }
                }
                if(!found) {
                    if(allMatches[1].contains("a")){
                        neueVertretungModels.append(VertretungModel(St: allMatches[0], Kl: allMatches[1].prefix(2)+"a", Ar: allMatches[2], Fa: allMatches[3], ErsatzFa: allMatches[4], Vertlehrer: allMatches[5], Ra: allMatches[6], Hin: allMatches[7]))
                    }
                    if(allMatches[1].contains("b")){
                        neueVertretungModels.append(VertretungModel(St: allMatches[0], Kl: allMatches[1].prefix(2)+"b", Ar: allMatches[2], Fa: allMatches[3], ErsatzFa: allMatches[4], Vertlehrer: allMatches[5], Ra: allMatches[6], Hin: allMatches[7]))
                    }
                    if(allMatches[1].contains("c")){
                        neueVertretungModels.append(VertretungModel(St: allMatches[0], Kl: allMatches[1].prefix(2)+"c", Ar: allMatches[2], Fa: allMatches[3], ErsatzFa: allMatches[4], Vertlehrer: allMatches[5], Ra: allMatches[6], Hin: allMatches[7]))
                    }
                    if(allMatches[1].contains("d")){
                        neueVertretungModels.append(VertretungModel(St: allMatches[0], Kl: allMatches[1].prefix(2)+"d", Ar: allMatches[2], Fa: allMatches[3], ErsatzFa: allMatches[4], Vertlehrer: allMatches[5], Ra: allMatches[6], Hin: allMatches[7]))
                    }
                    neueFertigeMulti.append(model)
                }
            }
            else {
                neueVertretungModels.append(model)
            }
        }
        catch _ {}
        return (neueVertretungModels,neueFertigeMulti)
    }
    
    func getOnlyRealKlassenListWithProcess(tables: Array<String>, progressBar: UIProgressView) -> Array<String>{
        var i=0
        var realEintraege = Array<String>()
        
        while(i<tables.count){
            let eintraegeArrayUnfertigZwei = tables[i].components(separatedBy: "tr ")
            for eintraegeArrayUnfertigEin in eintraegeArrayUnfertigZwei {
                if(!(eintraegeArrayUnfertigEin.contains("class=\"list inline_header\"")||eintraegeArrayUnfertigEin.contains("class='list inline_header'")||eintraegeArrayUnfertigEin.contains("(Fach)"))){
                    if(eintraegeArrayUnfertigEin.count != 1){
                        realEintraege.append(eintraegeArrayUnfertigEin)
                    }
                }
            }
            DispatchQueue.main.async {
                progressBar.setProgress((Float(i))/(Float(tables.count-1)), animated: true)
            }
            i+=1
        }
        
        return realEintraege
    }
    
    func getKlassenListWithProcess(tables: Array<String>, progressBar: UIProgressView) -> Array<String> {
        var i=0
        var klassen = Array<String>()
        while(i<tables.count){
            var klassenArrayUnfertig = tables[i].components(separatedBy: "td class=\"list inline_header\" colspan=\"8\"")
            var ie=0
            while(ie<klassenArrayUnfertig.count){
                klassenArrayUnfertig[ie] = klassenArrayUnfertig[ie].replaceFirst(of: ">",with: "")
                ie+=1
            }
            ie=1
            while(ie<klassenArrayUnfertig.count){
                klassen.append(klassenArrayUnfertig[ie].components(separatedBy: "</td>")[0].trimmingCharacters(in: .whitespacesAndNewlines))
                ie+=1
            }
            DispatchQueue.main.async {
                progressBar.setProgress((Float(i))/(Float(tables.count-1)), animated: true)
            }
            i+=1
        }
        return klassen
    }
    
    func getTablesWithProcess(main: String, urlEndings: Array<String>, progressBar: UIProgressView, username: String, password: String) -> (stand: String, fuerDatum: String, tables: Array<String>){
        var stand = ""
        var fuerDatum = ""
        var tables = Array<String>()
        
        var i=0
        while i<urlEndings.count {
            let mainURL = URL(string: main+"subst_"+urlEndings[i]+"&username="+username+"&password="+password)
            do {
                let full = try String(contentsOf: mainURL!).decodeUrl()!
                
                var body = ""
                do {
                    body = try onlyElement(full: full, element: "body")
                }
                catch let error {
                    if(error.localizedDescription.components(separatedBy: " ( error ")[1].components(separatedBy: ".)")[0]=="200"){
                        body = try onlyElement(full: full, element: "body", params: " bgcolor=\"#F0F0F0\"")
                    }
                }
                var center = try onlyElement(full: body, element: "center")
                if(center.contains("http://www.untis.at")) {
                    center = try onlyElement(full: body, element: "CENTER")
                }
                let table = try onlyElement(full: center, element: "table", params: " class=\"mon_list\" ")
                tables.append(table)
                if(urlEndings[i]=="001.htm"){
                    let headData = try onlyElement(full: body, element: "td", params: " align=\"right\" valign=\"bottom\"")
                    stand = (headData.components(separatedBy: "Stand: ")[1]).components(separatedBy: "</p>")[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let datum = try onlyElement(full: center, element: "div", params: " class=\"mon_title\"")
                    let datumParts = datum.components(separatedBy: " ")
                    fuerDatum = datumParts[1]+", "+datumParts[0]
                }
                DispatchQueue.main.async {
                    progressBar.setProgress((Float(i))/(Float(urlEndings.count-1)), animated: true)
                }
            }
            catch _{}
            
            i=i+1
        }
        return (stand, fuerDatum, tables)
    }
    
    func getAllEndings(argmain: String, username: String, password: String) -> Array<String> {
        var exit = false
        var next = "001.htm"
        var main = argmain
        var urlEndings = Array<String>()
        urlEndings.append("001.htm")
        while !exit {
            let mainURL = URL(string: main+"subst_"+next+"&username="+username+"&password="+password)
            
            do {
                let full = try String(contentsOf: mainURL!).decodeUrl()!
                
                if(full.contains("<frame name\"ticker\" src=\"")){
                    main=main + "f1/"
                }
                else {
                    do {
                        let head = try onlyElement(full: full, element: "head")
                        let contentMeta = try onlyArgumentOfElement(full: head, element: "meta http-equiv=\"refresh\"",argument: "content")
                        let nextURL = contentMeta.components(separatedBy: "URL=subst_")[1]
                        next = nextURL
                        if(next == "001.htm"){
                            exit=true
                        }
                        else {
                            urlEndings.append(nextURL)
                        }
                    }
                    catch _{}
                }
            }
            catch _ {}
        }
        return urlEndings
    }
    
    func onlyElement(full: String, element: String) throws -> String {
        return try onlyElement(full: full, element: element, params: "")
    }
    
    func onlyElement(full: String, element: String, params: String) throws -> String {
        let arrayOne = full.components(separatedBy: "<"+element+params+">")
        if(2>arrayOne.count){
            throw NSError(domain: "", code: 200, userInfo: nil)
        }
        let partOne = arrayOne[1]
        return partOne.components(separatedBy: "</"+element+">")[0]
    }
    
    func onlyArgumentOfElement(full: String, element: String, argument: String) throws -> String{
        let arrayOne = full.components(separatedBy: "<"+element)
        if(2>arrayOne.count) {
            throw NSError(domain: "", code: 200, userInfo: nil)
        }
        let partOne = arrayOne[1]
        let arrayTwo = partOne.components(separatedBy: argument+"=\"")
        if(2>arrayTwo.count){
            throw NSError(domain: "", code: 200, userInfo: nil)
        }
        let partTwo = arrayTwo[1]
        return partTwo.components(separatedBy: "\"")[0]
    }
    
    class VertretungModelArrayModel {
        var RightRows = Array<VertretungModel>()
        var klasse: String
        
        init(rights: Array<VertretungModel>, kl: String) {
            RightRows=rights
            klasse = kl
        }
        
        func getKlasse() -> String {
            return klasse
        }
        
        func getRightRows() -> Array<VertretungModel> {
            return RightRows
        }
        
        func getHTMLListItems(id: Int, ownKlasse: String) -> String{
            var content = ""
            var klasse = ""
            for s in RightRows {
                klasse = s.getKlasse()
                content+="" +
                    "            <tr>\n" +
                    "              <td>"+s.getStunde()+"</td>\n" +
                    "              <td>"+s.getKlasse()+"</td>\n" +
                    "              <td>"+s.getArt()+"</td>\n" +
                    "              <td>"+s.getFach()+"</td>\n" +
                    "              <td>"+s.getErsatzFach()+"</td>\n" +
                    "              <td>"+s.getVertretungslehrer()+"</td>\n" +
                    "              <td>"+s.getRaum()+"</td>\n" +
                    "              <td>"+s.getHinweise()+"</td>\n" +
                    "            </tr>"
            }
            var color: String
            if(klasse == ownKlasse){
                color = UserDefaults.standard.string(forKey: "vertretungEigeneKlasseFarbe") ?? "#FF0000"
            }
            else if(klasse.contains("5")||klasse.contains("6")) {
                color = UserDefaults.standard.string(forKey: "vertretungUnterstufeFarbe") ?? "#4aa3df"
            }
            else if(klasse.contains("7")||klasse.contains("8")||klasse.contains("9")){
                color = UserDefaults.standard.string(forKey: "vertretungMittelstufeFarbe") ?? "#3498db"
            }
            else if(klasse == "EF"||klasse == "Q1"||klasse == "Q2"){
                color = UserDefaults.standard.string(forKey: "vertretungOberstufeFarbe") ?? "#258cd1"
            }
            else {
                color = UserDefaults.standard.string(forKey: "vertretungErrorFarbe") ?? "#FF0000"
            }
            
            
            var returns = "<li data-panel-id=\"panel"+String(id)
            returns+="\" style=\"background-color: "+color
            returns+=";\">"+klasse+"</li>\n"
            returns+="        <div class=\"panel panel"+String(id)+"\">\n"
            returns+="<table width=\"99%\">\n" +
                "            <colgroup>\n"
            returns+="<col width=\"9%\"/>\n" +
                "              <col width=\"9%\"/>\n" +
                "              <col width=\"18%\"/>\n" +
                "              <col width=\"9%\"/>\n" +
                "              <col width=\"9%\"/>\n" +
                "              <col width=\"9%\"/>\n" +
                "              <col width=\"9%\"/>\n"
            returns+="<col width=\"27%\"/>\n" +
                "            </colgroup>\n\n"
            if(UserDefaults.standard.object(forKey: "vertretungsplanIconsEnabled") != nil) {
                if(UserDefaults.standard.bool(forKey: "vertretungsplanIconsEnabled")) {
                    let stunde = "Stunde"
                    let altKlasse = "Klasse"
                    let vertretungsart = "Vertretungsart"
                    let fach = "Fach"
                    let ersatzfach = "Ersatzfach"
                    let vertretungslehrer = "Vertretungslehrer"
                    let raum = "Raum"
                    let hinweise = "Hinweise"
                    returns+="                       <tr>\n" +
                        "              <td><img src=\"time.png\" alt=\""+stunde+"\" title=\""+stunde+"\" id=\"area\"/></td>\n" +
                        "              <td><img src=\"group.png\" alt=\""+altKlasse+"\" title=\""+altKlasse+"\" id=\"area\"/></td>\n" +
                        "              <td><img src=\"bullet_error.png\" alt=\""+vertretungsart+"\" title=\""+vertretungsart+"\" id=\"area\"/></td>\n" +
                        "              <td><img src=\"book.png\" alt=\""+fach+"\" title=\""+fach+"\" id=\"area\"/></td>\n" +
                        "              <td><img src=\"book_edit.png\" alt=\""+ersatzfach+"\" title=\""+ersatzfach+"\" id=\"area\"/></td>\n" +
                        "              <td><img src=\"user.png\" alt=\""+vertretungslehrer+"\" title=\""+vertretungslehrer+"\" id=\"area\"/></td>\n" +
                        "              <td><img src=\"door_open.png\" alt=\""+raum+"\" title=\""+raum+"\" id=\"area\"/></td>\n" +
                        "              <td><img src=\"lightbulb.png\" alt=\""+hinweise+"\" title=\""+hinweise+"\" id=\"area\"/></td>\n" +
                    "            </tr>            "
                }
            }
            else {
                let stunde = "Stunde"
                let altKlasse = "Klasse"
                let vertretungsart = "Vertretungsart"
                let fach = "Fach"
                let ersatzfach = "Ersatzfach"
                let vertretungslehrer = "Vertretungslehrer"
                let raum = "Raum"
                let hinweise = "Hinweise"
                returns+="                       <tr>\n" +
                    "              <td><img src=\"data:image/png;base64, "+timeBase()+"\" alt=\""+stunde+"\" title=\""+stunde+"\" id=\"area\"/></td>\n" +
                    "              <td><img src=\"data:image/png;base64, "+groupBase()+"\" alt=\""+altKlasse+"\" title=\""+altKlasse+"\" id=\"area\"/></td>\n" +
                    "              <td><img src=\"data:image/png;base64, "+bulletErrorBase()+"\" alt=\""+vertretungsart+"\" title=\""+vertretungsart+"\" id=\"area\"/></td>\n" +
                    "              <td><img src=\"data:image/png;base64, "+bookBase()+"\" alt=\""+fach+"\" title=\""+fach+"\" id=\"area\"/></td>\n" +
                    "              <td><img src=\"data:image/png;base64, "+bookEditBase()+"\" alt=\""+ersatzfach+"\" title=\""+ersatzfach+"\" id=\"area\"/></td>\n" +
                    "              <td><img src=\"data:image/png;base64, "+userBase()+"\" alt=\""+vertretungslehrer+"\" title=\""+vertretungslehrer+"\" id=\"area\"/></td>\n" +
                    "              <td><img src=\"data:image/png;base64, "+doorOpenBase()+"\" alt=\""+raum+"\" title=\""+raum+"\" id=\"area\"/></td>\n" +
                    "              <td><img src=\"data:image/png;base64, "+lightbulbBase()+"\" alt=\""+hinweise+"\" title=\""+hinweise+"\" id=\"area\"/></td>\n" +
                "            </tr>            "
            }
            returns+="            "+content+"\n" +
                "          </table>\n" +
            "        </div>"
            return returns
        }
        
        func timeBase() -> String {
            return "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAKrSURBVDjLpdPbT9IBAMXx/qR6qNbWUy89WS5rmVtutbZalwcNgyRLLMyuoomaZpRQCt5yNRELL0TkBSXUTBT5hZSXQPwBAvor/fZGazlb6+G8nIfP0znbgG3/kz+Knsbb+xxNV63DLxVLHzqV0vCrfMluzFmw1OW8ePEwf8+WgM1UXDnapVgLePr5Nj9DJBJGFEN8+TzKqL2RzkenV4yl5ws2BXob1WVeZxXhoB+PP0xzt0Bly0fKTePozV5GphYQPA46as+gU5/K+w2w6Ev2Ol/KpNCigM01R2uPgDcQIRSJEYys4JmNoO/y0tbnY9JlxnA9M15bfHZHCnjzVN4x7TLz6fMSJqsPgLAoMvV1niSQBGIbUP3Ki93t57XhItVXjulTQHf9hfk5/xgGyzQTgQjx7xvE4nG0j3UsiiLR1VVaLN3YpkTuNLgZGzRSq8wQUoD16flkOPSF28/cLCYkwqvrrAGXC1UYWtuRX1PR5RhgTJTI1Q4wKwzwWHk4kQI6a04nQ99mUOlczMYkFhPrBMQoN+7eQ35Nhc01SvA7OEMSFzTv8c/0UXc54xfQcj/bNzNmRmNy0zctMpeEQFSio/cdvqUICz9AiEPb+DLK2gE+2MrR5qXPpoAn6mxdr1GBwz1FiclDcAPCEkTXIboByz8guA75eg8WxxDtFZloZIdNKaDu5rnt9UVHE5POep6Zh7llmsQlLBNLSMTiEm5hGXXDJ6qb3zJiLaIiJy1Zpjy587ch1ahOKJ6XHGGiv5KeQSfFun4ulb/josZOYY0di/0tw9YCquX7KZVnFW46Ze2V4wU1ivRYe1UWI1Y1vgkDvo9PGLIoabp7kIrctJXSS8eKtjyTtuDErrK8jIYHuQf8VbK0RJUsLfEg94BfIztkLMvP3v3XN/5rfgIYvAvmgKE6GAAAAABJRU5ErkJggg=="
        }
        
        func userBase() -> String {
            return "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAJ3SURBVDjLpZNtSNNRFIcNKunF1rZWBMJqKaSiX9RP1dClsjldA42slW0q5oxZiuHrlqllLayoaJa2jbm1Lc3QUZpKFmmaTMsaRp+kMgjBheSmTL2//kqMBJlFHx44XM7vOfdyuH4A/P6HFQ9zo7cpa/mM6RvCrVDzaVDy6C5JJKv6rwSnIhlFd0R0Up/GwF2KWyl01CTSkM/dQoQRzAurCjRCGnRUUE2FaoSL0HExiYVzsQwcj6RNrSqo4W5Gh6Yc4+1qDDTkIy+GhYK4nTgdz0H2PrrHUJzs71NQn86enPn+CVN9GnzruoYR63mMPbkC59gQzDl7pt7rc9f7FNyUhPY6Bx9gwt4E9zszhWWpdg6ZcS8j3O7zCTuEpnXB+3MNZkUUZu0NmHE8XsL91oSWwiiEc3MeseLrN6woYCWa/Zl8ozyQ3w3Hl2lYy0SwlCUvsVi/Gv2JwITnYPDun2Hy6jYuEzAF1jUBCVYpO6kXo+NuGMeBAgcgfwNkvgBOPgUqXgKvP7rBFvRhE1crp8Vq1noFYSlacVyqGk0D86gbART9BDk9BFnPCNJbCY5aCFL1Cyhtp0RWAp74MsKSrkq9guHyvfMTtmLc1togpZoyqYmyNoITzVTYRJCiXYBIQ3CwFqi83o3JDhX6C0M8XsGIMoQ4OyuRlq1DdZcLkmbgGDX1iIEKNxAcbgTEOqC4ZRaJ6Ub86K7CYFEo8Qo+GBQlQyXBczLZpbloaQ9k1NUz/kD2myBBKxRZpa5hVcQslalatoUxizxAVVrN3CW21bFj9F858Q9dnIRmDyeuybM71uxmH9BNBB1q6zybV7H9s1Ue4PM3/gu/AEbfqfWy2twsAAAAAElFTkSuQmCC"
        }
        
        func lightbulbBase() -> String {
            return "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAKgSURBVDjLlZLrS1NxGMd90ZvovdEfEBEUEhZIb0xMjdyLIuyGkiHGUFKydFKKJiRegjIyFJRwojMxzfJSaVOYeTfxtpSNuZ1tXnY2z27nsss5334uWloG9uLD7/A7z/fzPPx4IgBE7ISl3qWyelUvu9JIueZqeOdUmcCMFDgcQ3fntjSK0j/rwx+csesIZ3jbL1j6EbCPIej5DpE3QRIoBJ3LEFb74BjIxkbXVYNdrTixS8Ca3h/y6pSTfloD0UcRjCS8BJGbRdA7QRgjd1pIfhruyeewKOMdm+rCw2GBV1tXKZh7SIEVoqAjpwVS0AlIvhBSkCGyeQRcPYDogO1DNixvrveFBa6ZCkuAmSe1OtJpFVLATkJboWCIAE3+GYngI6ENgnUK+hcxfFiw9fWRT+RWEWTHEeRmyPhaMvYCgu5ZEpgkbzCCgPszBNsr8NY8iF4Ky5WnpLDArs41+zYnSPdF8OYi0qEcTHc6mF45mJ4M2Ftl4C1lYPU34KerwFNTWKmO/j2BfbiwghmvJuPawZsUsNVHgTPlEx6ANcjJeR9r5QfhWUqEJOlhbc+FoV42FBY4R0sPbPbKlz2LLeQB9aCbYkJhzpIFlkoDZ8zDRk0kRHYYrm8d0JYeEyyduUd37QH9pTBqvSOV9iy0wtmZ+VNAOm+HOeM92JtlYDQN0JYcD1BtmTf/WqRtbJ/yTxtUt9fXGhPBq5MhriVBtMYhoLkMQ1Ek5sqi3eb2O4l7buIvhlRPkmsfZ/ibax+iruosnpacQUFOOq7Fn5TUypJz/1zlnRQr5JSypRVKZRvq6htR/ewlriTH03vV7ilQ5NwaHRgchM1GY3p6Bq+bmpEii9XtWzCgqkhLuXSBTUg4L8XFxUoXk2K57obirH0L/ocfNQ8V8wE+uE0AAAAASUVORK5CYII="
        }
        
        func groupBase() -> String {
            return "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAKDSURBVDjLjdFNTNJxHAZw69CWHjp16O2AZB3S1ovOObaI8NBYuuZAhqjIQkzJoSIZBmSCpVuK/sE/WimU6N9SDM0R66IHbabie1hrg0MK3Zo5a8vwidgym8w8PKffvp89e35RAKJ2ipp7WDxvjltZ6jwCr5W2bpHHtqUnx+77877jsZxzlO3roAWXuw5ha1pl9MZdAW2ig8RyXyL8rnx8G6uH387AMnUMC2b6l10BJPdAfWDGhZVREuszT7D6hsTStBNDurO+XQEZnEypx1a28XW2F8HFPqwtOBAYJlCde9EeEZCy4sTN4ksrRA4LZB57vZCfMElUyH4E7Ap86r+LwIAGIy03cDr/lDNJGR/zDyBiHGc3i1ODjUIWtqbdIIexVY86kwZ3HijR/86GmqFqJGhPWs8oTkRvAgb+uZGHhVfRV3UNni41OhU8EDlstBSkwjKjhnmqAg3uUtS6y9Dzvg0ljmKkFCaRm4CJT+/5OERtG4yqZMEwdQt1biV0EyW4PVEE1dsiiMk8eMn0/w9Wp+PCNK1CQ6iBYeommkIpH5Qhy5AF/6Mrf4G955tUJlXxtsHieeWQ2LJxvVuAAkoASUcmLugZPqW0qsprEQjDx3sY3ZIMhXt1+DNw77kdmnYKSsKKx+PfoTQtYX9KtzWG2Rod6aujaJwWHk8+uDawGITeA+SPA7nDQOYgwKcAYhQQajyIY9eQEYE5feLPyV4jFC8CELkAkWMDQmoDPGsQaWYgzRjEU8vL8GARAV8T099bUwqBdgzS14D4VaiBA8gZALJ/t6j1Qqu4Hx4sIvChoyDFWZ1RmcyzORJLJsDSzoUyD5Z6FsxKN+iXn/mM5ZLwYJGAX0F/sgCQt3xBAAAAAElFTkSuQmCC"
        }
        
        func doorOpenBase() -> String {
            return "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAGOSURBVDjLlZPNapNBFIafSdOvtbFgSi1dREEtguDSnTfStbgW9A6y9BICinfkRosRFw1mE5BoS4rNzPlzEfOrYjJwOGfzPvO+h5kUEWx6zt6+eO1ur8x0VN9E+Ondyy/udlLdPua8d8ZBrdIZoN1uh7szLTOb9WePgxpOdXjMzXsnuDlx/gGRzAxgZrRaLQBSSks94iPNJ0+BRL4aYpKJcER0GbAqns5mhptRRgNMC1Aj3P50sChanFULboJpwbUAiXCnlPEcoKr/BJgWQhWXMnEQE4DKmNrfHKyW/L7ZJBNyzVGzR4RSSp4DFh2sOhEpmCpWMo0bPzi4NWR76xqR/0SYA8a4ZkwyF9+3cD0kl8HyEqeA1fwpJUrJuAouGRNhmOvgjkhZD6AynuxABdNMSnXcHdU1AUXyRCwZl0JKTsQGAJFJhL3mHVwFzT8hBpgpqdPpRLfbpd/vL73/xX56v0djf5+d3QbV7h7b1Q6jqwu+fn7/La3znd88v3tkpg/M5JGZPnS3Vq1enZrky19GcE/tIr8QhwAAAABJRU5ErkJggg=="
        }
        
        func bulletErrorBase() -> String {
            return "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAFYSURBVDjLY/z//z8DJYCJgUJAsQEsuCQeHIgP/f/vX/H/f//9lFyWvCLJBff2xPD9+/27kV/O3xxIl5HsBaCmAj5Zb00+SUOGPz9/J19fF2BKtAG3NoVoATXl84oIMPz9tIlBXC9F4O/PX7WXl3iwEjQAaBPTn5+/KkW1ooUYfpxjOLVoKQOPwHeGPz9++QCxH0EDgDa5cQnrxfAKfmP49/M+A8P/fwx/v5xmUHQoZvzz82fzqUmWvDgNuLjQjQ1oS4uAnAHDv2+XgHq/MxgHqzP8+/WMgYPjFoO4boQm0HWFOA0A2p4qpOJtzMX7huH/n7cMDIzMDGfX3QIFKcO/H7cYRNXkgWp+Zx9q0tHCmg7+/PgJ9Ls/0MgHDEx8okCR/wxmSQFwe5g5lRmUXMvFbm1uagQKhGIa8PMXx7nZwd+BCQfo/H9I+D+cZgDR//9LILuAcehnJgBMs6gZ4tipDAAAAABJRU5ErkJggg=="
        }
        
        func bookEditBase() -> String{
            return "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAK/SURBVDjLbZNNaFRXFMd/72U+dDLNRItGUSeJiagTJ6IQhdhaWoopFCJiF10UBAXpSlHcddHi0oUbkXYRFURE/NiIIjSkpCpdtGoTJG20iUMsMZJokhmqee/de8/p4jmDggcuFw73/s7/nPu/nqrSe/hch6peUZhD6VYUVUCVeNPaEmcwYbn06/nv1gIkiA8cVNhQLOS96ZkyqtVLEMMEFZgvv2IhVEQTrbyJGAA7i4U13qeda8ivLKIxAVGJq0pcfVljhsyiBDt2f8s7AFSXFDuauXVvjLm516gIAFJVoYqKMl95TRBGvB1vWsBLpBKs29RMe9NSnANVQURxTnEiWFEWAsPlq4PvAyjOCRPTFVJ+kiAIMGGElThvqSORTFFID3Oy+xfqdnUyfLZHvWByX3UGiBOsM4RhyJ5t7bH8WB2qyp27fWxLP2dx8RtyrVuYL61n9Oe+EzUFxgnOWKzzuTD4F6GxWKc4K7Sk/2DPpjINuR3Mjv9Nyov4oGEF2Q/zuRrAWiEyhkhA/TReMgm+sjr1gL0bZ2lc20M4dYlUxmNiaBQTRC+Dhf+6q0PEWIcNLKFxWCcYJ6zkPl93lMi19RJM/oSfsiSzzQSzI4j1P+862v/YrylwggkNoXEExrGkfJuv2sbJtfcSTP6InzRElRaeDtzj+4EGth7tHwLw327BRDGgsXKXL/LPWN7xJdHzPupSSlhpZur2fX4Y+Yyx+XTtGf2qYSLrsKGl/lk/vflphFVMPTyFEPBqdhWlwYdcW3SYF1H2vUaKDRM5CjpA4aMzPLp0jMd3fiOd30x5ZoqbyYNkMktRxhCRp+8oUFXwfbq2d/JofIZo5Aatmz+mvn49//75D0NNh8g2tWGtoAphENbs6Kkqn+w/3afKAUVZ8eQ4W1uX0bWhhYmonqulTuZMtvYzUa7/fvHI7irgf/y+taODWkwAAAAAAElFTkSuQmCC"
        }
        
        func bookBase() -> String{
            return "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAHjSURBVDjLdZO/alVBEMZ/5+TemxAbFUUskqAoSOJNp4KC4AsoPoGFIHY+gA+jiJXaKIiChbETtBYLUbSMRf6Aydndmfks9kRjvHdhGVh2fvN9uzONJK7fe7Ai6algA3FZCAmQqEF/dnihpK1v7x7dPw0woF64Izg3Xl5s1n9uIe0lQYUFCtjc+sVuEqHBKfpVAXB1vLzQXFtdYPHkGFUCoahVo1Y/fnie+bkBV27c5R8A0pHxyhKvPn5hY2MHRQAQeyokFGJze4cuZfav3gLNYDTg7Pklzpw4ijtIQYRwFx6BhdjtCk+erU0CCPfg+/o2o3ZI13WUlLGo58YMg+GIY4dmCWkCAAgPzAspJW5ePFPlV3VI4uHbz5S5IQfy/yooHngxzFser30iFcNcuAVGw3A0Ilt91IkAsyCXQg5QO0szHEIrogkiguwN2acCoJhjnZGKYx4Ujz5WOA2YD1BMU+BBSYVUvNpxkXuIuWgbsOxTHrG3UHIFWIhsgXtQQpTizNBS5jXZQkhkcywZqQQlAjdRwiml7wU5xWLaL1AvZa8WIjALzIRZ7YVWDW5CiIj48Z8F2pYLl1ZR0+AuzEX0UX035mxIkLq0dhDw5vXL97fr5O3rfwQHJhPx4uuH57f2AL8BfPrVlrs6xwsAAAAASUVORK5CYII="
        }
    }
    
    class VertretungModel {
        var Stunde,Klasse,Art,Fach,ErsatzFach,Vertretungslehrer,Raum,Hinweise: String
        
        init(St: String, Kl: String, Ar: String, Fa: String, ErsatzFa: String, Vertlehrer: String, Ra: String, Hin: String){
            Stunde=St
            Klasse=Kl
            Art=Ar
            Fach=Fa
            ErsatzFach=ErsatzFa
            Vertretungslehrer=Vertlehrer
            Raum=Ra
            Hinweise=Hin
        }
        
        func getStunde() -> String {
            return Stunde
        }
        
        func getKlasse() -> String {
            return Klasse
        }
        
        func getArt() -> String {
            return Art
        }
        
        func getFach() -> String {
            return Fach
        }
        
        func getErsatzFach() -> String {
            return ErsatzFach
        }
        
        func getVertretungslehrer() -> String {
            return Vertretungslehrer
        }
        
        func getRaum() -> String {
            return Raum
        }
        
        func getHinweise() -> String {
            return Hinweise
        }
        
        func printObj() {
            var printstring = "Stunde: "+Stunde+", "
            printstring+="Klasse: "+Klasse+", "
            printstring+="Art: "+Art+", "
            printstring+="Fach: "+Fach+", "
            printstring+="Ersatzfach: "+ErsatzFach+", "
            printstring+="Vertretungslehrer: "+Vertretungslehrer+", "
            printstring+="Raum: "+Raum+", "
            printstring+="Hinweise: "+Hinweise+"."
            print(printstring)
        }
        
        func allForCheck() -> String{
            return Stunde+Klasse+Art+Fach+ErsatzFach+Vertretungslehrer+Raum+Hinweise
        }
    }
}

