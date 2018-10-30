//
//  IndicatorMapView.swift
//  Imagination
//
//  Created by Star on 2017/4/24.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit
class IndicatorMapViewBack: UIView {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    var mapHeight:CGFloat = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.mapHeight = self.frame.height - (self.frame.width-10)/2/4
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        if let ref = UIGraphicsGetCurrentContext() {
            ref.saveGState()
            let arrowHeight = (self.frame.width-10)/2/4
            let corner:CGFloat = 10.0
            let bezierPath = UIBezierPath()
            bezierPath.lineWidth = 1
            bezierPath.lineCapStyle = .round
            bezierPath.lineJoinStyle = .round
            bezierPath.move(to: CGPoint(x: 0, y: corner))
            bezierPath.addQuadCurve(to: CGPoint(x: corner, y: 0), controlPoint: CGPoint(x: 0, y: 0))
            
            bezierPath.addLine(to: CGPoint(x: self.frame.width-corner, y: 0))
            bezierPath.addQuadCurve(to: CGPoint(x: self.frame.width, y: 5), controlPoint: CGPoint(x: self.frame.width, y: 0))
            
            bezierPath.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height-arrowHeight-corner))
            bezierPath.addQuadCurve(to: CGPoint(x: self.frame.width-corner, y: self.frame.height-arrowHeight), controlPoint: CGPoint(x: self.frame.width, y: self.frame.height-arrowHeight))
            bezierPath.addQuadCurve(to: CGPoint(x: self.frame.width/2, y: self.frame.height), controlPoint: CGPoint(x: self.frame.width/2, y: self.frame.height-arrowHeight))
            bezierPath.addQuadCurve(to: CGPoint(x: 5, y: self.frame.height-arrowHeight), controlPoint: CGPoint(x: self.frame.width/2, y: self.frame.height-arrowHeight))
            bezierPath.addQuadCurve(to: CGPoint(x: 0, y: self.frame.height-arrowHeight-corner), controlPoint: CGPoint(x: 0, y: self.frame.height-arrowHeight))
            bezierPath.close()
            UIColor.lightGray.setStroke()
            bezierPath.stroke()
            ref.restoreGState()
        }
    }
}
