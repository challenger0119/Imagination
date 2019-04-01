//
//  WebViewController.swift
//  Imagination
//
//  Created by Miaoqi Wang on 2019/4/1.
//  Copyright © 2019 Star. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var webView:WKWebView!
    var urlStr:String?
    init(withURLString urlString:String) {
        urlStr = urlString
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: view.bounds)
        view.addSubview(webView)
        if let ustr = urlStr {
           webView.load(URLRequest(url: URL(string: ustr)!))
        }
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
