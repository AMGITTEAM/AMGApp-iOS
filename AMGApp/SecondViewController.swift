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

class SecondViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var progressBarText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        action(date: "Folgetag")
        //webView.loadHTMLString(action(), baseURL: nil)
    }
    
    func action(date: String)-> (String) {
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
        
        progressBarText.text="Dateien werden gezählt..."
        progressBar.setProgress(0.0, animated: true)
        
        var main = "http://amgitt.de:8080/AMGAppServlet/amgapp?requestType=HTMLRequest&request=http://amg-witten.de/fileadmin/VertretungsplanSUS/"+date+"/"
        
        urlEndings = getAllEndings(argmain: main)
        
        progressBarText.text="Dateien werden heruntergeladen..."
        
        (stand,fuerDatum,tables) = getTablesWithProcess(main: main, urlEndings: urlEndings, progressBar: progressBar)
        
        progressBar.setProgress(0.0, animated: true)
        progressBarText.text="Dateien werden eingelesen..."
        
        klassen = getKlassenListWithProcess(tables: tables,progressBar: progressBar)
        
        progressBar.setProgress(0.0, animated: true)
        progressBarText.text="Einträge werden überprüft..."
        
        realEintraege = getOnlyRealKlassenListWithProcess(tables: tables,progressBar: progressBar)
        
        progressBar.setProgress(0.0, animated: true)
        progressBarText.text="Einträge werden extrahiert..."
        
        var i=0
        
        for s in realEintraege {
            i+=1
            (vertretungModels,fertigeMulti) = tryMatcher(s: s,fertigeMulti: fertigeMulti,vertretungModels: vertretungModels)
            progressBar.setProgress((Float(i))/(Float(realEintraege.count-1)), animated: true)
        }
        
        
        
        
        
        
        /*do {
        print(try String(contentsOf: URL(string: "http://amgitt.de:8080/AMGAppServlet/amgapp?requestType=HTMLRequest&request=http://amg-witten.de/fileadmin/VertretungsplanSUS/Folgetag/subst_001.htm&username=Schueler&password=-1335285687")!))
        }
        catch let _{}*/
        
        return ""
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
                allMatches.append(match.replaceAll(of: "<td class=\"list\" align=\"center\">", with: "").replaceAll(of: "<td class=\"list\" align=\"center\" style=\"background-color: #FFFFFF\">", with: "").replaceAll(of: "<td class=\"list\" align=\"center\" style=\"background-color: #FFFFFF\" >", with: "").replaceAll(of: "<td class=\"list\">", with: "").replaceAll(of: "</td>", with: "").replaceAll(of: "<b>", with: "").replaceAll(of: "</b>", with: "").replaceAll(of: "<span style=\"color: #800000\">", with: "").replaceAll(of: "<span style=\"color: #0000FF\">", with: "").replaceAll(of: "<span style=\"color: #010101\">", with: "").replaceAll(of: "<span style=\"color: #008040\">", with: "").replaceAll(of: "<span style=\"color: #008000\">", with: "").replaceAll(of: "</span>", with: "").replaceAll(of: "&nbsp;", with: "").replaceFirst(of: ">",with: ""))
            }
            
            var model = VertretungModel(St: allMatches[0],Kl: allMatches[1], Ar: allMatches[2], Fa: allMatches[3], ErsatzFa: allMatches[4], Vertlehrer: allMatches[5], Ra: allMatches[6], Hin: allMatches[7])
            
            model.printObj()
            
            regex = try NSRegularExpression(pattern: "\\d([a-d]){2,4}")
            print("hep")
            print(allMatches[1].range(of: "\\d([a-d]){2,4}"))
            if(allMatches[1].range(of: "\\d([a-d]){2,4}", options: .regularExpression, range: nil, locale: nil) != nil){
                print("yay")
                var found = false
                for existModel in fertigeMulti {
                    if(existModel.allForCheck()==model.allForCheck()){
                        found = true
                    }
                }
                if(!found) {
                    if(allMatches[1].contains("a")){
                        neueVertretungModels.append(VertretungModel(St: allMatches[0], Kl: "a", Ar: allMatches[2], Fa: allMatches[3], ErsatzFa: allMatches[4], Vertlehrer: allMatches[5], Ra: allMatches[6], Hin: allMatches[7]))
                    }
                    if(allMatches[1].contains("b")){
                        neueVertretungModels.append(VertretungModel(St: allMatches[0], Kl: "b", Ar: allMatches[2], Fa: allMatches[3], ErsatzFa: allMatches[4], Vertlehrer: allMatches[5], Ra: allMatches[6], Hin: allMatches[7]))
                    }
                    if(allMatches[1].contains("c")){
                        neueVertretungModels.append(VertretungModel(St: allMatches[0], Kl: "c", Ar: allMatches[2], Fa: allMatches[3], ErsatzFa: allMatches[4], Vertlehrer: allMatches[5], Ra: allMatches[6], Hin: allMatches[7]))
                    }
                    if(allMatches[1].contains("d")){
                        neueVertretungModels.append(VertretungModel(St: allMatches[0], Kl: "d", Ar: allMatches[2], Fa: allMatches[3], ErsatzFa: allMatches[4], Vertlehrer: allMatches[5], Ra: allMatches[6], Hin: allMatches[7]))
                    }
                    neueFertigeMulti.append(model)
                }
            }
            else {
                neueVertretungModels.append(model)
            }
        }
        catch let _ {}
        return (neueVertretungModels,neueFertigeMulti)
    }
    
    func getOnlyRealKlassenListWithProcess(tables: Array<String>, progressBar: UIProgressView) -> Array<String>{
        var i=0
        var realEintraege = Array<String>()
        
        while(i<tables.count){
            var eintraegeArrayUnfertigZwei = tables[i].components(separatedBy: "tr ")
            for eintraegeArrayUnfertigEin in eintraegeArrayUnfertigZwei {
                if(!(eintraegeArrayUnfertigEin.contains("class=\"list inline_header\"")||eintraegeArrayUnfertigEin.contains("class='list inline_header'")||eintraegeArrayUnfertigEin.contains("(Fach)"))){
                    if(eintraegeArrayUnfertigEin.count != 1){
                        realEintraege.append(eintraegeArrayUnfertigEin)
                    }
                }
            }
            
            progressBar.setProgress((Float(i))/(Float(tables.count-1)), animated: true)
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
            progressBar.setProgress((Float(i))/(Float(tables.count-1)), animated: true)
            i+=1
        }
        return klassen
    }
    
    func getTablesWithProcess(main: String, urlEndings: Array<String>, progressBar: UIProgressView) -> (stand: String, fuerDatum: String, tables: Array<String>){
        var stand = ""
        var fuerDatum = ""
        var tables = Array<String>()
        
        var i=0
        while i<urlEndings.count {
            let mainURL = URL(string: main+"subst_"+urlEndings[i]+"&username=Schueler&password=-1335285687")
            do {
                let full = try String(contentsOf: mainURL!)
                
                var body = ""
                do {
                    print("try")
                    body = try onlyElement(full: full, element: "body")
                    print("made")
                }
                catch let error {
                    if(error.localizedDescription.components(separatedBy: " ( error ")[1].components(separatedBy: ".)")[0]=="200"){
                        print("CATCH")
                        print(mainURL)
                        print(full)
                        body = try onlyElement(full: full, element: "body", params: " bgcolor=\"#F0F0F0\"")
                    }
                }
                var center = try onlyElement(full: body, element: "center")
                if(center.contains("http://www.untis.at")) {
                    center = try onlyElement(full: body, element: "CENTER")
                }
                var table = try onlyElement(full: center, element: "table", params: " class=\"mon_list\" ")
                tables.append(table)
                if(urlEndings[i]=="001.htm"){
                    let headData = try onlyElement(full: body, element: "td", params: " align=\"right\" valign=\"bottom\"")
                    stand = (headData.components(separatedBy: "Stand: ")[1]).components(separatedBy: "</p>")[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let datum = try onlyElement(full: center, element: "div", params: " class=\"mon_title\"")
                    let datumParts = datum.components(separatedBy: " ")
                    fuerDatum = datumParts[1]+", "+datumParts[0]
                }
                progressBar.setProgress((Float(i))/(Float(urlEndings.count-1)), animated: true)
            }
            catch let _{}
            
            i=i+1
        }
        return (stand, fuerDatum, tables)
    }
    
    func getAllEndings(argmain: String) -> Array<String> {
        var exit = false
        var next = "001.htm"
        var main = argmain
        var urlEndings = Array<String>()
        urlEndings.append("001.htm")
        while !exit {
            var mainURL = URL(string: main+"subst_"+next+"&username=Schueler&password=-1335285687")
            
            do {
                var full = try String(contentsOf: mainURL!)
                
                if(full.contains("<frame name\"ticker\" src=\"")){
                    main=main + "f1/"
                }
                else {
                    do {
                        var head = try onlyElement(full: full, element: "head")
                        var contentMeta = try onlyArgumentOfElement(full: head, element: "meta http-equiv=\"refresh\"",argument: "content")
                        var nextURL = contentMeta.components(separatedBy: "URL=subst_")[1]
                        next = nextURL
                        if(next == "001.htm"){
                            exit=true
                        }
                        else {
                            urlEndings.append(nextURL)
                        }
                    }
                    catch let error {
                        print(error)
                    }
                }
            }
            catch let error {
                print(error)
            }
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
        
        func getHTMLListItems(id: Int, ownKlasse: String){
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
            if(UserDefaults.standard.bool(forKey: "vertretungsplanIconsEnabled") ?? true) {
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
            returns+="            "+content+"\n" +
                "          </table>\n" +
            "        </div>"
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

