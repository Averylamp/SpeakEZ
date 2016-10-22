//
//  ModeViewController.swift
//  PresentorPractice
//
//  Created by Avery Lamp on 10/22/16.
//  Copyright © 2016 Isometric. All rights reserved.
//

import UIKit
import AVFoundation

class ModeViewController: UIViewController {

    let synth = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var myUtterance : AVSpeechUtterance
        myUtterance = AVSpeechUtterance(string: "Please pick what you would like to practice today, presentation or interview.  Or pick freestyle to analyze any speeech.")
        myUtterance.voice = AVSpeechSynthesisVoice(language: speechSettings.language.rawValue)
        myUtterance.rate = Float(speechSettings.rate.rawValue)!
        self.delay(1.0) {
//            self.synth.speak(myUtterance)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func presentationClicked(_ sender: AnyObject) {
        let analysisVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AnalysisVC") as! AnalysisViewController
        analysisVC.state = AnalysisViewController.State.Presentation
        self.synth.stopSpeaking(at: .immediate)
        self.navigationController?.pushViewController(analysisVC, animated: true)
    }
    @IBAction func interviewClicked(_ sender: AnyObject) {
        let analysisVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AnalysisVC") as! AnalysisViewController
        analysisVC.state = AnalysisViewController.State.Interview
        self.synth.stopSpeaking(at: .immediate)
        self.navigationController?.pushViewController(analysisVC, animated: true)
        
    }
    @IBAction func freestyleClicked(_ sender: AnyObject) {
        let analysisVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AnalysisVC") as! AnalysisViewController
        analysisVC.state = AnalysisViewController.State.Freestyle
        self.synth.stopSpeaking(at: .immediate)
        self.navigationController?.pushViewController(analysisVC, animated: true)
        
    }

}
