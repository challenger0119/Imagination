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

    @IBOutlet weak var moodIndicatorView: UIView!   // 心情色指示条
    var cool = 0    // 舒服状态的记录数量
    var ok = 0      // 一般般状态的记录数量
    var why = 0     // 不爽状态的记录数量
    
    var times:[String] = []     // 日期数据源
    var itemBuffer:[Item] = []  // 内容数据源
    
    // MARK: - LifeCycle
    
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
    
    // MARK: - Method
    
    // 显示/关闭日期归档
    @IBAction func otherDay(_ sender:AnyObject) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CatalogueViewController") as! CatalogueViewController;
        vc.modalPresentationStyle = .overCurrentContext;
        vc.delegate = self
        if let cata = DataCache.shareInstance.catalogue_month {
            vc.content = cata.reversed()
        }
        self.present(vc, animated: false, completion: {
            var tframe = self.view.frame
            tframe.origin.x = CatalogueViewController.tableWidth;
            tframe.size.width = self.view.frame.width - CatalogueViewController.tableWidth
            UIView.animate(withDuration: 0.2) {
                self.navigationController?.view.frame = tframe;
                self.view.alpha = 0.7
            }
        })
    }
    
    // 添加新mood后更新
    @objc func updateMonthData() {
        DataCache.shareInstance.loadLastMonth()
        self.title = DataCache.shareInstance.currentMonthName
        
        loadMonthData()
    }
    
    // 指纹识别
    func authorityView() {
        if AuthorityViewController.pWord != AuthorityViewController.NotSet{
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "authority") as! AuthorityViewController
            self.present(vc, animated: true, completion: {
                vc.useTouchId()
            })
        }
    }

    func loadMonthData() {
        let monthCache = DataCache.shareInstance.lastMonth // 一个月的记录
        cool = 0
        ok = 0
        why = 0
        if let mm = monthCache {
            var dayArray = Array(mm.keys)
            dayArray.sort(by: {$0>$1})      // 降序排列日期 精确到天
            times.removeAll()
            itemBuffer.removeAll()
            for daytime in dayArray {
                if let day = mm[daytime] {
                    var tmpTimes = Array(day.keys)
                    tmpTimes.sort(by: {$0>$1})      //降序排列时间 精确到秒
                    
                    for ct in tmpTimes {
                        let cc = Item(contentString: day[ct]!)
                        switch cc.mood {
                            case 1:cool+=1
                            case 2:ok+=1
                            case 3:why+=1
                            default:break
                        }
                        
                        itemBuffer.append(cc)       //添加数据源
                    }
                    times.append(contentsOf: changeTimeToDayAndTime(tmpTimes, day: daytime))
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
        let partition_a = self.moodIndicatorView.frame.width * CGFloat(cool) / CGFloat(total)
        let partition_b = self.moodIndicatorView.frame.width * CGFloat(cool + ok) / CGFloat(total)
        let height = self.moodIndicatorView.frame.height / 2
        
        
        var left:UIView! = self.moodIndicatorView.viewWithTag(1)
        var center:UIView! = self.moodIndicatorView.viewWithTag(2)
        var right:UIView! = self.moodIndicatorView.viewWithTag(3)
        
        var firstTime = false
        
        if left == nil {
            firstTime = true
            left = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: height))
            left.backgroundColor = Item.coolColor
            left.tag = 1;
            self.moodIndicatorView.addSubview(left)
        }
        if center == nil{
            center = UIView.init(frame: CGRect(x: partition_a, y: 0, width: 0, height: height))
            center.backgroundColor = Item.justOkColor
            center.tag = 2;
            self.moodIndicatorView.addSubview(center)
        }
        if right == nil{
            right = UIView.init(frame: CGRect(x: partition_b, y: 0,width: 0, height: height))
            right.backgroundColor = Item.whyColor
            right.tag = 3;
            self.moodIndicatorView.addSubview(right)
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
                                right.frame = CGRect(x: partition_b, y: 0, width: self.moodIndicatorView.frame.width - partition_b, height: height)
                            })
                        }
                    })
                }
            })
        }else{
            UIView.animate(withDuration: 0.1, animations: {
                left.frame = CGRect(x: 0, y: 0, width: partition_a, height: height)
                center.frame = CGRect(x: partition_a, y: 0, width: partition_b - partition_a, height: height)
                right.frame = CGRect(x: partition_b, y: 0, width: self.moodIndicatorView.frame.width - partition_b, height: height)
            })
        }
    }
    

    func resumeView(andDo:@escaping (()->Void)){
        var tframe = self.view.frame
        tframe.size.width = self.view.frame.width + CatalogueViewController.tableWidth
        tframe.origin.x = 0
        
        UIView.animate(withDuration: 0.2, animations: { 
            self.navigationController?.view.frame = tframe;
        }) { (boo) in
            if boo {
                andDo()
            }
        }
    }
    
    // MARK: - CatalogueViewControllerDelegate
    
    func catalogueDidSelectItem(item: String){
        resumeView(){
            DataCache.shareInstance.loadLastMonthToMonth(item)
            self.title = item
            self.loadMonthData()
            self.refreshMoodState()
        }
    }
    func catalogueDidClose() {
        resumeView(){}
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 1
        })
    }
    
    // MARK: - Table view data source and Delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemBuffer.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier",for: indexPath) as! CustomTableViewCell
        let cc = itemBuffer[indexPath.row]
        cell.time.text = times[indexPath.row]
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
        
        let cc = itemBuffer[indexPath.row]
        let vc = ContentShowViewController(contentText: cc.content, contentDic: cc.multiMedias, state: cc.mood, placeInfo: cc.place)
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.alpha = 0
        self.tabBarController?.present(vc, animated: false, completion: {
            UIView.animate(withDuration: 0.2, animations: {
                vc.view.alpha = 1
            })
        })
    }
}
