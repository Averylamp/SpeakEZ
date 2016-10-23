//
//  AnalysisViewController.swift
//  PresentorPractice
//
//  Created by Avery Lamp on 10/22/16.
//  Copyright © 2016 Isometric. All rights reserved.
//

import UIKit
import AVFoundation

class AnalysisViewController: UIViewController, speechFeedbackProtocall, googleSpeechFeedbackProtocall, appleSpeechFeedbackProtocall {
    @IBOutlet weak var titleLabel: LTMorphingLabel!
    enum State{
        case Presentation, Interview, Freestyle
    }
    enum SpeechSystem{
        case Google, Microsoft, Apple
    }
    var state: State = State.Freestyle
    var speechSystem : SpeechSystem = .Google
    
    let synth = AVSpeechSynthesizer()
    
    @IBOutlet weak var interviewQuestionLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var interviewQuestionLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var fullText: String = ""
    var microsoftSpeechAnalyzer = SpeechController()
    var googleSpeechAnalyzer = GoogleSpeechController()
    var appleSpeechAnalyzer = AppleSpeechController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        microsoftSpeechAnalyzer.delegate = self
        googleSpeechAnalyzer.delegate = self
        appleSpeechAnalyzer.delegate = self
        appleSpeechAnalyzer.setupRecognizer()
        
        
        self.delay(0.5) {
            switch self.state{
            case State.Presentation:
                self.titleLabel.text = "You choose Presentation"
            case State.Interview:
                self.view.layoutIfNeeded()
                self.interviewQuestionLabel.alpha = 0.0
                UIView.animate(withDuration: 0.5, animations: {
                    self.interviewQuestionLabelHeightConstraint.constant = 80
                })
                self.interviewQuestionLabel.text = "If you opened your own business, what type of company would it be and why?"
                
                self.delay(4.0, closure: {
                    UIView.animate(withDuration: 1.0, animations: {
                        self.interviewQuestionLabel.alpha = 1.0
                    })
                })
                self.titleLabel.text = "You choose Interview"
            case State.Freestyle:
                self.titleLabel.text = "You choose Freestyle"
            }
            var choiceUtterance : AVSpeechUtterance
            choiceUtterance = AVSpeechUtterance(string: self.titleLabel.text)
            choiceUtterance.voice = AVSpeechSynthesisVoice(language: speechSettings.language.rawValue)
            choiceUtterance.rate = Float(speechSettings.rate.rawValue)!
            
            self.synth.speak(choiceUtterance)
            
            var readyToStart: AVSpeechUtterance
            readyToStart = AVSpeechUtterance(string: "Please click the green button then start when you are ready.")
            readyToStart.voice = AVSpeechSynthesisVoice(language: speechSettings.language.rawValue)
            readyToStart.rate = Float(speechSettings.rate.rawValue)!
            
            
            if self.state == State.Interview{
                self.delay(2.5, closure: {
                    var interviewUtterance : AVSpeechUtterance
                    interviewUtterance = AVSpeechUtterance(string: "Here is your interview question.  " + self.interviewQuestionLabel.text!)
                    interviewUtterance.voice = AVSpeechSynthesisVoice(language: speechSettings.language.rawValue)
                    interviewUtterance.rate = Float(speechSettings.rate.rawValue)!
                    self.synth.speak(interviewUtterance)
                    self.delay(8.0, closure: {
                        self.synth.speak(readyToStart)
                    })
                })
            }
            
            if self.state == State.Freestyle || self.state == State.Presentation {
                self.delay(4.0, closure: {
                    self.synth.speak(readyToStart)
                })
            }
        }
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonClicked(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    var lastLabel: LTMorphingLabel? = nil
    
    func addStringToTotalText(string: String){
        fullText += " " + string
        if lastLabel == nil{
            
            lastLabel = LTMorphingLabel(frame: CGRect(x: 20, y: 0, width: self.view.frame.width - 40, height: 26))
            lastLabel?.text = ""
        }
        let font = UIFont(name: "Panton-Regular", size: 22)
        lastLabel?.font = font
        lastLabel?.morphingEffect = .scale
        lastLabel?.morphingCharacterDelay = 0.07
        
        
        self.scrollView.addSubview(lastLabel!)
        
        var fullAdditionArr = string.characters.split{$0 == " "}.map(String.init)
        print(fullAdditionArr)
        let maxWidth = self.view.frame.width - 40
        let testLabel = LTMorphingLabel(frame: (lastLabel?.frame)!)
        testLabel.font = font
        testLabel.text = lastLabel?.text
        var i = 0
        while fullAdditionArr.count > 0 {
            if i < fullAdditionArr.count{
                testLabel.text = testLabel.text + " " + fullAdditionArr[i]
            }
            let width = testLabel.intrinsicContentSize.width
            if width > maxWidth || i == fullAdditionArr.count  {
                //                for j in 0..<i {
                //                    self.lastLabel?.text =  lastLabel!.text + " " + fullAdditionArr[j]
                //                }
                var textToAdd = ""
                for _ in 0..<i {
                    textToAdd += " " + fullAdditionArr.remove(at: 0)
                }
                self.lastLabel?.text = self.lastLabel!.text + textToAdd
                print(fullAdditionArr)
                if i < fullAdditionArr.count {
                    let newLabel = LTMorphingLabel(frame: CGRect(x: lastLabel!.frame.origin.x, y: lastLabel!.frame.origin.y + 28, width: lastLabel!.frame.width, height: lastLabel!.frame.height))
                    newLabel.font = font
                    newLabel.text = ""
                    testLabel.text = ""
                    newLabel.morphingEffect = .scale
                    newLabel.morphingCharacterDelay = 0.07
                    self.scrollView.addSubview(newLabel)
                    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: newLabel.frame.origin.y + newLabel.frame.height + 40)
                    lastLabel = newLabel
                }
                i = -1
                
            }
            
            i += 1
        }
        
        print("Done")
        
    }
    
    
    var shouldEnd = false
    var timeElapsed = 0.0
    var startTime:CFAbsoluteTime?
    
    
    @IBAction func startClicked(_ sender: AnyObject) {
        
        if let button = sender as? UIButton, sender.tag == 11{
            if button.titleLabel?.text == "Start"{
                startTime = CFAbsoluteTimeGetCurrent()
                if speechSystem == .Microsoft{
                    print("Started MICROSOFT")
                    microsoftSpeechAnalyzer.startButton_Click(nil)
                }else if speechSystem == .Google{
                    print("Started GOOGLE")
                    googleSpeechAnalyzer.recordAudio(nil)
                }else if speechSystem == .Apple{
                    print("Started APPLE")
                    appleSpeechAnalyzer.startSpeech()
                }
                shouldEnd = false
                button.backgroundColor = UIColor(red: 204.0 / 254.0, green: 44.0 / 255.0, blue: 22.0/255.0, alpha: 1.0)
                button.setTitle("End", for: .normal)
            }else{
                let endTime = CFAbsoluteTimeGetCurrent()
                let secondDiff = endTime - startTime!
                timeElapsed += secondDiff
                shouldEnd = true
                button.backgroundColor = UIColor(red: 0.0 / 254.0, green: 126.0 / 255.0, blue: 11.0/255.0, alpha: 1.0)
                button.setTitle("Start", for: .normal)
                if speechSystem == .Microsoft{
                    if microsoftSpeechAnalyzer.inProgress == false && !skipTextAnalysis{
                        startTextAnalysis()
                    }
                }else if speechSystem == .Google{
                    if !SpeechRecognitionService.sharedInstance().isStreaming() && !skipTextAnalysis{
                        startTextAnalysis()
                    }else{
                        googleSpeechAnalyzer.stopAudio(nil)
                        delay(1.0, closure: { 
                            self.startTextAnalysis()
                        })
                    }
                }else if speechSystem == .Apple{
                    if !appleSpeechAnalyzer.audioEngine.isRunning && !skipTextAnalysis{
                        startTextAnalysis()
                    }
                }
                
            }
            skipTextAnalysis = false
        }
        
    }
    
    
    // MARK: - Speech Delegates MICROSOFT
    
    func finalRecognitionRecieved(_ phrase: RecognizedPhrase!) {
        //        print("Final Recognition \(phrase.displayText)")
        self.addStringToTotalText(string: phrase.displayText)
        if !shouldEnd{
            microsoftSpeechAnalyzer.startButton_Click(nil)
        }else{
            startTextAnalysis()
        }
    }
    
    
    @IBOutlet weak var partialTextLabel: LTMorphingLabel!
    
    func partialRecognitionRecieved(_ phrase: String!) {
        partialTextLabel.text = phrase
    }
    
    func errorRecieved(_ error: String!) {
        partialTextLabel.text = error
        if !shouldEnd{
            self.delay(1.0, closure: {
                self.microsoftSpeechAnalyzer.startButton_Click(nil)
            })
        }else{
            
            startTextAnalysis()
        }
    }
    
    // MARK: - Speech Delegates GOOGLE
    
    func finalGoogleRecognitionRecieved(_ phrase: String!) {
        self.addStringToTotalText(string: phrase + ".")
        if !shouldEnd{
            googleSpeechAnalyzer.recordAudio(nil)
        }else{
            startTextAnalysis()
        }
        print("Final Google String recieved - \(phrase)")
    }
    
    func partialGoogleRecognitionRecieved(_ phrase: String!) {
        partialTextLabel.text = phrase
        print("Partial Google String recieved - \(phrase)")
    }
    
    func errorGoogleRecieved(_ error: String!) {
        partialTextLabel.text = error
        if !shouldEnd{
            self.delay(0.2, closure: {
                self.googleSpeechAnalyzer.recordAudio(nil)
            })
        }else{
            startTextAnalysis()
        }
        print("Error Google Recieved - \(error)")
    }
    
    // MARK: - Speech Delegates APPLE
    func finalAppleRecognitionRecieved(phrase: String) {
        self.addStringToTotalText(string: phrase)
        if !shouldEnd{
            delay(0.2, closure: {
                self.appleSpeechAnalyzer.startSpeech()
            })
        }else{
            startTextAnalysis()
        }
        print("Final Apple String recieved - \(phrase)")
    }
    
    func partialAppleRecognitionRecieved(phrase: String) {
        partialTextLabel.text = phrase
        if phrase.characters.last == "."{
            print("Sentence Ended")
            appleSpeechAnalyzer.endSpeech()
        }
        print("Partial Apple String recieved - \(phrase)")
    }
    
    func errorAppleRecieved(error: String) {
        partialTextLabel.text = error
        if !shouldEnd{
            self.delay(0.2, closure: {
                self.appleSpeechAnalyzer.recordButtonTapped()
            })
        }else{
            
            startTextAnalysis()
        }
        print("Error Apple Recieved - \(error)")
    }
    
    // MARK: - Text Analysis
    var progressHUD = MBProgressHUD()
    var analysisText = ""
    var speechWordCount = ""
    var speechTime = ""
    var fillerWordsStr = ""
    var sentimentAnalysisStr = ""
    var textView: UITextView = UITextView()
    func startTextAnalysis(){
        print("Start Text Analysis")
        if speechResultsView != nil {
            speechResultsView!.removeFromSuperview()
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        analysisText = ""
        speechWordCount = ""
        speechTime = ""
        fillerWordsStr = ""
        sentimentAnalysisStr = ""
        
        progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHUD.mode = .indeterminate
        progressHUD.label.text = "Analyzing your speech"
        progressHUD.bezelView.color = UIColor(white: 1.0, alpha: 1.0)
        progressHUD.label.textColor = UIColor.darkGray
        progressHUD.detailsLabel.text = "Please wait a moment"
        progressHUD.detailsLabel.textColor = UIColor.darkGray
        progressHUD.activityIndicatorColor = UIColor.darkGray
        progressHUD.dimBackground = true
        
        print("Full text - \(fullText)")
        var tempFullText = fullText.replacingOccurrences(of: ".", with: " ")
        tempFullText = tempFullText.replacingOccurrences(of: ",", with: "")
        let fullTextArr = tempFullText.characters.split{$0 == " "}.map(String.init)
        var freqDictionary = [String: Int]()
        for word in fullTextArr{
            if freqDictionary[word.lowercased()] != nil{
                freqDictionary[word.lowercased()]! += 1
            }else{
                freqDictionary[word.lowercased()] = 1
            }
        }
        print(freqDictionary)
        analysisText = "Great Speech!"
        speechWordCount = "\n\nYour Speech was a total of:\n  \(fullTextArr.count) Words"
        speechTime = "\n\nYour total speech time was:\n  \(Int(timeElapsed) /  60) minutes and \(Int(timeElapsed) % 60) seconds"
        print("TIME ELAPSED \(timeElapsed)")
        let fillerWords = ["um","uh", "umm","basically", "like", "okay", "well", "hmm","Actually", "Seriously", "So"]
        fillerWordsStr = ""
        for filler in fillerWords{
            if freqDictionary[filler.lowercased()] != nil{
                if fillerWordsStr == ""{
                    fillerWordsStr = "\n\nYou used filler words like: "
                }
                var fillerAddStr = "\n  \(filler): \(freqDictionary[filler.lowercased()]!) time"
                if freqDictionary[filler.lowercased()]! > 1{
                    fillerAddStr += "s"
                }
                fillerWordsStr += fillerAddStr
            }
        }
        if fillerWordsStr == ""{
            fillerWordsStr = "\n\nGood Job!  Your speech was free of Filler words\n"
        }
        
        // sentiment analysis
        var fullSentDict = [String:Array<[String:String]>]()
        var documentsArr = [[String:String]]()
        let allwords = freqDictionary.keys
        var id = 1
        for word in allwords{
            var innerDict = [String:String]()
            innerDict["id"] = "\(word)"
            innerDict["text"] = word
            innerDict["language"] = "en"
            documentsArr.append(innerDict)
            id += 1
        }
        fullSentDict["documents"] = documentsArr
        var bodyData:Data?
        do{
            
        try bodyData = JSONSerialization.data(withJSONObject: fullSentDict, options: [])
        }catch{
            print("JSON Serialization failed")
        }
        
//        print("JSON - \(NSString(data: bodyData!, encoding: String.Encoding.utf8.rawValue))")
//        print("\(NSString(data: bodyData!, encoding: ))")
        var request = URLRequest(url: URL(string: "https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/sentiment")!)
        request.httpMethod = "POST"
        request.setValue("c0ad10de41184a0592cbc6afee31ce7f", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("Response RECIEVED")
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            let json = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Array<[String:AnyObject]>]
            let docArray = json["documents"] as Array<[String:AnyObject]>!
            var allScores = [Double]()
            for dict in docArray!{
                let score = dict["score"]!.doubleValue
                allScores.append(score!)
            }
            allScores.sort()
            var negWords = [String](repeating: "", count: 4)
            var posWords = [String](repeating: "", count: 4)
            var negValues = Array(allScores[0..<4])
            var posValues = Array(Array(allScores[allScores.count - 4..<allScores.count]).reversed())
            for dict in docArray!{
                let score = dict["score"]!.doubleValue
                allScores.append(score!)
                if let index = negValues.index(of: score!) {
                    negWords[index] = dict["id"] as! String
                }
                if let index = posValues.index(of: score!) {
                    posWords[index] = "hi"
                    posWords[index] = dict["id"] as! String
                }
            }
            print(posValues)
            print(posWords)
            print(negValues)
            print(negWords)
            let doubleFormat = 0.3
            self.sentimentAnalysisStr = "\n\nSentiment Analysis"
            var positiveWords = "\n Your most positive words are:\n   "
            for word in posWords{
                positiveWords += word + ", "
            }
            positiveWords += "\n With scores of:\n   "
            for score in posValues{
                positiveWords += String(format: "%.3f, ", score)
            }
            
            var negativeWords = "\n\nYour most negative words are:\n   "
            for word in negWords{
                negativeWords += word + ", "
            }
            negativeWords += "\n With scores of:\n   "
            for score in negValues{
                negativeWords += String(format: "%.3f, ",score)
            }
            self.sentimentAnalysisStr += positiveWords + negativeWords
            self.delay(0.0, closure: {
                self.finishSpeechAnalyticsFadeIn()
            })
        }
        task.resume()
        
        analysisText = analysisText + speechWordCount + speechTime + fillerWordsStr + self.sentimentAnalysisStr
        
        let speechResultsVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SpeechResultsVC") as! SpeechResultsViewController
        
        speechResultsVC.view.frame =   CGRect(x: 40, y: 80, width: self.view.frame.width - 80, height: self.view.frame.height - 160)
        speechResultsView = speechResultsVC.view!
        speechResultsView!.alpha = 0.0
        
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: speechResultsView!.frame.width, height: 50))
        titleLabel.font = UIFont(name: "Panton-SemiBold", size: 26)
        titleLabel.text = "Nice Work!"
        titleLabel.textAlignment = .center
        speechResultsView!.addSubview(titleLabel)
        
        textView = UITextView(frame: CGRect(x: 10, y: 70, width: speechResultsView!.frame.width - 20, height: speechResultsView!.frame.height - 90))
        textView.font = UIFont(name: "Panton-Regular", size: 20)
        textView.isSelectable = true
        textView.isEditable = false
        textView.text = analysisText
        speechResultsView!.addSubview(textView)
        
        let hideButton = UIButton(frame: CGRect(x: speechResultsView!.frame.width - 50, y: 0, width: 50, height: 50))
        hideButton.setImage(UIImage(named:"cancel"), for: .normal)
        hideButton.addTarget(self, action: #selector(AnalysisViewController.closeSpeechAnalytics), for: .touchUpInside)
        speechResultsView!.addSubview(hideButton)
        
        
        self.view.addSubview(speechResultsView!)
        UIView.animate(withDuration: 1.0) {
            self.speechResultsView!.alpha = 1.0
            //            speechResultsView.center = CGPoint(x: speechResultsView.center.x, y: speechResultsView.center.y + 50)
            
        }
        
        
    }
    
    var speechResultsView: UIView? = UIView()
    
    func closeSpeechAnalytics(){
        UIView.animate(withDuration: 1.0, animations: {
            self.speechResultsView!.center.y = self.speechResultsView!.center.y - 50
            self.speechResultsView!.alpha = 0.0
            
            }) { (finished) in
                self.speechResultsView!.removeFromSuperview()
                self.speechResultsView = nil
        }
        MBProgressHUD.hide(for: self.view, animated: true)
        
    }
    
    
    func finishSpeechAnalyticsFadeIn(){
       let analysisText = "Great Speech!" + speechWordCount + speechTime + fillerWordsStr + self.sentimentAnalysisStr
        textView.text = analysisText
    }
    
    
    // MARK: - Settings
    var settingsView = UIView()
    
    var skipTextAnalysis = false
    @IBAction func changeRecognitionSettings(_ sender: AnyObject) {
        if startButton.titleLabel?.text == "End"{
            skipTextAnalysis = true
            startClicked(startButton)
        }
        settingsView.removeFromSuperview()
        settingsView = UIView(frame: CGRect(x: 40, y: 100, width: self.view.frame.width - 80, height: self.view.frame.height - 200))
        settingsView.backgroundColor = UIColor(red: 0.616, green: 0.718, blue: 0.965, alpha: 1.00)
        settingsView.layer.cornerRadius = 10
        self.view.addSubview(settingsView)
        settingsView.alpha = 0.0
        settingsView.center.y = settingsView.center.y - 50
        UIView.animate(withDuration: 1.0) { 
            self.settingsView.alpha = 1.0
            self.settingsView.center.y = self.settingsView.center.y + 50
        }
        
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: settingsView.frame.width, height: 50))
        titleLabel.font = UIFont(name: "Panton-SemiBold", size: 28)
        titleLabel.textAlignment = .center
        titleLabel.text = "Settings"
        self.settingsView.addSubview(titleLabel)
        
        let segLabel = UILabel(frame: CGRect(x:0, y:60, width: settingsView.frame.width, height: 30))
        segLabel.text = "Speech Recognition API"
        segLabel.textAlignment = .center
        segLabel.font = UIFont(name: "Panton-Regular", size: 20)
        self.settingsView.addSubview(segLabel)
        
        let segmentedControl = UISegmentedControl(items: ["Microsoft", "Apple", "Google"])
        segmentedControl.frame = CGRect(x:10, y:95, width: settingsView.frame.width - 20, height:35)
        segmentedControl.tintColor = UIColor.white
        segmentedControl.addTarget(self, action: #selector(AnalysisViewController.recogChanged(segmentedControl:)), for: .valueChanged)
        self.settingsView.addSubview(segmentedControl)
        
        switch speechSystem {
        case .Microsoft:
            segmentedControl.selectedSegmentIndex = 0
        case .Apple:
            segmentedControl.selectedSegmentIndex = 1
        case .Google:
            segmentedControl.selectedSegmentIndex = 2
        default:
            segmentedControl.selectedSegmentIndex = 1
        }
        let dismissButton = UIButton(frame: CGRect(x: settingsView.frame.width - 40,y: 5,width: 35,height: 35))
        dismissButton.setImage(UIImage(named: "cancel"), for: .normal)
        self.settingsView.addSubview(dismissButton)
        dismissButton.addTarget(self, action: #selector(AnalysisViewController.dismissSettings), for: .touchUpInside)
        
    }
    
    func dismissSettings(){
        UIView.animate(withDuration: 1.0, animations: { 
            self.settingsView.alpha = 0.0
            self.settingsView.center.y = self.settingsView.center.y - 50
            }) { (finished) in
                self.settingsView.removeFromSuperview()
        }
    }
    
    func recogChanged(segmentedControl : UISegmentedControl) {
        print("Seg Changed - \(segmentedControl.selectedSegmentIndex)")
        if microsoftSpeechAnalyzer.inProgress {
            
        }
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            print("Switch to Microsoft")
            speechSystem = .Microsoft
        case 1:
            print("Switch to Apple")
            speechSystem = .Apple
        case 2:
            print("Switch to Google")
            speechSystem = .Google
        default:
            print("Something went wrong")
        }
    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
