//
//  ViewController.swift
//  Imagination
//
//  Created by Star on 15/11/14.
//  Copyright © 2015年 Star. All rights reserved.
//

import UIKit
class ViewController: UITableViewController,DayListDelegate {
    
    var dayCache:Dictionary<String,String>?
    var times:[String]?
    var content:[String]?
    var daylist:DayList?
    let TAG_DAYLIST:NSInteger = 100
    @IBOutlet weak var today: UINavigationItem!
    
    @IBAction func otherDay(sender: UIBarButtonItem) {
        if let nav = self.navigationController {
            if let tmpList = nav.view.viewWithTag(TAG_DAYLIST) {
                tmpList.removeFromSuperview()
            }else{
                if let cata = DataCache.shareInstance.catalogue {
                    daylist = DayList(frame: CGRectMake(0, nav.navigationBar.frame.height+20, 130, nav.view.frame.height), cc: cata.reverse(),dele:self)
                    daylist?.tag = TAG_DAYLIST
                    self.navigationController?.view.addSubview(daylist!)
                }
            }
        } else {
            //几乎不可能是这种 只是方便
            if let tmpList = self.view.viewWithTag(TAG_DAYLIST) {
                tmpList.removeFromSuperview()
            }else{
                if let cata = DataCache.shareInstance.catalogue {
                    daylist = DayList(frame: CGRectMake(0, 0, 150, self.view.frame.height), cc: cata.reverse(),dele:self)
                    daylist?.tag = TAG_DAYLIST
                    self.navigationController?.view.addSubview(daylist!)
                }
            }
        }
        
    }
 
    func didSelectItem(item: String) {
        DataCache.shareInstance.loadLastDayToDay(item)
        today.title = item
        loadData()
    }
    
    func loadData() {
        dayCache = DataCache.shareInstance.lastDay
        if let day = dayCache {
            times?.removeAll()
            content?.removeAll()
            times = Array(day.keys)
            
            if  times != nil  {
                times?.sortInPlace({$0>$1})
                for ct in times! {
                    if content == nil {
                        content = Array.init(arrayLiteral: day[ct]!)
                    }  else {
                        content?.append(day[ct]!)
                    }
                }
                
            }
        }
        self.tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let storeboad = UIStoryboard.init(name: "Main", bundle: NSBundle.mainBundle())
        let vc = storeboad.instantiateViewControllerWithIdentifier("authority")
        self.presentViewController(vc, animated: true, completion: nil)
    }
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
        DataCache.shareInstance.loadLastDay()
        today.title = DataCache.shareInstance.lastDayName
        
        loadData()
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidDisappear(animated: Bool) {
        daylist?.removeFromSuperview()
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let day = dayCache {
            return day.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("xxxxx",forIndexPath: indexPath) as! CustomCell
        cell.time.text = times![indexPath.row]
        cell.content.text = content![indexPath.row]
        
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storeboad = UIStoryboard.init(name: "Main", bundle: NSBundle.mainBundle())
        let vc = storeboad.instantiateViewControllerWithIdentifier("editmind") as! EditImagination
        vc.text = content![indexPath.row]
        vc.editMode = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

