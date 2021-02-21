//
//  ViewControlle.swift
//  MusicInstruments
//
//  Created by 이석민 on 2020/05/25.
//  Copyright © 2020 Martin Mitrevski. All rights reserved.
//
import UIKit
import AVKit
import SoundAnalysis
import UserNotifications //푸쉬알람 설정
import Haptico
import WatchConnectivity

class ViewController: UIViewController {
    var sirendelay = true
    var dogbarkdelay = true
    var carhorndelay = true
    var speechdelay = true
    var timer = Timer()
    //레코드버튼
    
    @IBOutlet weak var leftcorner: UIView!
    @IBOutlet weak var rightcorner: UIView!
    private let audioEngine = AVAudioEngine()
    private var soundClassifier = MySoundClassifier2_15()
    var streamAnalyzer: SNAudioStreamAnalyzer!
    let queue = DispatchQueue(label: "사운드 헬퍼")
    var isOn = false //onoff
    var results = [(label: String, confidence: Float)]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    var set:SetController = SetController();
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "사운드 헬퍼"
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: {didAllow,Error in })
        UNUserNotificationCenter.current().delegate = self
        leftcorner.clipsToBounds = true
        leftcorner.layer.cornerRadius = 25
        leftcorner.layer.maskedCorners = CACornerMask.layerMinXMinYCorner
        rightcorner.clipsToBounds = true
        rightcorner.layer.cornerRadius = 25
        rightcorner.layer.maskedCorners = CACornerMask.layerMaxXMinYCorner
        self.navigationController?.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        self.tableView.backgroundColor = UIColor.clear
        
    }
    //녹음 시작함수
    public func startAudioEngine() {
        audioEngine.prepare()
        do {
            try audioEngine.start()
            
        } catch {
            showAudioError()
        }
    }
    //녹음중지 함수
    public func stopAudioEngine(){
        
        audioEngine.stop()
    }
    
    public func convert(id: String) -> String {
        let mapping = ["car_horn" : "car_horn", "dogBark" : "dogBark",
                       "Music" : "Music",
                       "Noise"  :"Noise","Pink noise":"Pink noise","Inside, public space":"Inside, public space", "Siren":"Siren","speech":"speech","White noise":"White noise", "Wind" :"Wind"]
        return mapping[id] ?? id
    }
    
    //녹음준비
    private func prepareForRecording() {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        streamAnalyzer = SNAudioStreamAnalyzer(format: recordingFormat)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            [unowned self] (buffer, when) in
            self.queue.async {
                self.streamAnalyzer.analyze(buffer,
                                            atAudioFramePosition: when.sampleTime)
            }
        }
        startAudioEngine()
    }
    
    
    private func createClassificationRequest() {
        do {
            let request = try SNClassifySoundRequest(mlModel: soundClassifier.model)
            try streamAnalyzer.add(request, withObserver: self)
        } catch {
            fatalError("error adding the classification request")
        }
    }
    
    //RECORDING 이 시작되도록 하는 버튼
    @IBAction func startRecordingButtonTapped(_ sender: UIButton) {
        //Vibration()

        isOn = !isOn
        if isOn == true{
            prepareForRecording()
            createClassificationRequest()
            print("음성인식 시작상태")
            
        }
        else{
            audioEngine.inputNode.removeTap(onBus: 0) //stop() 함수를 사용하면 오류가 발생
            stopAudioEngine()
            print("음성인식 종료상태")
            
        }
        
    }
    
}

extension ViewController: UITableViewDataSource {
    //테이블 Cell의 row를 지정하는 함수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
        
        
    }
    //테이블 Cell의 내용을 return하는 함수
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell")
        //dequeueReusableCell 셀의 메모리를 절약
        cell?.backgroundColor = UIColor.clear
        cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
        cell?.textLabel?.sizeToFit()
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.textColor = UIColor.white
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "ResultCell")
        }
        let result = results[indexPath.row]
        let label = convert(id: result.label)
        cell!.textLabel!.text = "\(label): \(result.confidence)"
        return cell!
    }
    /*
     public func convert(id: String) -> String {
     let mapping = ["car_horn" : "car_horn", "dogBark" : "dogBark",
     "Music" : "Music",
     "Noise"  :"Noise","Pink noise":"Pink noise","Rail transport":"Rail transport", "Rain on surface":"Rain on surface","Raindrop":"Raindrop","Siren":"Siren","speech":"speech","White noise":"White noise", "Wind" :"Wind"]
     return mapping[id] ?? id
     }*/
}

extension ViewController: SNResultsObserving {
    func request(_ request: SNRequest, didProduce result: SNResult) {
        let notvc : notification = notification();
        guard let result = result as? SNClassificationResult else { return }
        var temp = [(label: String, confidence: Float)]()
        let sorted = result.classifications.sorted { (first, second) -> Bool in
            return first.confidence > second.confidence
        }
        for classification in sorted {
            let confidence = classification.confidence * 100
            if confidence > 5 {
                temp.append((label: classification.identifier, confidence: Float(confidence)))
                print("\(classification.identifier)")
                print("정확도","\(confidence)")
                if classification.identifier == "Inside, public space" && confidence > 1 && speechdelay == true{
                    stopAudioEngine()
                    audioEngine.inputNode.removeTap(onBus: 0)
                    notvc.speechnotification()
                    Vibration()
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2500), execute: {
                        self.prepareForRecording()
                        self.createClassificationRequest()
                    })
                    speechdelay = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
                        self.speechdelay = true
                    })
                }
                if classification.identifier == "Siren" && confidence > 98.0 && sirendelay == true{
                    stopAudioEngine()
                    audioEngine.inputNode.removeTap(onBus: 0)
                    notvc.sirennotification()
                    Vibration()
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2500), execute: {
                        self.prepareForRecording()
                        self.createClassificationRequest()
                    })
                    sirendelay = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
                        self.sirendelay = true
                    })
                }
                if classification.identifier == "dogBark" && confidence > 99 && dogbarkdelay == true{
                    stopAudioEngine()
                    audioEngine.inputNode.removeTap(onBus: 0)
                    notvc.dogbarknotification()
                    Vibration()
                    dogbarkdelay = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2500), execute: {
                        self.prepareForRecording()
                        self.createClassificationRequest()
                    })
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
                        self.dogbarkdelay = true
                    })
                }
                if classification.identifier == "car_horn" && confidence > 99.9 && carhorndelay == true{
                    stopAudioEngine()
                    audioEngine.inputNode.removeTap(onBus: 0)
                    notvc.carhornnotification()
                    Vibration()
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2500), execute: {
                        self.prepareForRecording()
                        self.createClassificationRequest()
                    })
                    carhorndelay = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
                        self.carhorndelay = true
                    })
                }
            }
        }
        
        results = temp
        
    }
    func Vibration(){
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        print("First Vibration")
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            print("Second vibration")
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            print("Third Vibrationn")
         })

    }
}
extension ViewController : UNUserNotificationCenterDelegate {
    //To display notifications when app is running  inforeground
    
    //앱이 foreground에 있을 때. 즉 앱안에 있어도 push알림을 받게 해줍니다.
    //viewDidLoad()에 UNUserNotificationCenter.current().delegate = self를 추가
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        let settingsViewController = UIViewController()
        settingsViewController.view.backgroundColor = .gray
        self.present(settingsViewController, animated: true, completion: nil)
        
    }
}

extension ViewController {
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAudioError() {
        let errorTitle = "Audio Error"
        let errorMessage = "Recording is not possible at the moment."
        self.showAlert(title: errorTitle, message: errorMessage)
    }
    
}

