//
//  MainTableViewController.swift
//  Imagination
//
//  Created by Star on 16/1/5.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController,DayListDelegate {

    @IBOutlet weak var today: UINavigationItem!
    @IBOutlet weak var left: UIView!
    @IBOutlet weak var middle: UIView!
    @IBOutlet weak var right: UIView!
    @IBOutlet weak var done: UIBarButtonItem!
    @IBOutlet weak var backView: UIView!
    
    var cool = 0
    var ok = 0
    var why = 0
    
    var dayCache:Dictionary<String,String>?
    var times:[String]?
    var content:[String]?
    var daylist:DayList?
    let TAG_DAYLIST:NSInteger = 100
    
    func initMoodStateColor() {
        self.left.backgroundColor = Item.coolColor
        self.middle.backgroundColor = Item.justOkColor
        self.right.backgroundColor = Item.whyColor
    }
    func disableMoodStateColor() {
        self.left.backgroundColor = UIColor.lightGrayColor()
        self.middle.backgroundColor = UIColor.lightGrayColor()
        self.right.backgroundColor = UIColor.lightGrayColor()
    }
    
    @IBAction func otherDay(sender:AnyObject) {
        if let nav = self.navigationController {
            if let tmpList = nav.view.viewWithTag(TAG_DAYLIST) {
                tmpList.removeFromSuperview()
            }else{
                if let cata = DataCache.shareInstance.catalogue {
                    daylist = DayList(frame: CGRectMake(0, nav.navigationBar.frame.height+20, 130, nav.view.frame.height-2*(nav.navigationBar.frame.height+20)), cc: cata.reverse(),dele:self)
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
                    daylist = DayList(frame: CGRectMake(0, 20, 150, self.view.frame.height-20), cc: cata.reverse(),dele:self)
                    daylist?.tag = TAG_DAYLIST
                    self.navigationController?.view.addSubview(daylist!)
                }
            }
        }
    }
    
    //MARK: DayListDelegate
    
    func didSelectItem(item: String) {
        DataCache.shareInstance.loadLastDayToDay(item)
        today.title = item
        loadData()
        refreshMoodState()
    }
    
    func loadData() {
        dayCache = DataCache.shareInstance.lastDay
        cool = 0
        ok = 0
        why = 0
        
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
                    
                    //赋值moodState
                    let cc = Item.init(contentString: day[ct]!)
                    switch cc.mood {
                    case 1:cool++
                    case 2:ok++
                    case 3:why++
                    default:break
                    }
                }
            }
        }
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if AuthorityViewController.pWord != "" {
            let storeboad = UIStoryboard.init(name: "Main", bundle: NSBundle.mainBundle())
            let vc = storeboad.instantiateViewControllerWithIdentifier("authority")
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    func refreshMoodState() {
        let total = cool + ok + why
        if total == 0 {
            //如果没有moodState 就return
            disableMoodStateColor()
            return
        }
        initMoodStateColor()
        
        let partition_a = self.backView.frame.width * CGFloat(cool) / CGFloat(total)
        let partition_b = self.backView.frame.width * CGFloat(cool + ok) / CGFloat(total)
        
        for ctt in self.backView.constraints {
            if ctt.identifier == "middleLeading" {
                NSLayoutConstraint.deactivateConstraints([ctt])
                let new = NSLayoutConstraint.init(item: self.middle, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.backView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: partition_a)
                new.identifier = "middleLeading"
                self.backView.addConstraint(new)
            } else if ctt.identifier == "rightLeading" {
                NSLayoutConstraint.deactivateConstraints([ctt])
                let new = NSLayoutConstraint.init(item: self.right, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.backView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: partition_b)
                new.identifier = "rightLeading"
                self.backView.addConstraint(new)
            }
        }
        
    }
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
        DataCache.shareInstance.loadLastDay()
        today.title = DataCache.shareInstance.lastDayName
        
        loadData()
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    override func viewDidAppear(animated: Bool) {
        refreshMoodState()
    }
    override func viewDidDisappear(animated: Bool) {
        daylist?.removeFromSuperview()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let day = dayCache {
            return day.count
        }
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier",forIndexPath: indexPath) as! CustomTableViewCell
        let cc = Item.init(contentString: content![indexPath.row])
        cell.time.text = times![indexPath.row]
        cell.content.text = cc.content
        cell.time.textColor = cc.color
        cell.content.textColor = cc.color
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
