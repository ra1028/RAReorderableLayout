//
//  ViewController.swift
//  RAReorderableLayout-Demo
//
//  Created by Ryo Aoyama on 10/29/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var verticalButton: RAButton!
    
    @IBOutlet weak var horizontalButton: RAButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "RAReorderableLayout"
        verticalButton.exclusiveTouch = true
        horizontalButton.exclusiveTouch = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let num1: CGFloat = CGFloat(arc4random_uniform(256)) / 255.0
        let num2: CGFloat = CGFloat(arc4random_uniform(256)) / 255.0
        let num3: CGFloat = CGFloat(arc4random_uniform(256)) / 255.0
        let color1: UIColor = UIColor(red: num1, green: num2, blue: num3, alpha: 1.0)
        let color2: UIColor = UIColor(red: num3, green: num2, blue: num1, alpha: 1.0)
        
        if (num1 + num2 + num3) / 3.0 >= 0.5 {
            verticalButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            horizontalButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        }else {
            verticalButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            horizontalButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        }
        
        verticalButton.backgroundColor = color1
        horizontalButton.backgroundColor = color2
    }
}

class RAButton: UIButton {
    var baseView: UIView!
    
    override var highlighted: Bool {
        didSet {
            let transform: CGAffineTransform = highlighted ?
                CGAffineTransformMakeScale(1.1, 1.1) : CGAffineTransformIdentity
            UIView.animateWithDuration(
                0.05,
                delay: 0,
                options: .BeginFromCurrentState,
                animations: {
                    self.transform = transform
                },
                completion: nil
            )
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = CGRectGetWidth(bounds) / 2;
    }
    
    private func configure() {
        baseView = UIView(frame: bounds)
        layer.cornerRadius = CGRectGetWidth(bounds)
        baseView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
    }
}