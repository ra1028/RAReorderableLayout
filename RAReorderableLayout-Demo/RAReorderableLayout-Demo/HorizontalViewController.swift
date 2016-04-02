//
//  HorizontalViewController.swift
//  RAReorderableLayout-Demo
//
//  Created by Ryo Aoyama on 11/17/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

import UIKit

class HorizontalViewController: UIViewController, RAReorderableLayoutDelegate, RAReorderableLayoutDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var gradientView: UIView!
    private var gradientLayer: CAGradientLayer?
    private var books: [Book] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "RAReorderableLayout"
        collectionView.registerClass(BookCell.self, forCellWithReuseIdentifier: "horizontalCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        (collectionView.collectionViewLayout as! RAReorderableLayout).scrollDirection = .Horizontal
        applyGradation()
        
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        for (index, _) in alphabet.characters.enumerate() {
            let charIndex = alphabet.startIndex.advancedBy(index)
            var title = "BOOK "
            title += alphabet.substringWithRange(charIndex...charIndex)
            let color = UIColor(hue: 255.0 / 26.0 * CGFloat(index) / 255.0, saturation: 1.0, brightness: 0.9, alpha: 1.0)
            let book = Book(title: title, color: color)
            books.append(book)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = gradientView.bounds
    }
    
    private func applyGradation() {
        gradientLayer = CAGradientLayer()
        gradientLayer!.frame = gradientView.bounds
        let mainColor = UIColor(white: 0, alpha: 0.3).CGColor
        let subColor = UIColor.clearColor().CGColor
        gradientLayer!.colors = [subColor, mainColor]
        gradientLayer!.locations = [0, 1]
        gradientView.layer.insertSublayer(gradientLayer!, atIndex: 0)
    }
    
    // collectionView delegate datasource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(130.0, 170.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 20.0, 0, 20.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 20.0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: BookCell
        cell = collectionView.dequeueReusableCellWithReuseIdentifier("horizontalCell", forIndexPath: indexPath) as! BookCell
        cell.book = books[indexPath.item]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, atIndexPath: NSIndexPath, didMoveToIndexPath toIndexPath: NSIndexPath) {
        let book = books.removeAtIndex(atIndexPath.item)
        books.insert(book, atIndex: toIndexPath.item)
    }
    
    func scrollTrigerEdgeInsetsInCollectionView(collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 50, 0, 50)
    }
    
    func scrollSpeedValueInCollectionView(collectionView: UICollectionView) -> CGFloat {
        return 15.0
    }
}

class BookCell: UICollectionViewCell {
    private var backCoverView: UIView!
    private var pagesView: UIView!
    private var frontCoverView: UIView!
    private var bindingView: UIView!
    private var titleLabel: UILabel!
    var book: Book? {
        didSet {
            titleLabel.text = book?.title
            color = book?.color
        }
    }
    var color: UIColor? {
        didSet {
            backCoverView.backgroundColor = getDarkColor(color, minusValue: 20.0)
            frontCoverView.backgroundColor = color
            bindingView.backgroundColor = getDarkColor(color, minusValue: 50.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    private func configure() {
        backCoverView = UIView(frame: bounds)
        backCoverView.backgroundColor = getDarkColor(UIColor.redColor(), minusValue: 20.0)
        backCoverView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        pagesView = UIView(frame: CGRectMake(15.0, 0, CGRectGetWidth(bounds) - 25.0, CGRectGetHeight(bounds) - 5.0))
        pagesView.backgroundColor = UIColor.whiteColor()
        pagesView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        frontCoverView = UIView(frame: CGRectMake(0, 0, CGRectGetWidth(bounds), CGRectGetHeight(bounds) - 10.0))
        frontCoverView.backgroundColor = UIColor.redColor()
        frontCoverView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        bindingView = UIView(frame: CGRectMake(0, 0, 15.0, CGRectGetHeight(bounds)))
        bindingView.backgroundColor = getDarkColor(backCoverView?.backgroundColor, minusValue: 50.0)
        bindingView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        bindingView.layer.borderWidth = 1.0
        bindingView.layer.borderColor = UIColor.blackColor().CGColor
        
        titleLabel = UILabel(frame: CGRectMake(15.0, 30.0, CGRectGetWidth(bounds) - 16.0, 30.0))
        titleLabel.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont.boldSystemFontOfSize(20.0)
        
        contentView.addSubview(backCoverView)
        contentView.addSubview(pagesView)
        contentView.addSubview(frontCoverView)
        contentView.addSubview(bindingView)
        contentView.addSubview(titleLabel)
        
        let backPath = UIBezierPath(roundedRect: backCoverView!.bounds, byRoundingCorners: [.TopRight, .BottomRight], cornerRadii: CGSizeMake(10.0, 10.0))
        let backMask = CAShapeLayer()
        backMask.frame = backCoverView!.bounds
        backMask.path = backPath.CGPath
        let backLineLayer = CAShapeLayer()
        backLineLayer.frame = backCoverView!.bounds
        backLineLayer.path = backPath.CGPath
        backLineLayer.strokeColor = UIColor.blackColor().CGColor
        backLineLayer.fillColor = UIColor.clearColor().CGColor
        backLineLayer.lineWidth = 2.0
        backCoverView!.layer.mask = backMask
        backCoverView!.layer.insertSublayer(backLineLayer, atIndex: 0)
        
        let frontPath = UIBezierPath(roundedRect: frontCoverView!.bounds, byRoundingCorners: [.TopRight, .BottomRight], cornerRadii: CGSizeMake(10.0, 10.0))
        let frontMask = CAShapeLayer()
        frontMask.frame = frontCoverView!.bounds
        frontMask.path = frontPath.CGPath
        let frontLineLayer = CAShapeLayer()
        frontLineLayer.path = frontPath.CGPath
        frontLineLayer.strokeColor = UIColor.blackColor().CGColor
        frontLineLayer.fillColor = UIColor.clearColor().CGColor
        frontLineLayer.lineWidth = 2.0
        frontCoverView!.layer.mask = frontMask
        frontCoverView!.layer.insertSublayer(frontLineLayer, atIndex: 0)
    }
    
    private func getDarkColor(color: UIColor?, minusValue: CGFloat) -> UIColor? {
        if color == nil {
            return nil
        }
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color!.getRed(&r, green: &g, blue: &b, alpha: &a)
        r -= max(minusValue / 255.0, 0)
        g -= max(minusValue / 255.0, 0)
        b -= max(minusValue / 255.0, 0)
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

class Book: NSObject {
    var title: String?
    var color: UIColor?
    
    init(title: String?, color: UIColor) {
        super.init()
        self.title = title
        self.color = color
    }
}
