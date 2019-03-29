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
        verticalButton.isExclusiveTouch = true
        horizontalButton.isExclusiveTouch = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let num1: CGFloat = CGFloat(arc4random_uniform(256)) / 255.0
        let num2: CGFloat = CGFloat(arc4random_uniform(256)) / 255.0
        let num3: CGFloat = CGFloat(arc4random_uniform(256)) / 255.0
        let color1: UIColor = UIColor(red: num1, green: num2, blue: num3, alpha: 1.0)
        let color2: UIColor = UIColor(red: num3, green: num2, blue: num1, alpha: 1.0)
        
        if (num1 + num2 + num3) / 3.0 >= 0.5 {
            verticalButton.setTitleColor(UIColor.black, for: UIControl.State())
            horizontalButton.setTitleColor(UIColor.black, for: UIControl.State())
        }else {
            verticalButton.setTitleColor(UIColor.white, for: UIControl.State())
            horizontalButton.setTitleColor(UIColor.white, for: UIControl.State())
        }
        
        verticalButton.backgroundColor = color1
        horizontalButton.backgroundColor = color2
    }
}

class RAButton: UIButton {
    var baseView: UIView!
    
    override var isHighlighted: Bool {
        didSet {
            let transform: CGAffineTransform = isHighlighted ?
                CGAffineTransform(scaleX: 1.1, y: 1.1) : CGAffineTransform.identity
            UIView.animate(
                withDuration: 0.05,
                delay: 0,
                options: .beginFromCurrentState,
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
        layer.cornerRadius = bounds.width / 2;
    }
    
    private func configure() {
        baseView = UIView(frame: bounds)
        layer.cornerRadius = bounds.width
        baseView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
    }
}
