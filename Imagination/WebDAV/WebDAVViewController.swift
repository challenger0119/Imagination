//
//  WebDAVViewController.swift
//  Imagination
//
//  Created by Miaoqi Wang on 2019/4/27.
//  Copyright © 2019 Star. All rights reserved.
//

import UIKit
import QuickLook

private let reusableIdentifier = "WebDAVCell"

class WebDAVViewController: UIViewController {

    let table = UITableView()
    let path: String?
    var loginItem: UIBarButtonItem!
    var items = [WebDAVItem]()

    init(path: String? = nil) {
        self.path = path
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addLoginTip() {
        let loginTipLabel = UILabel(frame: view.bounds)
        loginTipLabel.text = "登陆一个支持WebDAV的网盘\n可以实现备份文件自动同步云端"
        loginTipLabel.numberOfLines = 0
        loginTipLabel.textColor = .darkGray
        loginTipLabel.textAlignment = .center
        loginTipLabel.font = UIFont.systemFont(ofSize: 15)
        view.addSubview(loginTipLabel)
    }

    func addLoginItem() {
        loginItem = UIBarButtonItem(title: "Login", style: .plain, target: self, action: #selector(login))
        self.navigationItem.rightBarButtonItem = loginItem
    }

    func loadData() {
        if let config  = WebDAVConfig.recent() {
            self.table.isHidden = false
            loginItem.title = "Logout"
            title = config.serverName
            WebDAV.shared.loadPath(path) { (items) in
                DispatchQueue.main.async {
                    self.items = items
                    self.table.reloadData()
                    self.title = self.items.first?.displayname
                }
            }
        } else {
            loginItem.title = "Login"
            presentLogin()
        }
    }

    func presentLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WebDAVLoginViewController") as! WebDAVLoginViewController
        vc.resultHandler = { (result) in
            switch result {
            case .login: self.loadData()
            case .cancel: break
            }
        }
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }

    @objc
    func login(_ sender: UIBarButtonItem) {
        if sender.title == "Login" {
            presentLogin()
        } else {
            WebDAVConfig.reset()
        }
    }
}

extension WebDAVViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addLoginTip()
        addLoginItem()

        view.addSubview(table)
        table.frame = view.bounds
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.register(UITableViewCell.self, forCellReuseIdentifier: reusableIdentifier)
        table.isHidden = true
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
}

extension WebDAVViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count - 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableIdentifier, for: indexPath)
        let item = items[indexPath.row + 1]
        if item.isDirectory {
            cell.accessoryType = .detailButton
        } else {
            cell.accessoryType = .none
        }
        cell.textLabel?.text = item.displayname
        return cell
    }
}

extension WebDAVViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row + 1]
        if item.isDirectory {
            self.navigationController?.pushViewController(WebDAVViewController(path: item.href), animated: true)
        } else {
            let vc = UIDocumentInteractionController(url: URL(fileURLWithPath: item.href))
            vc.delegate = self
            vc.presentPreview(animated: true)
        }
    }
}

extension WebDAVViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
