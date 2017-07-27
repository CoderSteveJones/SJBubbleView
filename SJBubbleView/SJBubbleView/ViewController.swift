//
//  ViewController.swift
//  SJBubbleView
//
//  Created by 江奔 on 2017/7/27.
//  Copyright © 2017年 TCGroup. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let bubbleView = SJBubbleView(beginPoint: CGPoint(x: 100,y: 100), bubbleWidth: 50, superView: self.view)
        bubbleView.backgroundColor = UIColor.red
        view.addSubview(bubbleView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

