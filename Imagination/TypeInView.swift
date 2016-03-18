//
//  TypeInView.swift
//  Imagination
//
//  Created by Star on 16/3/18.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit
protocol TypeInViewDelegate {
    func confirmWithStringResult(result:String)
}
class TypeInView: UIView {

    var delegate:TypeInViewDelegate?
    var adjustedNumber = ""
    @IBOutlet weak var numberOperator: UIButton!
    @IBOutlet weak var number: UITextField!
    @IBOutlet weak var note: UITextField!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func changeOperator() {
        let sheet = UIAlertController.init(title: "选择算符", message: nil, preferredStyle: .ActionSheet)
        sheet.addAction(UIAlertAction.init(title: "+", style: .Default, handler: {
            at in
            self.adjustedNumber = at.title!
            self.numberOperator.setTitle(self.adjustedNumber, forState: .Normal)
        }))
        sheet.addAction(UIAlertAction.init(title: "-", style: .Default, handler: {
            at in
            self.adjustedNumber = at.title!
            self.numberOperator.setTitle(self.adjustedNumber, forState: .Normal)
        }))
        self.window?.rootViewController?.presentViewController(sheet, animated: true, completion: {
        })
    }
    
    
    func alert(content:String) {
        let alert = UIAlertController.init(title: "提示", message: content, preferredStyle: .Alert)
        alert.addAction(UIAlertAction.init(title: "好的", style: .Cancel, handler: {
            at in
            
        }))
        self.window?.rootViewController?.presentViewController(alert, animated: true, completion: {
            
        })
    }
    
    
    @IBAction func confirm() {
      
        if number.text == nil || number.text!.isEmpty || Int(number.text!) == 0 {
            self.alert("请在“数字栏”填写数字")
            return
        }
        if let del = self.delegate {
            let string = "\(numberOperator.titleLabel!.text!)\(number.text!) - \(self.note.text == nil ? "" : self.note.text!)"//-300-note??
            del.confirmWithStringResult(string)
        }
    }

    class func View() -> TypeInView? {
        return NSBundle.mainBundle().loadNibNamed("TypeInView", owner: nil, options: nil).first as? TypeInView
    }
}
