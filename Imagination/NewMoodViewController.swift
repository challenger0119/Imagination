//
//  NewMoodViewController.swift
//  Imagination
//
//  Created by Star on 2016/10/27.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit

class NewMoodViewController: UIViewController {

    @IBOutlet weak var content: UIScrollView!
    var editMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func leftBtnClicked(_ sender: UIButton) {
    }
    @IBAction func rightBtnClicked(_ sender: UIButton) {
    }
    @IBAction func getLocation(_ sender: UIButton) {
    }
    
    
    @IBAction func selectImage(_ sender: UIButton) {
    }
    @IBAction func recordVoice(_ sender: UIButton) {
    }
    @IBAction func pickVideo(_ sender: UIButton) {
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        Dlog("didReceiveMemoryWarning")
    }

}
