//
//  CatalogueViewController.swift
//  Imagination
//
//  Created by Star on 2017/4/11.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit
protocol CatalogueViewControllerDelegate {
    func catalogueDidSelectItem(item:String)
    func catalogueDidClose()
}
let reusableCellIdentifier = "CatalogueViewControllerCell"

class CatalogueViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    static let tableWidth:CGFloat = 120
    var siderTable: UITableView!
    var content:[String]?
    var delegate:CatalogueViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        var tframe = self.view.frame
        tframe.size.width = CatalogueViewController.tableWidth
        tframe.origin.x = -CatalogueViewController.tableWidth
        self.siderTable = UITableView(frame: tframe, style: .plain)
        self.siderTable.dataSource = self
        self.siderTable.delegate = self
        self.siderTable.backgroundColor = UIColor.lightGray
        self.siderTable.separatorStyle = .none
        
        self.view.addSubview(siderTable)
        tframe.origin.x = CatalogueViewController.tableWidth
        tframe.size.width = self.view.frame.width-CatalogueViewController.tableWidth
        
        let tapview = UIView(frame: tframe)
        tapview.backgroundColor = UIColor.clear
        self.view.addSubview(tapview)
        tapview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cataCancel)));
        
        tframe.size.height = 20
        self.siderTable.tableHeaderView = UIView(frame: tframe)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var tframe = self.siderTable.frame
        tframe.origin.x = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.siderTable.frame = tframe
        }) { (boo) in
            if boo {
            }
        }
    }
    func dismissVC(){
        var tframe = self.siderTable.frame
        tframe.origin.x = -CatalogueViewController.tableWidth
        UIView.animate(withDuration: 0.2, animations: {
            self.siderTable.frame = tframe
        }) { (boo) in
            if boo {
                self.dismiss(animated: false, completion: {})
            }
        }
    }
    func cataCancel(){
        dismissVC()
        self.delegate?.catalogueDidClose()
    }
    
    //MARK: - UITableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.content != nil {
            return self.content!.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: reusableCellIdentifier) {
            cell.textLabel?.text = self.content![indexPath.row]
            return cell
        }else{
            let cell = UITableViewCell(style: .default, reuseIdentifier: reusableCellIdentifier)
            cell.textLabel?.text = self.content![indexPath.row]
            cell.backgroundColor = UIColor.clear
            cell.textLabel?.textColor = UIColor.white
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        dismissVC()
        self.delegate?.catalogueDidSelectItem(item: self.content![indexPath.row])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
