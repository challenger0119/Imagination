//
//  VoiceRecord.swift
//  Imagination
//
//  Created by Star on 2017/4/25.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit
import AVFoundation
class VoiceRecord: NSObject {
    
    var recorder:AVAudioRecorder?
    var player:AVAudioPlayer?
    var session:AVAudioSession
    init(filename:String) {
        self.session = AVAudioSession.sharedInstance()
        
        let recordSetting = [AVSampleRateKey:8000.0,
                             AVFormatIDKey:kAudioFormatLinearPCM,
                             AVLinearPCMBitDepthKey:16,
                             AVNumberOfChannelsKey:1,
            AVEncoderAudioQualityKey:AVAudioQuality.high]  as [String : Any]
        
        do {
            try self.recorder = AVAudioRecorder(url: URL.init(fileURLWithPath: FileManager.audioFilePathWithName(name: filename)), settings: recordSetting)
        }
        catch{
            Dlog(error.localizedDescription)
        }
        super.init()
        
        do{
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setActive(true)
        }catch{
            Dlog(error.localizedDescription)
        }
    }
    func startRecord(){
        if recorder != nil {
            self.recorder?.isMeteringEnabled = true
            self.recorder?.prepareToRecord()
            self.recorder?.record()
        }
    }
    func stopRecord(){
        if recorder != nil && recorder!.isRecording {
            Dlog("录音时长：\(recorder!.currentTime))")
            do{
                let file = try FileManager.default.attributesOfItem(atPath: recorder!.url.absoluteString)
                Dlog(file)
            }catch{
                Dlog(error.localizedDescription)
            }
            recorder?.stop()
        }
    }
    func pauseRecord(){
        if recorder != nil && recorder!.isRecording{
            recorder?.pause()
        }
    }
    func playRecord(){
        if recorder != nil && recorder!.isRecording {
            recorder?.stop()
        }
        if player == nil {
            do{
                player = try AVAudioPlayer(contentsOf: recorder!.url)
            }catch{
                Dlog(error.localizedDescription)
            }
        }
        if player!.isPlaying {
            return
        }else{
            do{
                try self.session.setCategory(AVAudioSessionCategoryPlayback)
                player?.play()
            }catch{
                Dlog(error.localizedDescription)
            }
        }
    }

}
