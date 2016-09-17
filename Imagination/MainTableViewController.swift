//
//  MainTableViewController.swift
//  Imagination
//
//  Created by Star on 16/1/5.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit
import CoreLocation
class MainTableViewController: UITableViewController,DayListDelegate {

    @IBOutlet weak var today: UINavigationItem!
    @IBOutlet weak var done: UIBarButtonItem!
    @IBOutlet weak var backView: UIView!
    let isCalculate = false
    
    var cool = 0
    var ok = 0
    var why = 0
    
    var dayCache:Dictionary<String,String>?
    var monthCache:Dictionary<String,Dictionary<String,String>>?
    var times:[String]?
    var content:[String]?
    var daylist:DayList?
    let TAG_DAYLIST:NSInteger = 100
    
    var locToShow:CLLocationCoordinate2D?

    @IBAction func otherDay(_ sender:AnyObject) {
        if let nav = self.navigationController {
            if let tmpList = nav.view.viewWithTag(TAG_DAYLIST) {
                tmpList.removeFromSuperview()
            }else{
                if let cata = DataCache.shareInstance.catalogue_month {
                    daylist = DayList(frame: CGRect(x: 0, y: nav.navigationBar.frame.height+20, width: 130, height: nav.view.frame.height-2*(nav.navigationBar.frame.height+20)), cc: cata.reversed(),dele:self)
                    daylist?.tag = TAG_DAYLIST
                    self.navigationController!.view.addSubview(daylist!)
                }
            }
        } else {
            //几乎不可能是这种 只是方便
            if let tmpList = self.view.viewWithTag(TAG_DAYLIST) {
                tmpList.removeFromSuperview()
            }else{
                if let cata = DataCache.shareInstance.catalogue_month {
                    daylist = DayList(frame: CGRect(x: 0, y: 20, width: 150, height: self.view.frame.height-20), cc: cata.reversed(),dele:self)
                    daylist?.tag = TAG_DAYLIST
                    self.view.addSubview(daylist!)
                }
            }
        }
    }
    
    //MARK: DayListDelegate
    
    func didSelectItem(_ item: String) {
        DataCache.shareInstance.loadLastMonthToMonth(item)
        today.title = item
        loadMonthData()
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
                times?.sort(by: {$0>$1})
                for ct in times! {
                    if content == nil {
                        content = Array.init(arrayLiteral: day[ct]!)
                    }  else {
                        content?.append(day[ct]!)
                        
                    }
                    
                    //赋值moodState
                    let cc = Item.init(contentString: day[ct]!)
                    switch cc.mood {
                    case 1:cool+=1
                    case 2:ok+=1
                    case 3:why+=1
                    default:break
                    }
                }
            }
        }
        self.tableView.reloadData()
    }
    func loadMonthData() {
        monthCache = DataCache.shareInstance.lastMonth
        cool = 0
        ok = 0
        why = 0
        if let mm = monthCache {
            //{2015.1.2:{9:30:xxx,11:30:xxx},2015.1.3:{6:35:ddd,11:07:ddd}}
            var dayArray = Array(mm.keys)//[2015.1.2,2015.1.3]
            dayArray.sort(by: {$0>$1})//[2015.1.3,2015.1.2]
            times?.removeAll()
            content?.removeAll()
            for daytime in dayArray {
                if let day = mm[daytime] {//{9:30:xxx,11:30:xxx}
                    var tmpTimes = Array(day.keys)//[9:30,11:30]
                    tmpTimes.sort(by: {$0>$1})//[11:30,9:30]
                    
                    for ct in tmpTimes {
                        if content == nil {//xxx
                            content = Array.init(arrayLiteral: day[ct]!)
                        }  else {
                            content?.append(day[ct]!)
                            
                        }
                        //赋值moodState
                        let cc = Item.init(contentString: day[ct]!)
                        switch cc.mood {
                        case 1:cool+=1
                        case 2:ok+=1
                        case 3:why+=1
                        default:break
                        }
                    }
                    if times == nil {
                        times = Array(changeTimeToDayAndTime(tmpTimes, day: daytime))
                    } else {
                        times?.append(contentsOf: changeTimeToDayAndTime(tmpTimes, day: daytime))
                    }
                }
            }
        }
        self.tableView.reloadData()
        
    }
    
    func changeTimeToDayAndTime(_ timearry:[String],day:String) -> [String]{
        //添加日期信息在里面 9：30 -> 2015.2.3 9:30
        var newArray = [String]()
        for tt in timearry {
            newArray.append(day+" "+tt)
        }
        return newArray
    }

    func differentWillAppear() {
        if isCalculate {
            
        }else {
            DataCache.shareInstance.loadLastMonth()
            today.title = DataCache.shareInstance.currentMonthName
            loadMonthData()
        }
    }
    
    func differentDidAppear(){
        if isCalculate {
            
        }else{
            refreshMoodState()
            self.authorityView()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.differentWillAppear()
        NotificationCenter.default.addObserver(self, selector: #selector(differentWillAppear), name: NSNotification.Name(rawValue: Notification.keyForNewMoodAdded), object: nil)
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.differentDidAppear()
    }
    
    func authorityView() {
        if AuthorityViewController.pWord != "" && DataCache.shareInstance.isStart {
            let storeboad = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            let vc = storeboad.instantiateViewController(withIdentifier: "authority")
            self.present(vc, animated: true, completion: {
                
            })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        daylist?.removeFromSuperview()
    }
    
    func refreshMoodState() {
        let total = cool + ok + why
        if total == 0 {
            //如果没有moodState 就return
            return
        }
        let partition_a = self.backView.frame.width * CGFloat(cool) / CGFloat(total)
        let partition_b = self.backView.frame.width * CGFloat(cool + ok) / CGFloat(total)
        let height = self.backView.frame.height / 2
        
        
        var left:UIView! = self.backView.viewWithTag(1)
        var center:UIView! = self.backView.viewWithTag(2)
        var right:UIView! = self.backView.viewWithTag(3)
        var firstTime = false
        if left == nil {
            firstTime = true
            left = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: height))
            left.backgroundColor = Item.coolColor
            left.tag = 1;
            self.backView.addSubview(left)
        }
        if center == nil{
            center = UIView.init(frame: CGRect(x: partition_a, y: 0, width: 0, height: height))
            center.backgroundColor = Item.justOkColor
            center.tag = 2;
            self.backView.addSubview(center)
        }
        if right == nil{
            right = UIView.init(frame: CGRect(x: partition_b, y: 0,width: 0, height: height))
            right.backgroundColor = Item.whyColor
            right.tag = 3;
            self.backView.addSubview(right)
        }
        
        if firstTime == true {
            firstTime = false
            UIView.animate(withDuration: 0.1, animations: {
                left.frame = CGRect(x: 0, y: 0, width: partition_a, height: height)
                }, completion: {
                    finish in
                    if finish {
                        UIView.animate(withDuration: 0.1, animations: {
                            center.frame = CGRect(x: partition_a, y: 0, width: partition_b - partition_a, height: height)
                            }, completion: {
                                finish in
                                if finish {
                                    UIView.animate(withDuration: 0.1, animations: {
                                        right.frame = CGRect(x: partition_b, y: 0, width: self.backView.frame.width - partition_b, height: height)
                                    })
                                }
                        })
                    }
            })
        }else{
            UIView.animate(withDuration: 0.1, animations: {
                left.frame = CGRect(x: 0, y: 0, width: partition_a, height: height)
                center.frame = CGRect(x: partition_a, y: 0, width: partition_b - partition_a, height: height)
                right.frame = CGRect(x: partition_b, y: 0, width: self.backView.frame.width - partition_b, height: height)
            })
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let day = content {
            return day.count
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier",for: indexPath) as! CustomTableViewCell
        let cc = Item.init(contentString: content![(indexPath as NSIndexPath).row])
        cell.time.text = times![(indexPath as NSIndexPath).row]
        cell.content.text = cc.content
        cell.time.textColor = cc.color
        cell.content.textColor = cc.color
        cell.locLabel.text = cc.place.name
        cell.locLabel.textColor = cc.color
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cc = Item.init(contentString: content![(indexPath as NSIndexPath).row])
        if !cc.place.name.isEmpty {
            self.locToShow = CLLocationCoordinate2D(latitude: cc.place.latitude, longitude: cc.place.longtitude)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
            vc.placeToShow = self.locToShow
            self.navigationController?.pushViewController(vc, animated: true)
        }
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

}
