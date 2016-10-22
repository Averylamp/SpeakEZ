//
//  AnalysisViewController.swift
//  PresentorPractice
//
//  Created by Avery Lamp on 10/22/16.
//  Copyright © 2016 Isometric. All rights reserved.
//

import UIKit
import AVFoundation

class AnalysisViewController: UIViewController {
    @IBOutlet weak var titleLabel: LTMorphingLabel!
    enum State{
        case Presentation, Interview, Freestyle
    }
    var state: State = State.Freestyle
    let synth = AVSpeechSynthesizer()
    
    @IBOutlet weak var interviewQuestionLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var interviewQuestionLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var fullText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        fullText += string
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
