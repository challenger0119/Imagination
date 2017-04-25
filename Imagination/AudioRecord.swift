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
    var session:AVAudioSession!
    var recorder:AVAudioRecorder!
    var player:AVAudioPlayer!
    
    
    let setting = [AVSampleRateKey:NSNumber(value:Float(8000.0)),
                   AVFormatIDKey:NSNumber(value:Int(kAudioFormatLinearPCM)),
                   AVLinearPCMBitDepthKey:NSNumber(value:Int(16)),
                   AVNumberOfChannelsKey:NSNumber(value:Int(1)),
                   AVLinearPCMIsFloatKey:NSNumber(value:Bool(true)),
                   AVEncoderAudioQualityKey:NSNumber(value:Int(AVAudioQuality.high.rawValue))]

    override init() {
        let audiofile = FileManager.audioFileDefaultPath()
        let session =  AVAudioSession.sharedInstance()
        do{
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            
            let audioFile = URL(fileURLWithPath: audiofile)
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
        do{
            self.player = try AVAudioPlayer.init(contentsOf: self.recorder.url)
            self.player!.play()
        }catch{
            Dlog(error.localizedDescription)
        }
    }
    func stopPlayRecord(){
        self.player.stop()
    }
    
}
