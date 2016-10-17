//
//  RAReorderableLayout.swift
//  RAReorderableLayout
//
//  Created by Ryo Aoyama on 10/12/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

import UIKit

public protocol RAReorderableLayoutDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, at: IndexPath, willMoveTo toIndexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, at: IndexPath, didMoveTo toIndexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, allowMoveAt indexPath: IndexPath) -> Bool
    func collectionView(_ collectionView: UICollectionView, at: IndexPath, canMoveTo: IndexPath) -> Bool
    
    func collectionView(_ collectionView: UICollectionView, collectionView layout: RAReorderableLayout, willBeginDraggingItemAt indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, collectionView layout: RAReorderableLayout, didBeginDraggingItemAt indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, collectionView layout: RAReorderableLayout, willEndDraggingItemTo indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, collectionView layout: RAReorderableLayout, didEndDraggingItemTo indexPath: IndexPath)
}

public protocol RAReorderableLayoutDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    
    func collectionView(_ collectionView: UICollectionView, reorderingItemAlphaInSection section: Int) -> CGFloat
    func scrollTrigerEdgeInsetsInCollectionView(_ collectionView: UICollectionView) -> UIEdgeInsets
    func scrollTrigerPaddingInCollectionView(_ collectionView: UICollectionView) -> UIEdgeInsets
    func scrollSpeedValueInCollectionView(_ collectionView: UICollectionView) -> CGFloat
}

public extension RAReorderableLayoutDataSource {
    func collectionView(_ collectionView: UICollectionView, reorderingItemAlphaInSection section: Int) -> CGFloat {
        return 0
    }
    func scrollTrigerEdgeInsetsInCollectionView(_ collectionView: UICollectionView) -> UIEdgeInsets {
        return .init(top: 100, left: 100, bottom: 100, right: 100)
    }
    func scrollTrigerPaddingInCollectionView(_ collectionView: UICollectionView) -> UIEdgeInsets {
        return  .zero
    }
    func scrollSpeedValueInCollectionView(_ collectionView: UICollectionView) -> CGFloat {
        return 10
    }
}

public extension RAReorderableLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, at: IndexPath, willMoveTo toIndexPath: IndexPath) {}
    func collectionView(_ collectionView: UICollectionView, at: IndexPath, didMoveTo toIndexPath: IndexPath) {}
    func collectionView(_ collectionView: UICollectionView, allowMoveAt indexPath: IndexPath) -> Bool {
        return true
    }
    func collectionView(_ collectionView: UICollectionView, at: IndexPath, canMoveTo: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, collectionView layout: RAReorderableLayout, willBeginDraggingItemAt indexPath: IndexPath) {}
    func collectionView(_ collectionView: UICollectionView, collectionView layout: RAReorderableLayout, didBeginDraggingItemAt indexPath: IndexPath) {}
    func collectionView(_ collectionView: UICollectionView, collectionView layout: RAReorderableLayout, willEndDraggingItemTo indexPath: IndexPath) {}
    func collectionView(_ collectionView: UICollectionView, collectionView layout: RAReorderableLayout, didEndDraggingItemTo indexPath: IndexPath) {}
}

open class RAReorderableLayout: UICollectionViewFlowLayout, UIGestureRecognizerDelegate {
    
    fileprivate enum direction {
        case toTop
        case toEnd
        case stay
        
        fileprivate func scrollValue(_ speedValue: CGFloat, percentage: CGFloat) -> CGFloat {
            var value: CGFloat = 0.0
            switch self {
            case .toTop:
                value = -speedValue
            case .toEnd:
                value = speedValue
            case .stay:
                return 0
            }
            
            let proofedPercentage: CGFloat = max(min(1.0, percentage), 0)
            return value * proofedPercentage
        }
    }
    
     public weak var delegate: RAReorderableLayoutDelegate? {
        get { return collectionView?.delegate as? RAReorderableLayoutDelegate }
        set { collectionView?.delegate = delegate }
    }
    
     public weak var dataSource: RAReorderableLayoutDataSource? {
        set { collectionView?.dataSource = dataSource }
        get { return collectionView?.dataSource as? RAReorderableLayoutDataSource }
    }
    
    fileprivate var displayLink: CADisplayLink?
    
    fileprivate var longPress: UILongPressGestureRecognizer?
    
    fileprivate var panGesture: UIPanGestureRecognizer?
    
    fileprivate var continuousScrollDirection: direction = .stay
    
    fileprivate var cellFakeView: RACellFakeView?
    
    fileprivate var panTranslation: CGPoint?
    
    fileprivate var fakeCellCenter: CGPoint?
    
    fileprivate var trigerInsets = UIEdgeInsetsMake(100.0, 100.0, 100.0, 100.0)
    
    fileprivate var trigerPadding = UIEdgeInsets.zero
    
    fileprivate var scrollSpeedValue: CGFloat = 10.0
    
    fileprivate var offsetFromTop: CGFloat {
        let contentOffset = collectionView!.contentOffset
        return scrollDirection == .vertical ? contentOffset.y : contentOffset.x
    }
    
    fileprivate var insetsTop: CGFloat {
        let contentInsets = collectionView!.contentInset
        return scrollDirection == .vertical ? contentInsets.top : contentInsets.left
    }
    
    fileprivate var insetsEnd: CGFloat {
        let contentInsets = collectionView!.contentInset
        return scrollDirection == .vertical ? contentInsets.bottom : contentInsets.right
    }
    
    fileprivate var contentLength: CGFloat {
        let contentSize = collectionView!.contentSize
        return scrollDirection == .vertical ? contentSize.height : contentSize.width
    }
    
    fileprivate var collectionViewLength: CGFloat {
        let collectionViewSize = collectionView!.bounds.size
        return scrollDirection == .vertical ? collectionViewSize.height : collectionViewSize.width
    }
    
    fileprivate var fakeCellTopEdge: CGFloat? {
        if let fakeCell = cellFakeView {
            return scrollDirection == .vertical ? fakeCell.frame.minY : fakeCell.frame.minX
        }
        return nil
    }
    
    fileprivate var fakeCellEndEdge: CGFloat? {
        if let fakeCell = cellFakeView {
            return scrollDirection == .vertical ? fakeCell.frame.maxY : fakeCell.frame.maxX
        }
        return nil
    }
    
    fileprivate var triggerInsetTop: CGFloat {
        return scrollDirection == .vertical ? trigerInsets.top : trigerInsets.left
    }
    
    fileprivate var triggerInsetEnd: CGFloat {
        return scrollDirection == .vertical ? trigerInsets.top : trigerInsets.left
    }
    
    fileprivate var triggerPaddingTop: CGFloat {
        return scrollDirection == .vertical ? trigerPadding.top : trigerPadding.left
    }
    
    fileprivate var triggerPaddingEnd: CGFloat {
        return scrollDirection == .vertical ? trigerPadding.bottom : trigerPadding.right
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureObserver()
    }
    
    public override init() {
        super.init()
        configureObserver()
    }
    
    deinit {
        removeObserver(self, forKeyPath: "collectionView")
    }
    
    override open func prepare() {
        super.prepare()
        
        // scroll trigger insets
        if let insets = dataSource?.scrollTrigerEdgeInsetsInCollectionView(self.collectionView!) {
            trigerInsets = insets
        }
        
        // scroll trier padding
        if let padding = dataSource?.scrollTrigerPaddingInCollectionView(self.collectionView!) {
            trigerPadding = padding
        }
        
        // scroll speed value
        if let speed = dataSource?.scrollSpeedValueInCollectionView(collectionView!) {
            scrollSpeedValue = speed
        }
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributesArray = super.layoutAttributesForElements(in: rect) else { return nil }

        attributesArray.filter {
            $0.representedElementCategory == .cell
        }.filter {
            $0.indexPath == (cellFakeView?.indexPath)
        }.forEach {
            // reordering cell alpha
            
            $0.alpha = dataSource?.collectionView(self.collectionView!, reorderingItemAlphaInSection: $0.indexPath.section) ?? 0
        }

        return attributesArray
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "collectionView" {
            setUpGestureRecognizers()
        }else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    fileprivate func configureObserver() {
        addObserver(self, forKeyPath: "collectionView", options: [], context: nil)
    }
    
    fileprivate func setUpDisplayLink() {
        guard displayLink == nil else {
            return
        }
        
        displayLink = CADisplayLink(target: self, selector: #selector(RAReorderableLayout.continuousScroll))
        displayLink!.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
    }
    
    fileprivate func invalidateDisplayLink() {
        continuousScrollDirection = .stay
        displayLink?.invalidate()
        displayLink = nil
    }
    
    // begein scroll
    fileprivate func beginScrollIfNeeded() {
        if cellFakeView == nil { return }
        
        if fakeCellTopEdge! <= offsetFromTop + triggerPaddingTop + triggerInsetTop {
            continuousScrollDirection = .toTop
            setUpDisplayLink()
        } else if fakeCellEndEdge! >= offsetFromTop + collectionViewLength - triggerPaddingEnd - triggerInsetEnd {
            continuousScrollDirection = .toEnd
            setUpDisplayLink()
        } else {
            invalidateDisplayLink()
        }
    }
    
    // move item
    fileprivate func moveItemIfNeeded() {
        guard let fakeCell = cellFakeView,
            let atIndexPath = fakeCell.indexPath,
            let toIndexPath = collectionView!.indexPathForItem(at: fakeCell.center) else {
                return
        }
        
        guard atIndexPath != toIndexPath else { return }
        
        // can move item
        if let canMove = delegate?.collectionView(collectionView!, at: atIndexPath, canMoveTo: toIndexPath) , !canMove {
            return
        }
        
        // will move item
        delegate?.collectionView(collectionView!, at: atIndexPath, willMoveTo: toIndexPath)
        
        let attribute = self.layoutAttributesForItem(at: toIndexPath)!
        collectionView!.performBatchUpdates({
            fakeCell.indexPath = toIndexPath
            fakeCell.cellFrame = attribute.frame
            fakeCell.changeBoundsIfNeeded(attribute.bounds)
            
            self.collectionView!.deleteItems(at: [atIndexPath])
            self.collectionView!.insertItems(at: [toIndexPath])
            
            // did move item
            self.delegate?.collectionView(self.collectionView!, at: atIndexPath, didMoveTo: toIndexPath)
            }, completion:nil)
    }
    
    internal func continuousScroll() {
        guard let fakeCell = cellFakeView else { return }
        
        let percentage = calcTriggerPercentage()
        var scrollRate = continuousScrollDirection.scrollValue(self.scrollSpeedValue, percentage: percentage)
        
        let offset = offsetFromTop
        let length = collectionViewLength
        
        if contentLength + insetsTop + insetsEnd <= length {
            return
        }
        
        if offset + scrollRate <= -insetsTop {
            scrollRate = -insetsTop - offset
        } else if offset + scrollRate >= contentLength + insetsEnd - length {
            scrollRate = contentLength + insetsEnd - length - offset
        }
        
        collectionView!.performBatchUpdates({
            if self.scrollDirection == .vertical {
                self.fakeCellCenter?.y += scrollRate
                fakeCell.center.y = self.fakeCellCenter!.y + self.panTranslation!.y
                self.collectionView?.contentOffset.y += scrollRate
            } else {
                self.fakeCellCenter?.x += scrollRate
                fakeCell.center.x = self.fakeCellCenter!.x + self.panTranslation!.x
                self.collectionView?.contentOffset.x += scrollRate
            }
            }, completion: nil)
        
        moveItemIfNeeded()
    }
    
    fileprivate func calcTriggerPercentage() -> CGFloat {
        guard cellFakeView != nil else { return 0 }
        
        let offset = offsetFromTop
        let offsetEnd = offsetFromTop + collectionViewLength
        let paddingEnd = triggerPaddingEnd
        
        var percentage: CGFloat = 0
        
        if self.continuousScrollDirection == .toTop {
            if let fakeCellEdge = fakeCellTopEdge {
                percentage = 1.0 - ((fakeCellEdge - (offset + triggerPaddingTop)) / triggerInsetTop)
            }
        }else if continuousScrollDirection == .toEnd {
            if let fakeCellEdge = fakeCellEndEdge {
                percentage = 1.0 - (((insetsTop + offsetEnd - paddingEnd) - (fakeCellEdge + insetsTop)) / triggerInsetEnd)
            }
        }
        
        percentage = min(1.0, percentage)
        percentage = max(0, percentage)
        return percentage
    }
    
    // gesture recognizers
    fileprivate func setUpGestureRecognizers() {
        guard let collectionView = collectionView else { return }
        guard longPress == nil && panGesture == nil else {return }
        
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(RAReorderableLayout.handleLongPress(_:)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(RAReorderableLayout.handlePanGesture(_:)))
        longPress?.delegate = self
        panGesture?.delegate = self
        panGesture?.maximumNumberOfTouches = 1
        let gestures: NSArray! = collectionView.gestureRecognizers as NSArray!
        gestures.enumerateObjects(options: []) { gestureRecognizer, index, finish in
            if gestureRecognizer is UILongPressGestureRecognizer {
                (gestureRecognizer as AnyObject).require(toFail: self.longPress!)
            }
            collectionView.addGestureRecognizer(self.longPress!)
            collectionView.addGestureRecognizer(self.panGesture!)
            }
        }
    
    open func cancelDrag() {
        cancelDrag(nil)
    }
    
    fileprivate func cancelDrag(_ toIndexPath: IndexPath!) {
        guard cellFakeView != nil else { return }
        
        // will end drag item
        self.delegate?.collectionView(self.collectionView!, collectionView: self, willEndDraggingItemTo: toIndexPath)
        
        collectionView?.scrollsToTop = true
        
        fakeCellCenter = nil
        
        invalidateDisplayLink()
        
        cellFakeView!.pushBackView {
            self.cellFakeView!.removeFromSuperview()
            self.cellFakeView = nil
            self.invalidateLayout()
            
            // did end drag item
            self.delegate?.collectionView(self.collectionView!, collectionView: self, didEndDraggingItemTo: toIndexPath)
        }
    }
    
    // long press gesture
    internal func handleLongPress(_ longPress: UILongPressGestureRecognizer!) {
        let location = longPress.location(in: collectionView)
        var indexPath: IndexPath? = collectionView?.indexPathForItem(at: location)
        
        if let cellFakeView = cellFakeView {
            indexPath = cellFakeView.indexPath
        }
        
        if indexPath == nil { return }
        
        switch longPress.state {
        case .began:
            // will begin drag item
            delegate?.collectionView(self.collectionView!, collectionView: self, willBeginDraggingItemAt: indexPath!)
            collectionView?.scrollsToTop = false
            
            let currentCell = collectionView?.cellForItem(at: indexPath!)
            
            cellFakeView = RACellFakeView(cell: currentCell!)
            cellFakeView!.indexPath = indexPath
            cellFakeView!.originalCenter = currentCell?.center
            cellFakeView!.cellFrame = layoutAttributesForItem(at: indexPath!)!.frame
            collectionView?.addSubview(cellFakeView!)
            
            fakeCellCenter = cellFakeView!.center
            
            invalidateLayout()

            cellFakeView?.pushFowardView()
            
            // did begin drag item
            delegate?.collectionView(self.collectionView!, collectionView: self, didBeginDraggingItemAt: indexPath!)
            
        case .cancelled, .ended:
            cancelDrag(indexPath)
        default:
            break
        }
    }
    
    // pan gesture
    func handlePanGesture(_ pan: UIPanGestureRecognizer!) {
        panTranslation = pan.translation(in: collectionView!)
        if let cellFakeView = cellFakeView,
            let fakeCellCenter = fakeCellCenter,
            let panTranslation = panTranslation {
            switch pan.state {
            case .changed:
                cellFakeView.center.x = fakeCellCenter.x + panTranslation.x
                cellFakeView.center.y = fakeCellCenter.y + panTranslation.y
                
                beginScrollIfNeeded()
                moveItemIfNeeded()
            case .cancelled, .ended:
                invalidateDisplayLink()
            default:
                break
            }
        }
    }
    
    // gesture recognize delegate
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // allow move item
        let location = gestureRecognizer.location(in: collectionView)
        if let indexPath = collectionView?.indexPathForItem(at: location) ,
            delegate?.collectionView(self.collectionView!, allowMoveAt: indexPath) == false {
            return false
        }
        
        switch gestureRecognizer {
        case longPress:
            return !(collectionView!.panGestureRecognizer.state != .possible && collectionView!.panGestureRecognizer.state != .failed)
        case panGesture:
            return !(longPress!.state == .possible || longPress!.state == .failed)
        default:
            return true
        }
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        switch gestureRecognizer {
        case panGesture:
            return otherGestureRecognizer == longPress
        case collectionView?.panGestureRecognizer:
            return (longPress!.state != .possible || longPress!.state != .failed)
        default:
            return true
        }
    }
}

private class RACellFakeView: UIView {
    
    weak var cell: UICollectionViewCell?
    
    var cellFakeImageView: UIImageView?
    
    var cellFakeHightedView: UIImageView?
    
    fileprivate var indexPath: IndexPath?
    
    fileprivate var originalCenter: CGPoint?
    
    fileprivate var cellFrame: CGRect?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(cell: UICollectionViewCell) {
        super.init(frame: cell.frame)
        
        self.cell = cell
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0
        layer.shadowRadius = 5.0
        layer.shouldRasterize = false
        
        cellFakeImageView = UIImageView(frame: self.bounds)
        cellFakeImageView?.contentMode = UIViewContentMode.scaleAspectFill
        cellFakeImageView?.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        
        cellFakeHightedView = UIImageView(frame: self.bounds)
        cellFakeHightedView?.contentMode = UIViewContentMode.scaleAspectFill
        cellFakeHightedView?.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        
        cell.isHighlighted = true
        cellFakeHightedView?.image = getCellImage()
        cell.isHighlighted = false
        cellFakeImageView?.image = getCellImage()
        
        addSubview(cellFakeImageView!)
        addSubview(cellFakeHightedView!)
    }
    
    func changeBoundsIfNeeded(_ bounds: CGRect) {
        if self.bounds.equalTo(bounds) { return }
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseInOut, .beginFromCurrentState],
            animations: {
                self.bounds = bounds
            },
            completion: nil
        )
    }
    
    func pushFowardView() {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseInOut, .beginFromCurrentState],
            animations: {
                self.center = self.originalCenter!
                self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.cellFakeHightedView!.alpha = 0;
                let shadowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
                shadowAnimation.fromValue = 0
                shadowAnimation.toValue = 0.7
                shadowAnimation.isRemovedOnCompletion = false
                shadowAnimation.fillMode = kCAFillModeForwards
                self.layer.add(shadowAnimation, forKey: "applyShadow")
            },
            completion: { _ in
                self.cellFakeHightedView?.removeFromSuperview()
            }
        )
    }
    
    func pushBackView(_ completion: (()->Void)?) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseInOut, .beginFromCurrentState],
            animations: {
                self.transform = CGAffineTransform.identity
                self.frame = self.cellFrame!
                let shadowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
                shadowAnimation.fromValue = 0.7
                shadowAnimation.toValue = 0
                shadowAnimation.isRemovedOnCompletion = false
                shadowAnimation.fillMode = kCAFillModeForwards
                self.layer.add(shadowAnimation, forKey: "removeShadow")
            },
            completion: { _ in
                completion?()
            }
        )
    }
    
    fileprivate func getCellImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(cell!.bounds.size, false, UIScreen.main.scale * 2)
        defer { UIGraphicsEndImageContext() }
        cell!.drawHierarchy(in: cell!.bounds, afterScreenUpdates: true)

        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}

// Convenience method
private func ~= (obj:NSObjectProtocol?, r:UIGestureRecognizer) -> Bool {
    return r.isEqual(obj)
}
