//
//  WebDAVViewController.swift
//  Imagination
//
//  Created by Miaoqi Wang on 2019/4/27.
//  Copyright © 2019 Star. All rights reserved.
//

import UIKit

private let reusableIdentifier = "WebDAVCell"

class WebDAVViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let table = UITableView()
    let path: String?
    var items = [WebDAVItem]()

    init(path: String? = nil) {
        self.path = path
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(table)
        table.frame = view.bounds
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.sectionHeaderHeight = 50
        table.register(UITableViewCell.self, forCellReuseIdentifier: reusableIdentifier)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }

    func loadData() {
        if let config  = WebDAVConfig.recent() {
            WebDAV(config: config).loadPath(path) { (items) in
                DispatchQueue.main.async {
                    self.items = items
                    self.table.reloadData()
                }
            }
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "WebDAVLoginViewController")
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: nil)
        }
    }
}

extension WebDAVViewController {
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

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.sectionHeaderHeight))
        backView.backgroundColor = .lightGray
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: tableView.bounds.size.width - 10, height: tableView.sectionHeaderHeight))
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .darkGray
        label.text = items.first?.displayname
        backView.addSubview(label)
        return backView
    }
}
extension WebDAVViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row + 1]
        if item.isDirectory {
            self.navigationController?.pushViewController(WebDAVViewController(path: item.href), animated: true)

        }
    }
}
