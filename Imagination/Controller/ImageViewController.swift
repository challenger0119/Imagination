//
//  ImageViewController.swift
//  Imagination
//
//  Created by Star on 2017/4/27.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController,UIScrollViewDelegate {
    
    let iview = UIImageView()
    let backScrolView = UIScrollView()
    
    
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
        self.view.backgroundColor = UIColor.white
        
        backScrolView.delegate = self
        backScrolView.minimumZoomScale = 1.0
        backScrolView.maximumZoomScale = image.size.width/self.view.frame.width > image.size.height/self.view.frame.height ? image.size.height/self.view.frame.height : image.size.width/self.view.frame.width
        backScrolView.frame = self.view.bounds;
        
        self.view.addSubview(backScrolView);
        
        let imagewidth = self.view.bounds.width - 20
        let imageheight = self.view.bounds.height - 20 - self.navigationController!.navigationBar.frame.height - UIApplication.shared.statusBarFrame.height
        iview.frame = CGRect(x: 10, y: 10, width: imagewidth, height: imageheight)
        iview.contentMode = .scaleAspectFit // 这个要在 setImage 前面
        iview.image = image
        backScrolView.addSubview(iview)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeVC))
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        tap.numberOfTapsRequired = 2
        self.backScrolView.addGestureRecognizer(tap)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.iview
    }
    
    @objc func doubleTap(sender:UITapGestureRecognizer){
        if sender.state == .ended {
            if self.backScrolView.zoomScale == 1 {
                self.backScrolView.zoom(to: rectFor(scale: 3.0, center: sender.location(in: sender.view)), animated: true)
            }else{
                self.backScrolView.setZoomScale(1.0, animated: true)
            }
        }
    }

    func rectFor(scale:CGFloat,center:CGPoint)->CGRect{
        var zoomRect = CGRect();
        let frame = self.backScrolView.frame;
        zoomRect.size.height = frame.size.height / scale;
        zoomRect.size.width  = frame.size.width / scale;
        zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
        return zoomRect;
    }
    @objc func closeVC(){
        self.dismiss(animated: true, completion: {
            
        })
    }

}
