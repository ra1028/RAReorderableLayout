//
//  RAReorderableLayout.swift
//  RAReorderableLayout
//
//  Created by Ryo Aoyama on 10/12/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

import UIKit

@objc protocol RAReorderableLayoutDelegate: UICollectionViewDelegateFlowLayout {
    
}

@objc protocol RAReorderableLayoutDataSource: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
}

class RAReorderableLayout: UICollectionViewFlowLayout, UIGestureRecognizerDelegate {
    
    var delegate: RAReorderableLayoutDelegate! {
        set {
            self.collectionView?.delegate = delegate
        }
        get {
            return self.collectionView?.delegate as RAReorderableLayoutDelegate
        }
    }
    
    var datasource: RAReorderableLayoutDataSource! {
        set {
            self.collectionView?.delegate = delegate
        }
        get {
            return self.collectionView?.dataSource as RAReorderableLayoutDataSource
        }
    }
    
    private var longPress: UILongPressGestureRecognizer?
    
    private var panGesture: UIPanGestureRecognizer?
    
    private var cellFakeView: RACellFakeView?
    
    private var panTranslation: CGPoint?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureObserver()
    }
    
    override init() {
        super.init()
        self.configureObserver()
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "collectionView")
    }
    
    override func prepareLayout() {
        super.prepareLayout()
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        let attribute: UICollectionViewLayoutAttributes = super.layoutAttributesForItemAtIndexPath(indexPath)
        if attribute.representedElementCategory == .Cell {
            if attribute.indexPath.isEqual(self.cellFakeView?.indexPath) {
                attribute.alpha = 0
            }
        }
        return attribute
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var attributesArray = super.layoutAttributesForElementsInRect(rect)
        if attributesArray != nil {
            for attribute in attributesArray! {
                var attri = attribute as UICollectionViewLayoutAttributes
                if attri.representedElementCategory == .Cell {
                    if attri.indexPath.isEqual(self.cellFakeView?.indexPath) {
                        attri.alpha = 0
                    }
                }
            }
        }
        return attributesArray
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "collectionView" {
            self.setUpGestureRecognizers()
        }else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    private func configureObserver() {
        self.addObserver(self, forKeyPath: "collectionView", options:.allZeros, context: nil)
    }
    
    private func setUpDisplayLink() {
        
    }
    
    private func invalidateDisplayLink() {
        
    }
    
    // gesture recognizers
    private func setUpGestureRecognizers() {
        if self.collectionView != nil {
            self.longPress = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
            self.panGesture = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
            self.longPress?.delegate = self
            self.panGesture?.delegate = self
            let gestures: NSArray! = self.collectionView?.gestureRecognizers
            gestures.enumerateObjectsUsingBlock { (gestureRecognizer, index, finish) -> Void in
                if gestureRecognizer is UILongPressGestureRecognizer {
                    gestureRecognizer.requireGestureRecognizerToFail(self.longPress!)
                }
            }
            self.collectionView?.addGestureRecognizer(self.longPress!)
            self.collectionView?.addGestureRecognizer(self.panGesture!)
        }
    }
    
    // long press gesture
    func handleLongPress(longPress: UILongPressGestureRecognizer!) {
        let location = longPress.locationInView(self.collectionView)
        var indexPath: NSIndexPath? = self.collectionView?.indexPathForItemAtPoint(location)
        if self.cellFakeView != nil {
            indexPath = self.cellFakeView?.indexPath
        }
        if  indexPath != nil {
            switch longPress.state {
            case .Began:
                //TODO: insert can move delegate
                
                self.collectionView?.scrollsToTop = false
                
                let currentCell: UICollectionViewCell? = self.collectionView?.cellForItemAtIndexPath(indexPath!)
                
                self.cellFakeView = RACellFakeView(cell: currentCell!)
                self.cellFakeView!.indexPath = indexPath
                self.cellFakeView!.originalCenter = currentCell?.center
                self.collectionView?.addSubview(self.cellFakeView!)
                
                self.invalidateLayout()
                
                self.cellFakeView!.pushFowardView()
                
                // TODO: insert did begin dragging delegate
            case .Cancelled:
                fallthrough
            case .Ended:
                // TODO: insert will end dragging delegate
                
                self.collectionView?.scrollsToTop = true
                
                self.invalidateDisplayLink()
                
                let attribute = self.layoutAttributesForItemAtIndexPath(self.cellFakeView!.indexPath!)
                self.cellFakeView!.pushBackView(cellFrame: attribute.frame, completion: { () -> Void in
                    self.cellFakeView!.removeFromSuperview()
                    self.cellFakeView = nil
                    self.invalidateLayout()
                })
            default:
                break
            }
        }
    }
    
    // pan gesture
    func handlePanGesture(pan: UIPanGestureRecognizer!) {
        if self.cellFakeView != nil {
            switch pan.state {
            case .Changed:
                self.panTranslation = pan.translationInView(self.collectionView!)
                self.cellFakeView!.center.x = self.cellFakeView!.originalCenter!.x + panTranslation!.x
                self.cellFakeView!.center.y = self.cellFakeView!.originalCenter!.y + panTranslation!.y
                
                self.moveItemIfNeeded()
            case .Cancelled:
                fallthrough
            case .Ended:
                self.invalidateDisplayLink()
            default:
                break
            }
        }
    }
    
    // move item
    private func moveItemIfNeeded() {
        let atIndexPath = self.cellFakeView!.indexPath
        let toIndexPath = self.collectionView!.indexPathForItemAtPoint(self.cellFakeView!.center)
        
        if atIndexPath == nil {
            return
        }else if atIndexPath!.isEqual(toIndexPath) {
            return
        }
        
        //TODO: insert can move to indexPath delegate
        
        //TODO: insert will move delegate
        
        let attribute = self.layoutAttributesForItemAtIndexPath(toIndexPath!)
        self.collectionView!.performBatchUpdates({ () -> Void in
            self.cellFakeView!.indexPath = toIndexPath
            self.cellFakeView?.changeBoundsIfNeeded(attribute.bounds)
            self.collectionView!.moveItemAtIndexPath(atIndexPath!, toIndexPath: toIndexPath!)
            
            //TODO: insert did move delegate
        }, completion:nil)
    }
    
    // gesture recognize delegate
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isEqual(self.longPress) {
            if (self.collectionView!.panGestureRecognizer.state != .Possible && self.collectionView!.panGestureRecognizer.state != .Failed) {
                return false
            }
        }else if gestureRecognizer.isEqual(self.panGesture) {
            if (self.longPress!.state == .Possible || self.longPress!.state == .Failed) {
                return false
            }
        }
        
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isEqual(self.longPress) {
            if otherGestureRecognizer.isEqual(self.panGesture) {
                return true
            }
        }else if gestureRecognizer.isEqual(self.panGesture) {
            if otherGestureRecognizer.isEqual(self.longPress) {
                return true
            }else {
                return false
            }
        }else if gestureRecognizer.isEqual(self.collectionView?.panGestureRecognizer) {
            if (self.longPress!.state != .Possible || self.longPress!.state != .Failed) {
                return false
            }
        }
        
        return true
    }
}

private class RACellFakeView: UIView {
    
    weak var cell: UICollectionViewCell?
    
    var cellFakeImageView: UIImageView?
    
    var cellFakeHightedView: UIImageView?
    
    private var indexPath: NSIndexPath?
    
    private var originalCenter: CGPoint?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(cell: UICollectionViewCell) {
        super.init(frame: cell.frame)
        
        self.cell = cell
        
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSizeMake(0, 0)
        self.layer.shadowOpacity = 0
        self.layer.shadowRadius = 3.0
        self.layer.shouldRasterize = false
        
        self.cellFakeImageView = UIImageView(frame: self.bounds)
        self.cellFakeImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        self.cellFakeImageView?.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        self.cellFakeHightedView = UIImageView(frame: self.bounds)
        self.cellFakeHightedView?.contentMode = UIViewContentMode.ScaleAspectFill
        self.cellFakeHightedView?.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        cell.highlighted = true
        self.cellFakeHightedView?.image = getCellImage()
        cell.highlighted = false
        self.cellFakeImageView?.image = getCellImage()
        
        self.addSubview(self.cellFakeImageView!)
        self.addSubview(self.cellFakeHightedView!)
    }
    
    func changeBoundsIfNeeded(bounds: CGRect) {
        if CGRectEqualToRect(self.bounds, bounds) {
            return
        }
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut | .BeginFromCurrentState, animations: { () -> Void in
            self.bounds = bounds
        }, completion: nil)
    }
    
    func pushFowardView() {
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut | .BeginFromCurrentState, animations: {
            self.center = self.originalCenter!
            self.transform = CGAffineTransformMakeScale(1.1, 1.1)
            var shadowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
            shadowAnimation.fromValue = 0
            shadowAnimation.toValue = 0.5
            shadowAnimation.removedOnCompletion = false
            shadowAnimation.fillMode = kCAFillModeForwards
            self.layer.addAnimation(shadowAnimation, forKey: "applyShadow")
            }, completion: { (finished) -> Void in
                self.cellFakeHightedView!.removeFromSuperview()
        })
    }
    
    func pushBackView(cellFrame frame: CGRect!, completion: (()->Void)?) {
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut | .BeginFromCurrentState, animations: {
            self.transform = CGAffineTransformIdentity
            self.frame = frame
            var shadowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
            shadowAnimation.fromValue = 0.5
            shadowAnimation.toValue = 0
            shadowAnimation.removedOnCompletion = false
            shadowAnimation.fillMode = kCAFillModeForwards
            self.layer.addAnimation(shadowAnimation, forKey: "removeShadow")
            }, completion: { (finished) -> Void in
                if completion != nil {
                    completion!()
                }
        })
    }
    
    private func getCellImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.cell!.bounds.size, true, UIScreen.mainScreen().scale * 5)
        self.cell!.drawViewHierarchyInRect(self.cell!.bounds, afterScreenUpdates: true)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}