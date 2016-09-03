//
//  DayList.swift
//  Imagination
//
//  Created by Star on 15/12/6.
//  Copyright © 2015年 Star. All rights reserved.
//

import UIKit
protocol DayListDelegate {
    func didSelectItem(item:String)
}

class DayList: UIView,UITableViewDelegate,UITableViewDataSource {
    var table = UITableView()
    let content:[String]
    let delegate:DayListDelegate
    
    init(frame: CGRect, cc:[String],dele:DayListDelegate) {
        self.content = cc
        self.table.frame = CGRectMake(0, 0, frame.width, 0)
        self.delegate = dele
        super.init(frame: frame)
        self.layer.borderColor = UIColor.blueColor().CGColor
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 0.5
        self.backgroundColor = UIColor.whiteColor()
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, 0)
        self.table.delegate = self
        self.table.dataSource = self
        self.addSubview(table)
        
        
        UIView.beginAnimations("showTable", context: nil)
        UIView.setAnimationDuration(0.3)
        let viewHeight:CGFloat = frame.height
        var actualHeight:CGFloat = CGFloat(content.count*40)
        if viewHeight < actualHeight {
            actualHeight = viewHeight
        }
        self.table.frame = CGRectMake(0,0, frame.width, actualHeight)
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, actualHeight)
        UIView.commitAnimations()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        Dlog("didselect\(indexPath.row)")
        delegate.didSelectItem(content[indexPath.row])
        self.removeFromSuperview()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40.0
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        if let cell = table.dequeueReusableCellWithIdentifier("daylistcell") {
            cell.textLabel?.text = content[indexPath.row]
            return cell
        } else {
            let cell = UITableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: "daylistcell")
            cell.textLabel?.text = content[indexPath.row]
            return cell
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
       return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return content.count
    }
}
