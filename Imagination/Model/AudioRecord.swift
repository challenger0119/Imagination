//
//  AudioRecord.swift
//  Imagination
//
//  Created by Star on 2017/4/25.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecord {
    fileprivate var recorder:AVAudioRecorder!
    fileprivate var player:AVAudioPlayer!  //有初始化关联，所以不能直接访问 容易出错
    var recordFileURL:URL{
        get{
            return self.recorder.url
        }
    }
    var audioFile:URL!
    let setting = [AVSampleRateKey:NSNumber(value:Float(8000.0)),
                   AVFormatIDKey:NSNumber(value:Int(kAudioFormatLinearPCM)),
                   AVLinearPCMBitDepthKey:NSNumber(value:Int(16)),
                   AVNumberOfChannelsKey:NSNumber(value:Int(1)),
                   AVLinearPCMIsFloatKey:NSNumber(value:Bool(true)),
                   AVEncoderAudioQualityKey:NSNumber(value:Int(AVAudioQuality.high.rawValue))]
    
    init(withFile file:String = "") {
        var audiofile = FileManager.tmpAudioFilePath()
        if file != "" {
            audiofile = file
        }
        audioFile = URL(fileURLWithPath: audiofile)
        do{
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [])
        }catch{
            Dlog(error.localizedDescription)
        }
    }

    func startRecord(){
        do{
            if recorder == nil {
                recorder = try AVAudioRecorder(url: audioFile,settings: setting)
                recorder.isMeteringEnabled = true
                Dlog("prepareToRecord \(recorder.prepareToRecord())")
            }
            try AVAudioSession.sharedInstance().setActive(true)
            recorder.record()
        }catch{
            Dlog(error.localizedDescription)
        }
    }
    
    func pauseRecord(){
        recorder.pause()
    }
    
    func stopRecord(){
        self.recorder.stop()
        let tsession = AVAudioSession.sharedInstance()
        do{
            try tsession.setActive(false)
        }catch{
            Dlog(error.localizedDescription)
        }
    }
    
    func playRecord(){
        do{
            if player == nil {
                self.player = try AVAudioPlayer.init(contentsOf: self.audioFile)
                self.player.isMeteringEnabled = true
                Dlog("prepareToPlay \(player.prepareToPlay())")
            }
            try AVAudioSession.sharedInstance().setActive(true)
            
            self.player.play()
        }catch{
            Dlog(error.localizedDescription)
        }
    }
    
    func stopPlayRecord(){
        self.player.stop()
        do{
            try AVAudioSession.sharedInstance().setActive(false)
        }catch{
            Dlog(error.localizedDescription)
        }
    }

    func averagePower(forChannel channel:Int)->Float{
        self.recorder.updateMeters()
        return self.recorder.averagePower(forChannel:channel)
    }
    
    func peekPower(forChannel channel:Int)->Float{
        self.recorder.updateMeters()
        return self.recorder.peakPower(forChannel: channel)
    }
    
    func playerAveragePower(forChannel channel:Int)->Float{
        self.player.updateMeters()
        return self.player.averagePower(forChannel:channel)
    }
    
    func playerPeekPower(forChannel channel:Int)->Float{
        self.player.updateMeters()
        return self.player.peakPower(forChannel: channel)
    }
    
    func playerDuration()->TimeInterval{
        if player == nil {
            do {
                self.player = try AVAudioPlayer.init(contentsOf: self.audioFile)
            }catch{
                Dlog(error.localizedDescription)
            }
        }
        return player.duration
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
