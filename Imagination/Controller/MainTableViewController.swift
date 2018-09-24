//
//  MainTableViewController.swift
//  Imagination
//
//  Created by Star on 16/1/5.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit
import RealmSwift

class MainTableViewController: UITableViewController,CatalogueViewControllerDelegate {

    @IBOutlet weak var today: UINavigationItem!
    @IBOutlet weak var moodIndicatorView: UIView!   // 心情色指示条
    var cool = 0    // 舒服状态的记录数量
    var ok = 0      // 一般般状态的记录数量
    var why = 0     // 不爽状态的记录数量
    var dataSource:[Item] = []  // 内容数据源
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateMonthData), name: NSNotification.Name(rawValue: Notification.keyForNewMoodAdded), object: nil)
        self.updateMonthData()
        OperationQueue.main.addOperation {
            self.authorityView() // 排个队，当前controller 呈现后显示鉴权页面
        }
 
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: - Method
    
    // 显示/关闭日期归档
    @IBAction func otherDay(_ sender:AnyObject) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CatalogueViewController") as! CatalogueViewController;
        vc.modalPresentationStyle = .overCurrentContext;
        vc.delegate = self
        vc.content = DataCache.share.catalogue_month
        self.tabBarController?.present(vc, animated: false, completion: {
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
        DataCache.share.loadCategory()
        self.title = DataCache.share.currentMonthName
        loadMonthData(DataCache.share.currentMonthName)
    }

    // 指纹识别
    func authorityView() {
        if AuthorityViewController.pWord != AuthorityViewController.NotSet{
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "authority") as! AuthorityViewController
            self.tabBarController?.present(vc, animated: true, completion: {
                vc.useTouchId()
            })
        }
    }

    // 解析一个月的数据生成数据源
    func loadMonthData(_ month:String) {
        guard !month.isEmpty else {
            return
        }
        
        self.cool = 0
        self.ok = 0
        self.why = 0
        
        DataCache.share.loadMonth(monthString: month, result: { (items) in
            self.dataSource.removeAll()
            for cc in items {
                switch cc.moodType {
                case .Cool: self.cool += 1
                case .OK: self.ok += 1
                case .Why: self.why += 1
                default:break
                }
                self.dataSource.append(cc)       //添加数据源
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshMoodState()
            }
        })
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
            left.backgroundColor = MoodType.coolColor
            left.tag = 1;
            self.moodIndicatorView.addSubview(left)
        }
        if center == nil{
            center = UIView.init(frame: CGRect(x: partition_a, y: 0, width: 0, height: height))
            center.backgroundColor = MoodType.justOkColor
            center.tag = 2;
            self.moodIndicatorView.addSubview(center)
        }
        if right == nil{
            right = UIView.init(frame: CGRect(x: partition_b, y: 0,width: 0, height: height))
            right.backgroundColor = MoodType.whyColor
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
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.alpha = 1
                })
                andDo()
            }
        }
    }
    
    // MARK: - CatalogueViewControllerDelegate
    
    func catalogueDidSelectItem(item: String){
        resumeView(){
            self.title = item
            self.loadMonthData(item)
        }
    }
    
    func catalogueDidClose() {
        resumeView(){}
        
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
        cell.time.text = cc.dayString + " " + cc.timeString
        // 去掉内容里面的换行 避免cell过高
        if let plc = cc.location {
            cell.content.text = cc.content.replacingOccurrences(of: "\n", with: "") + cc.getMediaDescription() + "\n\n@\(plc.name)"
        }else{
            cell.content.text = cc.content.replacingOccurrences(of: "\n", with: "") + cc.getMediaDescription()
        }
        cell.time.textColor = cc.moodType.getColor()
        cell.content.textColor = cc.moodType.getColor()
        
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
