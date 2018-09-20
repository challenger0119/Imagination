//
//  DataPickerViewController.swift
//  Imagination
//
//  Created by YouJuny on 2018/9/20.
//  Copyright © 2018年 Star. All rights reserved.
//

import UIKit

class DataPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var backView: UIView!
    @IBOutlet var pickerView: UIPickerView!
    
    let catalogue = DataCache.share.catalogue
    var from:String = "from"
    var to:String = "to"
    var selected:((_ from:String, _ to:String) -> Void)?
    var blurImageView:UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        self.view.alpha = 0;
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.backView.layer.cornerRadius = 10
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.2) {
            self.view.alpha = 1.0
        }
    }
    
    func exit(action:@escaping (() -> Void)){
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 0
        }) { (finish) in
            if finish {
                self.dismiss(animated: false, completion: {
                    action()
                })
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.exit {
            
        }
    }
    
    @IBAction func selected(_ sender: Any) {
        if from == "from" {
            return
        } else if to == "to" {
            return
        }else{
            self.exit {
                if self.selected != nil {
                    self.selected!(self.from, self.to)
                }
            }
        }
    }
    
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row != 0 {
            if component == 0 {
                from = catalogue[row-1]
            } else {
                to = catalogue[row-1]
            }
            Dlog("\(from)-\(to)")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        if let vv = view {
            let tmp = vv as! UILabel
            if row == 0 {
                if component == 0 {
                    tmp.text = "From"
                } else if component == 1{
                    tmp.text = "To"
                }
            } else {
                tmp.text = catalogue[row-1]
            }
            return tmp
        } else {
            let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: pickerView.frame.size.width/2, height: 40))
            label.textAlignment = NSTextAlignment.center
            if row == 0 {
                if component == 0 {
                    label.text = "From"
                } else if component == 1{
                    label.text = "To"
                }
            } else {
                label.text = catalogue[row-1]
            }
            return label
        }
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return catalogue.count + 1
    }
}
