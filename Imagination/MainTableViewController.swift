//
//  MainTableViewController.swift
//  Imagination
//
//  Created by Star on 16/1/5.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit
import CoreLocation
class MainTableViewController: UITableViewController,CatalogueViewControllerDelegate {

    @IBOutlet weak var today: UINavigationItem!
    @IBOutlet weak var done: UIBarButtonItem!
    @IBOutlet weak var backView: UIView!
    var cool = 0
    var ok = 0
    var why = 0
    
    var monthCache:Dictionary<String,Dictionary<String,String>>?
    var times:[String]?
    var content:[String]?
    let TAG_DAYLIST:NSInteger = 100
    
    var locToShow:CLLocationCoordinate2D?

    @IBAction func otherDay(_ sender:AnyObject) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CatalogueViewController") as! CatalogueViewController;
        vc.modalPresentationStyle = .overCurrentContext;
        
        if let cata = DataCache.shareInstance.catalogue_month {
            vc.content = cata.reversed()
            vc.delegate = self
        }
        
        self.present(vc, animated: false, completion: {
            var tframe = self.view.frame
            tframe.origin.x = tableWidth;
            tframe.size.width = self.view.frame.width-tableWidth
            UIView.animate(withDuration: 0.2) {
                self.navigationController?.view.frame = tframe;
            }
        })
    }
       //MARK: - vc life circle
    func updateMonthData() {
        DataCache.shareInstance.loadLastMonth()
        today.title = DataCache.shareInstance.currentMonthName
        loadMonthData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateMonthData()
        NotificationCenter.default.addObserver(self, selector: #selector(updateMonthData), name: NSNotification.Name(rawValue: Notification.keyForNewMoodAdded), object: nil)
        authorityView()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshMoodState()
        
    }
    
    func authorityView() {
        if AuthorityViewController.pWord != AuthorityViewController.NotSet{
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "authority") as! AuthorityViewController
            self.present(vc, animated: true, completion: {
                vc.useTouchId()
            })
        }
    }

    func loadMonthData() {
        monthCache = DataCache.shareInstance.lastMonth //{2015.1.2:{9:30:xxx,11:30:xxx},2015.1.3:{6:35:ddd,11:07:ddd}}
        cool = 0
        ok = 0
        why = 0
        if let mm = monthCache {
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
    

    func resumeView(andDo:@escaping ((Void)->Void)){
        var tframe = self.view.frame
        tframe.size.width = self.view.frame.width+tableWidth
        tframe.origin.x = 0
        UIView.animate(withDuration: 0.2) {
            
        }
        UIView.animate(withDuration: 0.2, animations: { 
            self.navigationController?.view.frame = tframe;
        }) { (boo) in
            if boo {
                andDo()
            }
        }
    }
    
    //MARK: - DayListDelegate
    
    func catalogueDidSelectItem(item: String){
        resumeView(){
            DataCache.shareInstance.loadLastMonthToMonth(item)
            self.today.title = item
            self.loadMonthData()
            self.refreshMoodState()
        }

    }
    func catalogueDidClose() {
        resumeView(){
            
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let day = content {
            return day.count
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier",for: indexPath) as! CustomTableViewCell
        let cc = Item(contentString: content![(indexPath as NSIndexPath).row])
        cell.time.text = times![(indexPath as NSIndexPath).row]
        if cc.place.latitude != 0 {
            cell.content.text = cc.content.replacingOccurrences(of: "\n", with: "")+cc.multiMediasDescrip + "\n\n@\(cc.place.name)"
        }else{
            cell.content.text = cc.content.replacingOccurrences(of: "\n", with: "")+cc.multiMediasDescrip
        }
        cell.time.textColor = cc.color
        cell.content.textColor = cc.color
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        let cc = Item(contentString: content![(indexPath as NSIndexPath).row])

        let mshow = MoodShowImageView(frame: UIApplication.shared.keyWindow!.bounds,contentText:cc.content, contentDic: cc.multiMedias,state:cc.mood,placeInfo:cc.place)
        mshow.backgroundColor = UIColor.lightGray
        mshow.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            mshow.alpha = 1
        })
        mshow.image = UIImage.blurImage(of: UIApplication.shared.keyWindow!, withBlurNumber: 1)
        mshow.exitAnimation = {
            mshow.alpha = 0
        }
        UIApplication.shared.keyWindow!.addSubview(mshow)
    }

}
