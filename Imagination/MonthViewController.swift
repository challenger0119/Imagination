//
//  MonthViewController.swift
//  Imagination
//
//  Created by Star on 2017/1/4.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit

class MonthViewController: UITableViewController {
    var monthList:[String]?
    override func viewDidLoad() {
        super.viewDidLoad()
        DataCache.shareInstance.loadLastMonth()
        if let cata = DataCache.shareInstance.catalogue_month {
            
            self.monthList = cata;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.monthList == nil {
            return 0
        }else{
            return self.monthList!.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "MonthViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = self.monthList![indexPath.row]
        return cell
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        /*
        guard let destination = segue.destination as? UITabBarController else{
            return
        }
        let nav = destination.viewControllers?.first as! UINavigationController
        let main = nav.topViewController as! MainTableViewController
        let cell = sender as! UITableViewCell
        DataCache.shareInstance.loadLastMonthToMonth(cell.textLabel!.text!)
        main.today.title = cell.textLabel!.text!
 */
    }


}
