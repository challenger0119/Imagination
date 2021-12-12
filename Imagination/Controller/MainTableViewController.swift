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
    var dataSource:[Item] = []  // 内容数据源
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateMonthData), name: NSNotification.Name(rawValue: Notification.keyForNewMoodAdded), object: nil)
        self.updateMonthData()
        OperationQueue.main.addOperation {
            self.authorityView() // 排个队，当前controller 呈现后显示鉴权页面
        }
 
        let swipeToChangeMonthGesture = UISwipeGestureRecognizer(target: self, action: #selector(otherDay(_:)))
        swipeToChangeMonthGesture.direction = .right
        self.view.addGestureRecognizer(swipeToChangeMonthGesture)
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
        loadMonthData(DataCache.share.updateAndGetCurrentMonthName())
    }

    // 指纹识别
    func authorityView() {
        if AuthorityViewController.pWord != AuthorityViewController.NotSet {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "authority") as! AuthorityViewController
            self.tabBarController?.present(vc, animated: true, completion: {
                vc.useTouchId()
            })
        }
    }

    // 解析一个月的数据生成数据源
    func loadMonthData(_ month: String) {
        guard !month.isEmpty else {
            return
        }
        self.title = month
        
        DataCache.share.loadMonth(monthString: month, result: { (items) in
            self.dataSource.removeAll()
            items.forEach { item in
                self.dataSource.append(item)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
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
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ContentShowViewController(withItem:dataSource[indexPath.row])
        self.tabBarController?.present(vc, animated: true, completion: nil)
    }
}
