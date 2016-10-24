//
//  SplashViewController.swift
//  PresentorPractice
//
//  Created by Avery Lamp on 10/22/16.
//  Copyright © 2016 Isometric. All rights reserved.
//

import UIKit
import AVFoundation
enum speechSettings: String{
    case language = "en-US"
    case rate = "0.5"
}

class SplashViewController: UIViewController {
    
    
    
    let synth = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var myUtterance : AVSpeechUtterance
        myUtterance = AVSpeechUtterance(string: "Welcome to Presentor Practice.  We can help you prepare for presentations, interviews, or simply record your performance.  Click Get started to continue.")
        myUtterance.voice = AVSpeechSynthesisVoice(language: speechSettings.language.rawValue)
        myUtterance.rate = Float(speechSettings.rate.rawValue)!
        self.delay(1.0) {
            self.synth.speak(myUtterance)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getStartedClicked(_ sender: AnyObject) {
        let modeVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ModeVC")
        self.synth.stopSpeaking(at: .immediate)
        self.navigationController?.setViewControllers([modeVC], animated: true)
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

extension UIViewController{
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
