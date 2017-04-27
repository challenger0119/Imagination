//
//  AudioRecord.swift
//  Imagination
//
//  Created by Star on 2017/4/25.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit
import AVFoundation
class AudioRecord: NSObject {
    var recorder:AVAudioRecorder!
    var player:AVAudioPlayer!
    var recordFileURL:URL{
        get{
            return self.recorder.url
        }
    }
    var audioFile:URL!
    init(withFile file:String = "") {
        var audiofile = FileManager.audioFilePathWithTimstamp()
        if file != "" {
            audiofile = file
        }
        let session =  AVAudioSession.sharedInstance()
        let setting = [AVSampleRateKey:NSNumber(value:Float(8000.0)),
                       AVFormatIDKey:NSNumber(value:Int(kAudioFormatLinearPCM)),
                       AVLinearPCMBitDepthKey:NSNumber(value:Int(16)),
                       AVNumberOfChannelsKey:NSNumber(value:Int(1)),
                       AVLinearPCMIsFloatKey:NSNumber(value:Bool(true)),
                       AVEncoderAudioQualityKey:NSNumber(value:Int(AVAudioQuality.high.rawValue))]
        do{
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            
            audioFile = URL(fileURLWithPath: audiofile)
            recorder = try AVAudioRecorder(url: audioFile,settings: setting)
            Dlog(recorder.prepareToRecord())
            recorder.isMeteringEnabled = true
        }catch{
            
        }
        super.init()
    }

    func startRecord(){
        let tsession = AVAudioSession.sharedInstance()
        do{
            try tsession.setActive(true)
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
        let tsession = AVAudioSession.sharedInstance()
        do{
            self.player = try AVAudioPlayer.init(contentsOf: self.audioFile)
            self.player!.isMeteringEnabled = true
            try tsession.setActive(true)
            self.player!.play()
        }catch{
            Dlog(error.localizedDescription)
        }
    }
    func stopPlayRecord(){
        self.player.stop()
        let tsession = AVAudioSession.sharedInstance()
        do{
            try tsession.setActive(false)
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
    
}
