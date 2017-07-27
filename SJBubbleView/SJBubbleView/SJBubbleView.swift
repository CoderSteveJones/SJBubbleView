//
//  SJBubbleView.swift
//  SJBubbleView
//
//  Created by 江奔 on 2017/7/27.
//  Copyright © 2017年 TCGroup. All rights reserved.
//

import UIKit

class SJBubbleView: UIView {

    var begin_Point = CGPoint() /** 中心点 */
    var super_View: UIView? /** 父视图 */
    var bubble_Width = 0.0 /** 视图宽度 */
    var r1_View: UIView? /** 底部圆 */
    var r2_View: UIView? /** 手拖圆 */
    var r1 = 0.0 /** 底部圆半径 */
    var r2 = 0.0 /** 手拖圆半径 */
    
    var x1 = 0.0 /** 底部圆center.x */
    var y1 = 0.0 /** 底部圆center.y */
    var x2 = 0.0 /** 手拖圆center.x */
    var y2 = 0.0 /** 手拖圆center.y */
    
    var d_r1_r2 = 0.0 /** 圆心距离 */
    
    var cosθ = 0.0 /** 计算Bezier时需用 */
    var sinθ = 0.0
    
    var r1_View_Frame = CGRect() /** 记录r1_View 的大小和中心 */
    var r1_View_Center = CGPoint()
    
    var a_point = CGPoint() /** 图中对应点 */
    var b_point = CGPoint()
    var c_point = CGPoint()
    var d_point = CGPoint()
    var o_point = CGPoint()
    var p_point = CGPoint()
    
    var shapeLayer: CAShapeLayer?
    var bezierPath: UIBezierPath?
    
    
    var viscosity: Double = 0.0 { /** 气泡粘性系数，越大可以拉得越长 */
        
        didSet {
            r1 = Double((r1_View?.bounds.size.width)! / 2) - d_r1_r2 / viscosity
            r1_View?.center = r1_View_Center
            r1_View?.bounds = CGRect(x: 0, y: 0, width: r1 * 2, height: r1 * 2)
            r1_View?.layer.cornerRadius = CGFloat(r1)
        }
    }
    
    
    init(beginPoint: CGPoint,bubbleWidth: Double,superView: UIView) {
        self.begin_Point = beginPoint
        self.super_View = superView
        self.bubble_Width = bubbleWidth
        super.init(frame: CGRect(x: Double(beginPoint.x), y: Double(beginPoint.y), width: bubbleWidth, height: bubbleWidth))
        setupConfig()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    private func setupConfig() {
        
        
        /** 手拖圆 */
        r2_View = UIView(frame: CGRect(x: 0, y: 0, width: bubble_Width, height: bubble_Width))
        r2 = Double((r2_View?.bounds.size.width)! / 2);
        r2_View?.layer.cornerRadius = CGFloat(r2)
        r2_View?.layer.masksToBounds = true
        
        
        /** 底部圆 */
        r1_View = UIView(frame: (r2_View?.frame)!)
        r1 = Double((r1_View?.bounds.size.width)! / 2);
        r1_View?.layer.cornerRadius = CGFloat(r1)
        r1_View?.layer.masksToBounds = true
        
        /** 添加到父视图 */
        super_View?.addSubview(r1_View!)
        super_View?.addSubview(r2_View!)
        
        /** 记录r1_View的位置和中心点 */
        r1_View_Frame = (r1_View?.frame)!
        r1_View_Center = (r1_View?.center)!
        
        /** 为手拖圆添加手势 */
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleDragGesture))
        r2_View?.addGestureRecognizer(pan)
    }
    
    private func draw() {
        
        x1 = Double((r1_View?.center.x)!);
        y1 = Double((r1_View?.center.y)!);
        x2 = Double((r2_View?.center.x)!);
        y2 = Double((r2_View?.center.y)!);
        
        /** 圆心距 */
        let l1 = (x2 - x1) * (x2 - x1)
        let l2 = (x2 - x1) * (x2 - x1)
        d_r1_r2 = sqrt(l1 + l2)
        
        /** cosθ 和 sinθ计算 */
        if d_r1_r2 == 0 {
            cosθ = 1
            sinθ = 0
        }else {
            cosθ = (y2 - y1) / d_r1_r2
            sinθ = (x2 - x1) / d_r1_r2
        }
        
        /** a b c d o p 各点 */
        a_point = CGPoint(x: x1-r1*cosθ, y: y1+r1*sinθ)
        b_point = CGPoint(x: x1+r1*cosθ, y: y1-r1*sinθ)
        c_point = CGPoint(x: x2+r2*cosθ, y: y2-r2*sinθ)
        d_point = CGPoint(x: x2-r2*cosθ, y: y2+r2*sinθ)
        o_point = CGPoint(x: Double(a_point.x) + (d_r1_r2 / 2)*sinθ, y: Double(a_point.y) + (d_r1_r2 / 2)*cosθ)
        p_point = CGPoint(x: Double(b_point.x) + (d_r1_r2 / 2)*sinθ, y: Double(b_point.y) + (d_r1_r2 / 2)*cosθ)
        
        
        bezierPath = UIBezierPath()
        bezierPath?.move(to: a_point)
        bezierPath?.addQuadCurve(to: d_point, controlPoint: o_point)
        bezierPath?.addLine(to: c_point)
        bezierPath?.addQuadCurve(to: b_point, controlPoint: p_point)
        bezierPath?.addLine(to: a_point)
        
        shapeLayer?.path = bezierPath?.cgPath
        shapeLayer?.fillColor = UIColor.red.cgColor
        
        super_View?.layer.insertSublayer(shapeLayer!, below: r2_View?.layer)
    }
    
    @objc private func handleDragGesture(ges: UIPanGestureRecognizer) {
        
        let dragPoint = ges.location(in: super_View)
        
            r1_View?.isHidden = false
        
        if ges.state == .began {
            
            r2_View?.center = dragPoint
            draw()
            
        }else if ges.state == .changed {
            
            r1_View?.isHidden = true
            shapeLayer?.removeFromSuperlayer()
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: { 
                
                self.r2_View?.center = self.r1_View_Center
            }, completion: { (fin) in
                if fin {
                    
                }
            })
            
            
        }else if ges.state == .ended || ges.state == .cancelled || ges.state == .failed {
            
        }
       
    }
    
    
    
}
