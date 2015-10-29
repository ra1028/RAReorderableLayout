//
//  RAReorderableLayout.swift
//  RAReorderableLayout
//
//  Created by Ryo Aoyama on 10/12/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

import UIKit

@objc public protocol RAReorderableLayoutDelegate: UICollectionViewDelegateFlowLayout {
        optional func collectionView(collectionView: UICollectionView, atIndexPath: NSIndexPath, willMoveToIndexPath toIndexPath: NSIndexPath)
        optional func collectionView(collectionView: UICollectionView, atIndexPath: NSIndexPath, didMoveToIndexPath toIndexPath: NSIndexPath)
        
        optional func collectionView(collectionView: UICollectionView, allowMoveAtIndexPath indexPath: NSIndexPath) -> Bool
        optional func collectionView(collectionView: UICollectionView, atIndexPath: NSIndexPath, canMoveToIndexPath: NSIndexPath) -> Bool
        
        optional func collectionView(collectionView: UICollectionView, collectionViewLayout layout: RAReorderableLayout, willBeginDraggingItemAtIndexPath indexPath: NSIndexPath)
        optional func collectionView(collectionView: UICollectionView, collectionViewLayout layout: RAReorderableLayout, didBeginDraggingItemAtIndexPath indexPath: NSIndexPath)
        optional func collectionView(collectionView: UICollectionView, collectionViewLayout layout: RAReorderableLayout, willEndDraggingItemToIndexPath indexPath: NSIndexPath)
        optional func collectionView(collectionView: UICollectionView, collectionViewLayout layout: RAReorderableLayout, didEndDraggingItemToIndexPath indexPath: NSIndexPath)
}

@objc public protocol RAReorderableLayoutDataSource: UICollectionViewDataSource {
        func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
        func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
        
        optional func collectionView(collectionView: UICollectionView, reorderingItemAlphaInSection section: Int) -> CGFloat
        optional func scrollTrigerEdgeInsetsInCollectionView(collectionView: UICollectionView) -> UIEdgeInsets
        optional func scrollTrigerPaddingInCollectionView(collectionView: UICollectionView) -> UIEdgeInsets
        optional func scrollSpeedValueInCollectionView(collectionView: UICollectionView) -> CGFloat
}

public class RAReorderableLayout: UICollectionViewFlowLayout, UIGestureRecognizerDelegate {
        
        private enum direction {
                case toTop
                case toEnd
                case stay
                
                private func scrollValue(speedValue speedValue: CGFloat, percentage: CGFloat) -> CGFloat {
                        var value: CGFloat = 0.0
                        switch self {
                        case toTop:
                                value = -speedValue
                        case toEnd:
                                value = speedValue
                        case .stay:
                                return 0
                        }
                        
                        let proofedPercentage: CGFloat = max(min(1.0, percentage), 0)
                        return value * proofedPercentage
                }
        }
        
        public weak var delegate: RAReorderableLayoutDelegate? {
                set {
                        self.collectionView?.delegate = delegate
                }
                get {
                        return self.collectionView?.delegate as? RAReorderableLayoutDelegate
                }
        }
        
        public weak var datasource: RAReorderableLayoutDataSource? {
                set {
                        self.collectionView?.delegate = delegate
                }
                get {
                        return self.collectionView?.dataSource as? RAReorderableLayoutDataSource
                }
        }
        
        private var displayLink: CADisplayLink?
        
        private var longPress: UILongPressGestureRecognizer?
        
        private var panGesture: UIPanGestureRecognizer?
        
        private var continuousScrollDirection: direction = .stay
        
        private var cellFakeView: RACellFakeView?
        
        private var panTranslation: CGPoint?
        
        private var fakeCellCenter: CGPoint?
        
        public var trigerInsets: UIEdgeInsets = UIEdgeInsetsMake(100.0, 100.0, 100.0, 100.0)
        
        public var trigerPadding: UIEdgeInsets = UIEdgeInsetsZero
        
        public var scrollSpeedValue: CGFloat = 10.0
        
        private var offsetFromTop: CGFloat {
                let contentOffset = self.collectionView!.contentOffset
                return self.scrollDirection == .Vertical ? contentOffset.y : contentOffset.x
        }
        
        private var insetsTop: CGFloat {
                let contentInsets = self.collectionView!.contentInset
                return self.scrollDirection == .Vertical ? contentInsets.top : contentInsets.left
        }
        
        private var insetsEnd: CGFloat {
                let contentInsets = self.collectionView!.contentInset
                return self.scrollDirection == .Vertical ? contentInsets.bottom : contentInsets.right
        }
        
        private var contentLength: CGFloat {
                let contentSize = self.collectionView!.contentSize
                return self.scrollDirection == .Vertical ? contentSize.height : contentSize.width
        }
        
        private var collectionViewLength: CGFloat {
                let collectionViewSize = self.collectionView!.bounds.size
                return self.scrollDirection == .Vertical ? collectionViewSize.height : collectionViewSize.width
        }
        
        private var fakeCellTopEdge: CGFloat? {
                if let fakeCell = self.cellFakeView {
                        return self.scrollDirection == .Vertical ? CGRectGetMinY(fakeCell.frame) : CGRectGetMinX(fakeCell.frame)
                }
                return nil
        }
        
        private var fakeCellEndEdge: CGFloat? {
                if let fakeCell = self.cellFakeView {
                        return self.scrollDirection == .Vertical ? CGRectGetMaxY(fakeCell.frame) : CGRectGetMaxX(fakeCell.frame)
                }
                return nil
        }
        
        private var trigerInsetTop: CGFloat {
                return self.scrollDirection == .Vertical ? self.trigerInsets.top : self.trigerInsets.left
        }
        
        private var trigerInsetEnd: CGFloat {
                return self.scrollDirection == .Vertical ? self.trigerInsets.top : self.trigerInsets.left
        }
        
        private var trigerPaddingTop: CGFloat {
                if self.scrollDirection == .Vertical {
                        return self.trigerPadding.top
                }else {
                        return self.trigerPadding.left
                }
        }
        
        private var trigerPaddingEnd: CGFloat {
                if self.scrollDirection == .Vertical {
                        return self.trigerPadding.bottom
                }else {
                        return self.trigerPadding.right
                }
        }
        
        required public init?(coder aDecoder: NSCoder) {
                super.init(coder: aDecoder)
                self.configureObserver()
        }
        
        public override init() {
                super.init()
                self.configureObserver()
        }
        
        deinit {
                self.removeObserver(self, forKeyPath: "collectionView")
        }
        
        override public func prepareLayout() {
                super.prepareLayout()
                
                // scroll triger insets
                if let insets = self.datasource?.scrollTrigerEdgeInsetsInCollectionView?(self.collectionView!) {
                        self.trigerInsets = insets
                }
                
                // scroll trier padding
                if let padding = self.datasource?.scrollTrigerPaddingInCollectionView?(self.collectionView!) {
                        self.trigerPadding = padding
                }
                
                // scroll speed value
                if let speed = self.datasource?.scrollSpeedValueInCollectionView?(self.collectionView!) {
                        self.scrollSpeedValue = speed
                }
        }
        
        override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
                let attributesArray = super.layoutAttributesForElementsInRect(rect)
                if attributesArray != nil {
                        for attribute in attributesArray! {
                                let layoutAttribute = attribute
                                if layoutAttribute.representedElementCategory == .Cell {
                                        if layoutAttribute.indexPath.isEqual(self.cellFakeView?.indexPath) {
                                                var cellAlpha: CGFloat = 0
                                                
                                                // reordering cell alpha
                                                if let alpha = self.datasource?.collectionView?(self.collectionView!, reorderingItemAlphaInSection: layoutAttribute.indexPath.section) {
                                                        cellAlpha = alpha
                                                }
                                                
                                                layoutAttribute.alpha = cellAlpha
                                        }
                                }
                        }
                }
                return attributesArray
        }
        
        public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
                if keyPath == "collectionView" {
                        self.setUpGestureRecognizers()
                }else {
                        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
                }
        }
        
        private func configureObserver() {
                self.addObserver(self, forKeyPath: "collectionView", options: [], context: nil)
        }
        
        private func setUpDisplayLink() {
                if self.displayLink != nil {
                        return
                }
                
                self.displayLink = CADisplayLink(target: self, selector: "continuousScroll")
                self.displayLink!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        }
        
        private func invalidateDisplayLink() {
                self.continuousScrollDirection = .stay
                self.displayLink?.invalidate()
                self.displayLink = nil
        }
        
        // begein scroll
        private func beginScrollIfNeeded() {
                if self.cellFakeView == nil {
                        return
                }
                
                let offset = self.offsetFromTop
                _ = self.insetsTop
                _ = self.insetsEnd
                let trigerInsetTop = self.trigerInsetTop
                let trigerInsetEnd = self.trigerInsetEnd
                let paddingTop = self.trigerPaddingTop
                let paddingEnd = self.trigerPaddingEnd
                let length = self.collectionViewLength
                let fakeCellTopEdge = self.fakeCellTopEdge
                let fakeCellEndEdge = self.fakeCellEndEdge
                
                if  fakeCellTopEdge <= offset + paddingTop + trigerInsetTop {
                        self.continuousScrollDirection = .toTop
                        self.setUpDisplayLink()
                }else if fakeCellEndEdge >= offset + length - paddingEnd - trigerInsetEnd {
                        self.continuousScrollDirection = .toEnd
                        self.setUpDisplayLink()
                }else {
                        self.invalidateDisplayLink()
                }
        }
        
        // move item
        private func moveItemIfNeeded() {
                var atIndexPath: NSIndexPath?
                var toIndexPath: NSIndexPath?
                if let fakeCell = self.cellFakeView {
                        atIndexPath = fakeCell.indexPath
                        toIndexPath = self.collectionView!.indexPathForItemAtPoint(cellFakeView!.center)
                }
                
                if atIndexPath == nil || toIndexPath == nil {
                        return
                }
                
                if atIndexPath!.isEqual(toIndexPath) {
                        return
                }
                
                // can move item
                if let canMove = self.delegate?.collectionView?(self.collectionView!, atIndexPath: atIndexPath!, canMoveToIndexPath: toIndexPath!) {
                        if !canMove {
                                return
                        }
                }
                
                // will move item
                self.delegate?.collectionView?(self.collectionView!, atIndexPath: atIndexPath!, willMoveToIndexPath: toIndexPath!)
                
                let attribute = self.layoutAttributesForItemAtIndexPath(toIndexPath!)!
                self.collectionView!.performBatchUpdates({ () -> Void in
                        self.cellFakeView!.indexPath = toIndexPath
                        self.cellFakeView!.cellFrame = attribute.frame
                        self.cellFakeView!.changeBoundsIfNeeded(attribute.bounds)
                        
                        self.collectionView!.deleteItemsAtIndexPaths([atIndexPath!])
                        self.collectionView!.insertItemsAtIndexPaths([toIndexPath!])
                        
                        // did move item
                        self.delegate?.collectionView?(self.collectionView!, atIndexPath: atIndexPath!, didMoveToIndexPath: toIndexPath!)
                        }, completion:nil)
        }
        
        internal func continuousScroll() {
                if self.cellFakeView == nil {
                        return
                }
                
                let percentage: CGFloat = self.calcTrigerPercentage()
                var scrollRate: CGFloat = self.continuousScrollDirection.scrollValue(speedValue: self.scrollSpeedValue, percentage: percentage)
                
                let offset: CGFloat = self.offsetFromTop
                let insetTop: CGFloat = self.insetsTop
                let insetEnd: CGFloat = self.insetsEnd
                let length: CGFloat = self.collectionViewLength
                let contentLength: CGFloat = self.contentLength
                
                if contentLength + insetTop + insetEnd <= length {
                        return
                }
                
                if offset + scrollRate <= -insetTop {
                        scrollRate = -insetTop - offset
                }else if offset + scrollRate >= contentLength + insetEnd - length {
                        scrollRate = contentLength + insetEnd - length - offset
                }
                
                self.collectionView!.performBatchUpdates({ () -> Void in
                        if self.scrollDirection == .Vertical {
                                self.fakeCellCenter?.y += scrollRate
                                self.cellFakeView?.center.y = self.fakeCellCenter!.y + self.panTranslation!.y
                                self.collectionView?.contentOffset.y += scrollRate
                        }else {
                                self.fakeCellCenter?.x += scrollRate
                                self.cellFakeView?.center.x = self.fakeCellCenter!.x + self.panTranslation!.x
                                self.collectionView?.contentOffset.x += scrollRate
                        }
                        }, completion: nil)
                
                self.moveItemIfNeeded()
        }
        
        private func calcTrigerPercentage() -> CGFloat {
                if self.cellFakeView == nil {
                        return 0
                }
                
                let offset = self.offsetFromTop
                let offsetEnd = self.offsetFromTop + self.collectionViewLength
                let insetTop = self.insetsTop
                _ = self.insetsEnd
                let trigerInsetTop = self.trigerInsetTop
                let trigerInsetEnd = self.trigerInsetEnd
                _ = self.trigerPaddingTop
                let paddingEnd = self.trigerPaddingEnd
                
                var percentage: CGFloat = 0
                
                if self.continuousScrollDirection == .toTop {
                        if let fakeCellEdge = self.fakeCellTopEdge {
                                percentage = 1.0 - ((fakeCellEdge - (offset + trigerPaddingTop)) / trigerInsetTop)
                        }
                }else if self.continuousScrollDirection == .toEnd {
                        if let fakeCellEdge = self.fakeCellEndEdge {
                                percentage = 1.0 - (((insetTop + offsetEnd - paddingEnd) - (fakeCellEdge + insetTop)) / trigerInsetEnd)
                        }
                }
                
                percentage = min(1.0, percentage)
                percentage = max(0, percentage)
                return percentage
        }
        
        // gesture recognizers
        private func setUpGestureRecognizers() {
                if self.collectionView == nil {
                        return
                }
                
                self.longPress = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
                self.panGesture = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
                self.longPress?.delegate = self
                self.panGesture?.delegate = self
                self.panGesture?.maximumNumberOfTouches = 1
                let gestures: NSArray! = self.collectionView?.gestureRecognizers
                gestures.enumerateObjectsUsingBlock { (gestureRecognizer, index, finish) -> Void in
                        if gestureRecognizer is UILongPressGestureRecognizer {
                                gestureRecognizer.requireGestureRecognizerToFail(self.longPress!)
                        }
                        self.collectionView?.addGestureRecognizer(self.longPress!)
                        self.collectionView?.addGestureRecognizer(self.panGesture!)
                }
        }
        
        public func cancelDrag() {
                self.cancelDrag(toIndexPath: nil)
        }
        
        private func cancelDrag(toIndexPath toIndexPath: NSIndexPath!) {
                if self.cellFakeView == nil {
                        return
                }
                
                // will end drag item
                self.delegate?.collectionView?(self.collectionView!, collectionViewLayout: self, willEndDraggingItemToIndexPath: toIndexPath)
                
                self.collectionView?.scrollsToTop = true
                
                self.fakeCellCenter = nil
                
                self.invalidateDisplayLink()
                
                self.cellFakeView!.pushBackView({ () -> Void in
                        self.cellFakeView!.removeFromSuperview()
                        self.cellFakeView = nil
                        self.invalidateLayout()
                        
                        // did end drag item
                        self.delegate?.collectionView?(self.collectionView!, collectionViewLayout: self, didEndDraggingItemToIndexPath: toIndexPath)
                })
        }
        
        // long press gesture
        internal func handleLongPress(longPress: UILongPressGestureRecognizer!) {
                let location = longPress.locationInView(self.collectionView)
                var indexPath: NSIndexPath? = self.collectionView?.indexPathForItemAtPoint(location)
                
                if self.cellFakeView != nil {
                        indexPath = self.cellFakeView!.indexPath
                }
                
                if indexPath == nil {
                        return
                }
                
                switch longPress.state {
                case .Began:
                        // will begin drag item
                        self.delegate?.collectionView?(self.collectionView!, collectionViewLayout: self, willBeginDraggingItemAtIndexPath: indexPath!)
                        
                        self.collectionView?.scrollsToTop = false
                        
                        let currentCell: UICollectionViewCell? = self.collectionView?.cellForItemAtIndexPath(indexPath!)
                        
                        self.cellFakeView = RACellFakeView(cell: currentCell!)
                        self.cellFakeView!.indexPath = indexPath
                        self.cellFakeView!.originalCenter = currentCell?.center
                        self.cellFakeView!.cellFrame = self.layoutAttributesForItemAtIndexPath(indexPath!)!.frame
                        self.collectionView?.addSubview(self.cellFakeView!)
                        
                        self.fakeCellCenter = self.cellFakeView!.center
                        
                        self.invalidateLayout()
                        
                        self.cellFakeView!.pushFowardView()
                        
                        // did begin drag item
                        self.delegate?.collectionView?(self.collectionView!, collectionViewLayout: self, didBeginDraggingItemAtIndexPath: indexPath!)
                case .Cancelled:
                        fallthrough
                case .Ended:
                        self.cancelDrag(toIndexPath: indexPath)
                default:
                        break
                }
        }
        
        // pan gesture
        internal func handlePanGesture(pan: UIPanGestureRecognizer!) {
                self.panTranslation = pan.translationInView(self.collectionView!)
                if self.cellFakeView != nil && self.fakeCellCenter != nil && self.panTranslation != nil {
                        switch pan.state {
                        case .Changed:
                                self.cellFakeView!.center.x = self.fakeCellCenter!.x + panTranslation!.x
                                self.cellFakeView!.center.y = self.fakeCellCenter!.y + panTranslation!.y
                                
                                self.beginScrollIfNeeded()
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
        
        // gesture recognize delegate
        public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
                // allow move item
                let location = gestureRecognizer.locationInView(self.collectionView)
                if let indexPath = self.collectionView?.indexPathForItemAtPoint(location) {
                        if self.delegate?.collectionView?(self.collectionView!, allowMoveAtIndexPath: indexPath) == false {
                                return false
                        }
                }
                
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
        
        public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
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
        
        private var cellFrame: CGRect?
        
        required init?(coder aDecoder: NSCoder) {
                super.init(coder: aDecoder)
        }
        
        init(cell: UICollectionViewCell) {
                super.init(frame: cell.frame)
                
                self.cell = cell
                
                self.layer.shadowColor = UIColor.blackColor().CGColor
                self.layer.shadowOffset = CGSizeMake(0, 0)
                self.layer.shadowOpacity = 0
                self.layer.shadowRadius = 5.0
                self.layer.shouldRasterize = false
                
                self.cellFakeImageView = UIImageView(frame: self.bounds)
                self.cellFakeImageView?.contentMode = UIViewContentMode.ScaleAspectFill
                self.cellFakeImageView?.autoresizingMask = [.FlexibleWidth , .FlexibleHeight]
                
                self.cellFakeHightedView = UIImageView(frame: self.bounds)
                self.cellFakeHightedView?.contentMode = UIViewContentMode.ScaleAspectFill
                self.cellFakeHightedView?.autoresizingMask = [.FlexibleWidth , .FlexibleHeight]
                
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
                
                UIView.animateWithDuration(0.3, delay: 0, options: [.CurveEaseInOut, .BeginFromCurrentState], animations: { () -> Void in
                        self.bounds = bounds
                        }, completion: nil)
        }
        
        func pushFowardView() {
                UIView.animateWithDuration(0.3, delay: 0, options: [.CurveEaseInOut, .BeginFromCurrentState], animations: {
                        self.center = self.originalCenter!
                        self.transform = CGAffineTransformMakeScale(1.1, 1.1)
                        self.cellFakeHightedView!.alpha = 0;
                        let shadowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
                        shadowAnimation.fromValue = 0
                        shadowAnimation.toValue = 0.7
                        shadowAnimation.removedOnCompletion = false
                        shadowAnimation.fillMode = kCAFillModeForwards
                        self.layer.addAnimation(shadowAnimation, forKey: "applyShadow")
                        }, completion: { (finished) -> Void in
                                self.cellFakeHightedView!.removeFromSuperview()
                })
        }
        
        func pushBackView(completion: (()->Void)?) {
                UIView.animateWithDuration(0.3, delay: 0, options: [.CurveEaseInOut, .BeginFromCurrentState], animations: {
                        self.transform = CGAffineTransformIdentity
                        self.frame = self.cellFrame!
                        let shadowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
                        shadowAnimation.fromValue = 0.7
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
                UIGraphicsBeginImageContextWithOptions(self.cell!.bounds.size, false, UIScreen.mainScreen().scale * 2)
                self.cell!.drawViewHierarchyInRect(self.cell!.bounds, afterScreenUpdates: true)
                let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return image
        }
}
