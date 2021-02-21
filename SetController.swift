//
//  SetController.swift
//  MusicInstruments
//
//  Created by 이석민 on 2020/05/25.
//  Copyright © 2020 Martin Mitrevski. All rights reserved.
//

import UIKit
import AudioToolbox
import Haptico

class SetController : UIViewController{
    @IBOutlet weak var ExplainCorner: UIView!
    var not : notification = notification();
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    let generator_li = UIImpactFeedbackGenerator(style: .light)
    
    @IBOutlet weak var StackCorner: UIStackView!
    
    
    @IBOutlet weak var StackCorner1: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        StackCorner.clipsToBounds = true
        StackCorner.layer.cornerRadius = 10
        StackCorner.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner)
        view.backgroundColor = UIColor.white
        
        ExplainCorner.clipsToBounds = true
        ExplainCorner.layer.cornerRadius = 10
        ExplainCorner.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner)
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
    }
    
    
    
    @IBAction func carhorn(_ sender: UIButton) {
        if sender.isSelected {
            print("Carhorn Noti On")
            Haptico.shared().generateFeedbackFromPattern(".oOOOO-O", delay: 0.07)
            carhornbool = true
            sender.isSelected = false
        } else {
            carhornbool = false
            sender.isSelected = true
            Haptico.shared().generateFeedbackFromPattern("Oo....-.", delay: 0.07)
            print("Carhorn Noti Off")
        }
    }
    @IBAction func Siren(_ sender: UIButton) {
        generator.impactOccurred()
        if sender.isSelected {
            sirenbool = true
            print("Siren Noti On")
             Haptico.shared().generateFeedbackFromPattern(".oOOOO-O", delay: 0.07)
            sender.isSelected = false
        } else {
            sirenbool = false
            sender.isSelected = true
                 Haptico.shared().generateFeedbackFromPattern("Oo....-.", delay: 0.07)
         
            print("Siren Noti Off")
        }
    }
    
    @IBAction func Speech(_ sender: UIButton) {
        if sender.isSelected {
            speechbool = true
            print("Humen Noti On")
            Haptico.shared().generateFeedbackFromPattern(".oOOOO-O", delay: 0.07)
            generator.impactOccurred()
            sender.isSelected = false
        } else {
            speechbool = false
            print("Human Noti Off")
             Haptico.shared().generateFeedbackFromPattern("Oo....-.", delay: 0.07)
           
            sender.isSelected = true
        }
    }
    
    
    @IBAction func Dog(_ sender: UIButton) {
        if sender.isSelected {
            dogbool = true
            print("Dog Noti On")
            Haptico.shared().generateFeedbackFromPattern(".oOOOO-O", delay: 0.07)
            generator.impactOccurred()
            sender.isSelected = false
        } else {
            dogbool = false
            print("Dog Noti Off")
             Haptico.shared().generateFeedbackFromPattern("Oo....-.", delay: 0.07)
           
            sender.isSelected = true
        }
    }

}
