//
//  DataPicker.swift
//  Imagination
//
//  Created by Star on 15/12/10.
//  Copyright © 2015年 Star. All rights reserved.
//

import UIKit

protocol DataPickerDelegate {
    func dataPickerResult(_ first:String,second:String)
}

class DataPicker: UIView,UIPickerViewDelegate,UIPickerViewDataSource {
    let catalogue = DataCache.share.catalogue
    var from:String
    var to:String
    let delegate:DataPickerDelegate
    init(frame: CGRect, dele:DataPickerDelegate) {
        self.from = "from"
        self.to = "to"
        
        self.delegate = dele
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = UIColor.white
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 0.3
        self.layer.cornerRadius = 5
        let confirm = UIButton.init(frame: CGRect(x: self.frame.size.width - 50, y: 5,width: 30, height: 30))
        confirm.setImage(UIImage.init(named: "check"), for: UIControlState())
        confirm.addTarget(self, action: #selector(DataPicker.confirm), for: UIControlEvents.touchUpInside)
        self.addSubview(confirm)
        let cancel = UIButton.init(frame: CGRect(x: 20, y: 5,width: 30, height: 30))
        cancel.setImage(UIImage.init(named: "cancel"), for: UIControlState())
        cancel.addTarget(self, action: #selector(DataPicker.cancel), for: UIControlEvents.touchUpInside)
        self.addSubview(cancel)
        let pickerView = UIPickerView.init(frame: CGRect(x: 0, y: 30, width: self.frame.size.width, height: self.frame.size.height-30))
        pickerView.delegate = self
        pickerView.dataSource = self
        self.addSubview(pickerView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func confirm() {
        self.removeFromSuperview()
        if from == "from" {
            return
        } else if to == "to" {
            return
        }
        delegate.dataPickerResult(from, second: to)
    }
    
    @objc func cancel() {
        self.removeFromSuperview()
    }
    
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
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return catalogue.count + 1
    }
}
