//
//  notification.swift
//  MusicInstruments
//
//  Created by 이석민 on 2020/05/05.
//  Copyright © 2020 Martin Mitrevski. All rights reserved.
//

import Foundation
import UserNotifications
import SwiftUI
import UIKit
import Haptico

public var carhornbool : Bool = true
public var sirenbool : Bool = true
public var speechbool : Bool = true
public var dogbool : Bool = true
//딜레이 타임

class notification {

    func sirennotification(){
        if sirenbool == true{
            let content = UNMutableNotificationContent()
            content.title = "Sound helper"
            content.subtitle = "사이렌 소리가 들립니다. 주변을 둘러보세요! \u{1F6A8}"
            content.badge = 1
            let date = Date(timeIntervalSinceNow: 70)
            let dateCompenents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            _ = UNCalendarNotificationTrigger(dateMatching: dateCompenents, repeats: true)
            //2. Use TimeIntervalNotificationTrigger
            let TimeIntervalTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
            let request = UNNotificationRequest(identifier: "\(String(describing: index))timerdone", content: content, trigger: TimeIntervalTrigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            Haptico.shared().generateFeedbackFromPattern("OOOO", delay: 0.1)
        }else if sirenbool == false{
            print("sirenbool'valuse is false")
        }
    }
    func carhornnotification(){
        if carhornbool == true{
            let content = UNMutableNotificationContent()
            content.title = "Sound helper"
            content.subtitle = "자동차 경적소리가 들립니다. \u{1F699}" //자동차 경적 이모티콘
            content.badge = 1
            let date = Date(timeIntervalSinceNow: 70)
            let dateCompenents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            
            _ = UNCalendarNotificationTrigger(dateMatching: dateCompenents, repeats: true)
            //2. Use TimeIntervalNotificationTrigger
            let TimeIntervalTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
            let request = UNNotificationRequest(identifier: "\(String(describing: index))timerdone", content: content, trigger: TimeIntervalTrigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            Haptico.shared().generateFeedbackFromPattern("OOO", delay: 0.01)
            
        }else if carhornbool == false{
            print("Carhornbool'value is flase")
        }
    }
    func speechnotification(){
        if speechbool == true{
            let content = UNMutableNotificationContent()
        
            content.title = "Sound helper"
            content.subtitle = "주변에서 대화중입니다. \u{1F9BA}"
            content.badge = 1
            let date = Date(timeIntervalSinceNow: 70)
            let dateCompenents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            
            _ = UNCalendarNotificationTrigger(dateMatching: dateCompenents, repeats: true)
            //2. Use TimeIntervalNotificationTrigger
            let TimeIntervalTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
            let request = UNNotificationRequest(identifier: "\(String(describing: index))timerdone", content: content, trigger: TimeIntervalTrigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }else if speechbool == false{
            print("speechbool'value is false")
        }
    }
    @objc func dogbarknotification(){
        if dogbool == true{
            let content = UNMutableNotificationContent()
            content.title = "sound helper"
            content.subtitle = "강아지가 짖는 소리가 들립니다. \u{1F436}"
            content.badge = 1
            let uuidString = UUID().uuidString
            let date = Date(timeIntervalSinceNow: 70)
            let dateCompenents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            
            _ = UNCalendarNotificationTrigger(dateMatching: dateCompenents, repeats: true)
            //2. Use TimeIntervalNotificationTrigger
            let TimeIntervalTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
            let request = UNNotificationRequest(identifier: uuidString,
                                                   content: content, trigger: TimeIntervalTrigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)



        }
    }
}
