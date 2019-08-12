//
//  WebDAVViewController.swift
//  Imagination
//
//  Created by Miaoqi Wang on 2019/4/27.
//  Copyright © 2019 Star. All rights reserved.
//

import UIKit

private let reusableIdentifier = "WebDAVCell"

class WebDAVViewController: UIViewController {

    let table = UITableView(frame: .zero, style: .grouped)
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
                    if self.path != nil {
                        self.title = self.items.first?.displayname
                    }
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
            loadData()
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
        table.separatorStyle = .singleLine
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
            if item.href == WebDavSyncMananger.shared.syncDirHref {
                cell.accessoryType = .detailDisclosureButton
            } else {
                cell.accessoryType = .detailButton
            }
        } else {
            cell.accessoryType = .none
        }
        cell.textLabel?.text = item.displayname
        return cell
    }
}

extension WebDAVViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = items[indexPath.row + 1]
        if item.isDirectory {
            self.navigationController?.pushViewController(WebDAVViewController(path: item.href), animated: true)
        } else {
            openURL(url: URL(string: item.href)!)
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let item = items[indexPath.row + 1]
        let alert = UIAlertController(title: "提示", message: "即将删除\(item.displayname), 确定？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "删除", style: .destructive, handler: { (_) in
            WebDAV.shared.delete(path: item.href) { (error) in
                if error == nil {
                    DispatchQueue.main.async {
                        self.items.remove(at: indexPath.row + 1)
                        self.table.reloadData()
                    }
                }
            }

        }))
        self.present(alert, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let item = items[indexPath.row + 1]
        if WebDavSyncMananger.shared.syncDirHref == item.href {
            let alert = UIAlertController(title: nil, message: "该目录已设为同步目录，可设置其他目录修改", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好", style: .default, handler: { (_) in
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: nil, message: "是否将该目录设为同步目录", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "否", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "是", style: .default, handler: { (_) in
                WebDavSyncMananger.shared.syncDirHref = item.href
                self.table.reloadData()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension WebDAVViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}

extension WebDAVViewController {
    func openURL(url: URL) {
        let tmp = FileManager.tempsPath() + url.lastPathComponent
        let tmpURL = URL(fileURLWithPath: tmp)
        if FileManager.default.fileExists(atPath: tmp) {
            DispatchQueue.main.async {
                let vc = UIDocumentInteractionController(url: tmpURL)
                vc.delegate = self
                vc.presentPreview(animated: true)
            }
        } else {
            let activity = UIActivityIndicatorView(style: .gray)
            activity.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            activity.center = view.center
            view.addSubview(activity)
            activity.startAnimating()
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            URLSession.shared.downloadTask(with: request) { (fileURL, response, error) in
                DispatchQueue.main.async {
                    activity.stopAnimating()
                    activity.removeFromSuperview()
                }
                if let file = fileURL {
                    do {
                        try FileManager.default.copyItem(at: file, to: tmpURL)
                        DispatchQueue.main.async {
                            let vc = UIDocumentInteractionController(url: tmpURL)
                            vc.delegate = self
                            vc.presentPreview(animated: true)
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }
}
