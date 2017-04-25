//
//  AudioRecordView.swift
//  Imagination
//
//  Created by Star on 2017/4/25.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit
import AVFoundation
enum RecordState:Int {
    case None,Recording,Pausing,Playing,Over,Save
}

protocol AudioRecordViewDelegate {
    func audioRecordViewStateChanged(state:RecordState)
}
class AudioRecordView: UIView,AVAudioRecorderDelegate {

    @IBOutlet weak var audoMeterView: UIProgressView!
    
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var stateLabel: UILabel!
    var meterTimer:Timer?
    var delegate:AudioRecordViewDelegate?
    var stateString = "Ready"
    var state:RecordState = .None{
        didSet{
            if delegate != nil {
                delegate?.audioRecordViewStateChanged(state: state)
            }
            switch state {
            case .Recording:
                self.startBtn.isEnabled = false
                self.pauseBtn.isEnabled = true
                self.stopBtn.isEnabled = true
                self.playBtn.isEnabled = false
                self.saveBtn.isEnabled = false
                self.stateLabel.text = "Recording.."
            case .Pausing:
                self.startBtn.isEnabled = true
                self.pauseBtn.isEnabled = false
                self.stopBtn.isEnabled = true
                self.playBtn.isEnabled = false
                self.saveBtn.isEnabled = false
                self.stateLabel.text = "Paused"
            case .Playing:
                self.startBtn.isEnabled = false
                self.pauseBtn.isEnabled = false
                self.stopBtn.isEnabled = true
                self.playBtn.isEnabled = false
                self.saveBtn.isEnabled = true
                self.stateLabel.text = "Playing.."
            case .Over:
                self.startBtn.isEnabled = true
                self.pauseBtn.isEnabled = false
                self.stopBtn.isEnabled = false
                self.playBtn.isEnabled = true
                self.saveBtn.isEnabled = true
                self.stateLabel.text = stateString
            case .None:
                self.startBtn.isEnabled = true
                self.pauseBtn.isEnabled = false
                self.stopBtn.isEnabled = false
                self.playBtn.isEnabled = false
                self.saveBtn.isEnabled = false
                self.stateLabel.text = "Ready"
            case .Save:
                break
            }
        }
    }
    
    var aRecord:AudioRecord!
    override func awakeFromNib() {
        aRecord = AudioRecord()
    }
    @IBAction func startBtnClicked(_ sender: UIButton) {
        aRecord.startRecord()
        state = .Recording
        meterTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    @IBAction func PauseBtnClicked(_ sender: UIButton) {
        aRecord.pauseRecord()
        state = .Pausing
        meterTimer?.invalidate()
    }
    @IBAction func StopBtnClicked(_ sender: UIButton) {

        if state == .Playing {
            state = .Over
            aRecord.stopPlayRecord()
        }else{
            state = .Over
            aRecord.stopRecord()
            self.meterTimer?.invalidate()
            do{
                let atr = try FileManager.default.attributesOfItem(atPath: FileManager.audioFileDefaultPath())
                let size = atr[FileAttributeKey("NSFileSize")] as! Int
                self.stateString = "\(String(describing: Int(size / 1024)))Kb"
                self.stateLabel.text = stateString
            }catch{
                Dlog(error.localizedDescription)
            }
        }
    }
    @IBAction func PlayBtnClicked(_ sender: UIButton) {
        state = .Playing
        aRecord.playRecord()
    }
    @IBAction func saveBtnClicked(_ sender: UIButton) {
        delegate?.audioRecordViewStateChanged(state: .Save)
        self.removeFromSuperview()
    }
    class func getView()->AudioRecordView?{
        if let vv = Bundle.main.loadNibNamed("AudioRecordView", owner: nil, options: nil) {
            return vv.first as? AudioRecordView
        }else{
            return nil
        }
    }
    
    func updateProgress(){
        self.aRecord.recorder.updateMeters()
        let power = aRecord.recorder.averagePower(forChannel:0)
        self.audoMeterView.setProgress((power+160)/160, animated: true)
    }
}
