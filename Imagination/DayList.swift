//
//  DayList.swift
//  Imagination
//
//  Created by Star on 15/12/6.
//  Copyright © 2015年 Star. All rights reserved.
//

import UIKit
protocol DayListDelegate {
    func didSelectItem(_ item:String)
}

class DayList: UIView,UITableViewDelegate,UITableViewDataSource {
    var table = UITableView()
    let content:[String]
    let delegate:DayListDelegate
    
    init(frame: CGRect, cc:[String],dele:DayListDelegate) {
        self.content = cc
        self.table.frame = CGRect(x: 0, y: 0, width: frame.width, height: 0)
        self.delegate = dele
        super.init(frame: frame)
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 0.5
        self.backgroundColor = UIColor.white
        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 0)
        self.table.delegate = self
        self.table.dataSource = self
        self.table.clipsToBounds = true
        self.addSubview(table)
        
        
        UIView.beginAnimations("showTable", context: nil)
        UIView.setAnimationDuration(0.3)
        let viewHeight:CGFloat = frame.height
        var actualHeight:CGFloat = CGFloat(content.count*40)
        if viewHeight < actualHeight {
            actualHeight = viewHeight
        }
        self.table.frame = CGRect(x: 0,y: 0, width: frame.width, height: actualHeight)
        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: actualHeight)
        UIView.commitAnimations()
    }

    func close() {
        UIView.animate(withDuration: 0.3, animations: {
            self.table.frame = CGRect(x: 10,y: 40, width: 0, height: 0)
            self.frame = CGRect(x: 10, y: 40, width: 0, height: 0)
        }) { (finish) in
            if finish {
                self.removeFromSuperview()
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Dlog("didselect\((indexPath as NSIndexPath).row)")
        delegate.didSelectItem(content[(indexPath as NSIndexPath).row])
        close()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if let cell = table.dequeueReusableCell(withIdentifier: "daylistcell") {
            cell.textLabel?.text = content[(indexPath as NSIndexPath).row]
            return cell
        } else {
            let cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "daylistcell")
            cell.textLabel?.text = content[(indexPath as NSIndexPath).row]
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return content.count
    }
}
