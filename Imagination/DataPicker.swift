//
//  DataPicker.swift
//  Imagination
//
//  Created by Star on 15/12/10.
//  Copyright © 2015年 Star. All rights reserved.
//

import UIKit
protocol DataPickerDelegate {
    func dataPickerResult(first:String,second:String)
}
class DataPicker: UIView,UIPickerViewDelegate,UIPickerViewDataSource {
    let catalogue = DataCache.shareInstance.catalogue
    var from:String
    var to:String
    let delegate:DataPickerDelegate
    init(frame: CGRect, dele:DataPickerDelegate) {
        self.from = "from"
        self.to = "to"
        
        
        self.delegate = dele
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 0.3
        self.layer.cornerRadius = 5
        let conform = UIButton.init(frame: CGRectMake(self.frame.size.width - 50, 5,30, 30))
        conform.setImage(UIImage.init(named: "check"), forState: UIControlState.Normal)
        conform.addTarget(self, action: "conform", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(conform)
        let cancel = UIButton.init(frame: CGRectMake(20, 5,30, 30))
        cancel.setImage(UIImage.init(named: "cancel"), forState: UIControlState.Normal)
        cancel.addTarget(self, action: "cancel", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(cancel)
        let pickerView = UIPickerView.init(frame: CGRectMake(0, 30, self.frame.size.width, self.frame.size.height-30))
        pickerView.delegate = self
        pickerView.dataSource = self
        self.addSubview(pickerView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func conform() {
        self.removeFromSuperview()
        if from == "from" {
            return
        } else if to == "to" {
            return
        }
        delegate.dataPickerResult(from, second: to)
    }
    func cancel() {
        self.removeFromSuperview()
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row != 0 {
            if component == 0 {
                from = catalogue![row-1]
            } else {
                to = catalogue![row-1]
            }
            print("\(from)-\(to)")
        }
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        if let vv = view {
            print("reusing")
            let tmp = vv as! UILabel
            if row == 0 {
                if component == 0 {
                    tmp.text = "From"
                } else if component == 1{
                    tmp.text = "To"
                }
            } else {
                tmp.text = catalogue![row-1]
            }
            return tmp
        } else {
            print("not reusing")
            let label = UILabel.init(frame: CGRectMake(0, 0, pickerView.frame.size.width/2, 40))
            label.textAlignment = NSTextAlignment.Center
            if row == 0 {
                if component == 0 {
                    label.text = "From"
                } else if component == 1{
                    label.text = "To"
                }
            } else {
                label.text = catalogue![row-1]
            }
            return label
        }
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let cata = catalogue {
            return cata.count+1
        } else {
            return 1
        }
    }
}
