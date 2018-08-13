//
//  AudioViewController.swift
//  Imagination
//
//  Created by Star on 2017/4/27.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit

class AudioViewController: UIViewController {

    
    init(withFile file:String) {
        self.filePath = file
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var filePath:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let audioView = AudioRecordView.getView()
        audioView?.frame = CGRect(x: 0, y: (self.view.frame.height-200)/2, width: self.view.frame.width, height: 200)
        audioView?.onlyPlayBack(fileToPlay: self.filePath)
        self.view.addSubview(audioView!)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeVC))
    }
    @objc func closeVC(){
        self.dismiss(animated: true, completion: {
            
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
