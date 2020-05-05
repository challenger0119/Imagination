//
//  AboutViewController.swift
//  Imagination
//
//  Created by YouJuny on 2020/5/5.
//  Copyright © 2020 Star. All rights reserved.
//

import UIKit

class AboutViewController: UITableViewController {

    @IBOutlet var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        versionLabel.text = "版本: \(version ?? "")"
    }
}

extension AboutViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                let webVC = WebViewController(withURLString: "https://wuzhi.me")
                navigationController?.pushViewController(webVC, animated: true)
            case 1:
                let webVC = WebViewController(withURLString: "https://hitokoto.cn")
                navigationController?.pushViewController(webVC, animated: true)
            default:
                break
            }
        }
    }
}
