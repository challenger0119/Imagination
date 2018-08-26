//
//  MainTableViewController.swift
//  Imagination
//
//  Created by Star on 16/1/5.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController,CatalogueViewControllerDelegate {

    @IBOutlet weak var moodIndicatorView: UIView!   // 心情色指示条
    var cool = 0    // 舒服状态的记录数量
    var ok = 0      // 一般般状态的记录数量
    var why = 0     // 不爽状态的记录数量
    
    var dataSource:[Item] = []  // 内容数据源
    
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

    // 解析一个月的数据生成数据源
    func loadMonthData() {
        DispatchQueue.global().async {
            let monthCache = DataCache.shareInstance.lastMonth // 一个月的记录
            self.cool = 0
            self.ok = 0
            self.why = 0
            if let mcache = monthCache {
                var dayArray = Array(mcache.keys)
                dayArray.sort(by: {$0>$1})      // 降序排列日期 精确到天
                self.dataSource.removeAll()
                for daytime in dayArray {
                    if let day = mcache[daytime] {
                        var tmpTimes = Array(day.keys)
                        tmpTimes.sort(by: {$0>$1})      //降序排列时间 精确到秒以下
                        
                        for ct in tmpTimes {
                            let cc = Item(withTime: daytime + " " + ct, contentString: day[ct]!)
                            switch cc.mood {
                            case .Cool: self.cool += 1
                            case .OK: self.ok += 1
                            case .Why: self.why += 1
                            default:break
                            }
                            self.dataSource.append(cc)       //添加数据源
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshMoodState()
            }
        }
    }
    
    // 更新状态条
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
            left = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: height))
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
    
    // 关闭归档视图
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
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier",for: indexPath) as! CustomTableViewCell
        let cc = dataSource[indexPath.row]
        cell.time.text = cc.timeString
        // 去掉内容里面的换行 避免cell过高
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
        
        let vc = ContentShowViewController(withItem:dataSource[indexPath.row])
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.alpha = 0
        self.tabBarController?.present(vc, animated: false, completion: {
            UIView.animate(withDuration: 0.2, animations: {
                vc.view.alpha = 1
            })
        })
    }
}
