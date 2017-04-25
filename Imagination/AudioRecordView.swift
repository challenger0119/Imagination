//
//  AudioRecordView.swift
//  Imagination
//
//  Created by Star on 2017/4/25.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit
class AudioRecordView: UIView {

    @IBOutlet weak var audoMeterView: UIProgressView!
    var vRecorder:VoiceRecord?
    override func awakeFromNib() {
        vRecorder = VoiceRecord(filename: "")
    }
    @IBAction func startBtnClicked(_ sender: UIButton) {
        if vRecorder != nil {
            vRecorder?.startRecord()
        }
    }
    @IBAction func PauseBtnClicked(_ sender: UIButton) {
        if vRecorder != nil {
            vRecorder?.startRecord()
        }
    }
    @IBAction func StopBtnClicked(_ sender: UIButton) {
        if vRecorder != nil {
            vRecorder?.stopRecord()
        }
    }
    @IBAction func PlayBtnClicked(_ sender: UIButton) {
        if vRecorder != nil {
            vRecorder?.playRecord()
        }
    }
    class func getView()->AudioRecordView?{
        if let vv = Bundle.main.loadNibNamed("AudioRecordView", owner: nil, options: nil) {
            return vv.first as? AudioRecordView
        }else{
            return nil
        }
    }

}
