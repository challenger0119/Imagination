//
//  ImageViewController.swift
//  Imagination
//
//  Created by Star on 2017/4/27.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    init(withImage image:UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var image:UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        let iview = UIImageView.init(frame: CGRect(x:0,y:0,width:self.view.frame.width,height:self.view.frame.height))
        iview.image = image
        self.view.addSubview(iview)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeVC))
        
    }
    func closeVC(){
        self.dismiss(animated: true, completion: {
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
