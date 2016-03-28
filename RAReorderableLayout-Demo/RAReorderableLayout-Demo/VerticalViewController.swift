//
//  VerticalViewController.swift
//  RAReorderableLayout-Demo
//
//  Created by Ryo Aoyama on 11/17/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

import UIKit

class VerticalViewController: UIViewController, RAReorderableLayoutDelegate, RAReorderableLayoutDataSource {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var imagesForSection0: [UIImage] = []
    var imagesForSection1: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "RAReorderableLayout"
        let nib = UINib(nibName: "verticalCell", bundle: nil)
        collectionView.registerNib(nib, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        for index in 0..<18 {
            let name = "Sample\(index).jpg"
            let image = UIImage(named: name)
            imagesForSection0.append(image!)
        }
        for index in 18..<30 {
            let name = "Sample\(index).jpg"
            let image = UIImage(named: name)
            imagesForSection1.append(image!)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.contentInset = UIEdgeInsetsMake(topLayoutGuide.length, 0, 0, 0)
    }
    
    // RAReorderableLayout delegate datasource
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = CGRectGetWidth(UIScreen.mainScreen().bounds)
        let threePiecesWidth = floor(screenWidth / 3.0 - ((2.0 / 3) * 2))
        let twoPiecesWidth = floor(screenWidth / 2.0 - (2.0 / 2))
        if indexPath.section == 0 {
            return CGSizeMake(threePiecesWidth, threePiecesWidth)
        }else {
            return CGSizeMake(twoPiecesWidth, twoPiecesWidth)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2.0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 2.0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return imagesForSection0.count
        }else {
            return imagesForSection1.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("verticalCell", forIndexPath: indexPath) as! RACollectionViewCell
        
        if indexPath.section == 0 {
            cell.imageView.image = imagesForSection0[indexPath.item]
        }else {
            cell.imageView.image = imagesForSection1[indexPath.item]
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, allowMoveAtIndexPath indexPath: NSIndexPath) -> Bool {
        if collectionView.numberOfItemsInSection(indexPath.section) <= 1 {
            return false
        }
        return true
    }
    
    func collectionView(collectionView: UICollectionView, atIndexPath: NSIndexPath, didMoveToIndexPath toIndexPath: NSIndexPath) {
        var photo: UIImage
        if atIndexPath.section == 0 {
            photo = imagesForSection0.removeAtIndex(atIndexPath.item)
        }else {
            photo = imagesForSection1.removeAtIndex(atIndexPath.item)
        }
        
        if toIndexPath.section == 0 {
            imagesForSection0.insert(photo, atIndex: toIndexPath.item)
        }else {
            imagesForSection1.insert(photo, atIndex: toIndexPath.item)
        }
    }
    
    func scrollTrigerEdgeInsetsInCollectionView(collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(100.0, 100.0, 100.0, 100.0)
    }
    
    func collectionView(collectionView: UICollectionView, reorderingItemAlphaInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else {
            return 0.3
        }
    }
    
    func scrollTrigerPaddingInCollectionView(collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(collectionView.contentInset.top, 0, collectionView.contentInset.bottom, 0)
    }
}

class RACollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var gradientLayer: CAGradientLayer?
    var hilightedCover: UIView!
    override var highlighted: Bool {
        didSet {
            hilightedCover.hidden = !highlighted
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        hilightedCover.frame = bounds
        applyGradation(imageView)
    }
    
    private func configure() {
        imageView = UIImageView()
        imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        addSubview(imageView)
        
        hilightedCover = UIView()
        hilightedCover.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        hilightedCover.backgroundColor = UIColor(white: 0, alpha: 0.5)
        hilightedCover.hidden = true
        addSubview(hilightedCover)
    }
    
    private func applyGradation(gradientView: UIView!) {
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
        
        gradientLayer = CAGradientLayer()
        gradientLayer!.frame = gradientView.bounds
        
        let mainColor = UIColor(white: 0, alpha: 0.3).CGColor
        let subColor = UIColor.clearColor().CGColor
        gradientLayer!.colors = [subColor, mainColor]
        gradientLayer!.locations = [0, 1]
        
        gradientView.layer.addSublayer(gradientLayer!)
    }
}