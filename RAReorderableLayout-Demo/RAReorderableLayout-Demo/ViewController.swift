//
//  ViewController.swift
//  RAReorderableLayout-Demo
//
//  Created by Ryo Aoyama on 10/29/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

import UIKit

class ViewController: UIViewController, RAReorderableLayoutDelegate ,RAReorderableLayoutDataSource {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "collectionViewCell", bundle: nil);
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "cell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        for index in 0..<30 {
            let name = "Sample\(index).jpg"
            let image = UIImage(named: name)
            self.images.append(image!)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = CGRectGetWidth(UIScreen.mainScreen().bounds)
        let threePiecesWidth = screenWidth / 3.0
        let twoPiecesWidth = screenWidth / 2.0
        let fiveItems = indexPath.item % 5
        if fiveItems == 0 || fiveItems == 1 {
            return CGSizeMake(twoPiecesWidth, twoPiecesWidth)
        }else {
            return CGSizeMake(threePiecesWidth, threePiecesWidth)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("cellID", forIndexPath: indexPath) as RACollectionViewCell
        cell.numLabel.text = toString(indexPath.item + 1)
        cell.imageView.image = self.images[indexPath.item]
        return cell
    }
}

class RACollectionViewCell: UICollectionViewCell {
    var numLabel: UILabel!
    var imageView: UIImageView!
    var gradientLayer: CAGradientLayer?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.bounds
        self.numLabel.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 20.0, CGRectGetWidth(self.bounds), 20.0)
        self.applyGradation(self.numLabel)
    }
    
    private func configure() {
        self.imageView = UIImageView()
        self.imageView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.addSubview(self.imageView)
        
        self.numLabel = UILabel()
        self.numLabel.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.numLabel.textAlignment = .Center
        self.numLabel.font = UIFont.boldSystemFontOfSize(20.0)
        self.numLabel.textColor = UIColor.whiteColor()
        self.addSubview(self.numLabel)
    }
    
    private func applyGradation(gradientView: UIView!) {
        self.gradientLayer?.removeFromSuperlayer()
        self.gradientLayer = nil
        
        self.gradientLayer = CAGradientLayer()
        self.gradientLayer!.frame = gradientView.frame
        
        let mainColor = UIColor(white: 0, alpha: 0.7).CGColor
        let subColor = UIColor.clearColor().CGColor
        self.gradientLayer!.colors = [subColor, mainColor]
        self.gradientLayer!.locations = [0, 1]
        
        self.layer.insertSublayer(self.gradientLayer, below: gradientView.layer)
    }
}

