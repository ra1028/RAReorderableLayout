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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "RAReorderableLayout"
        self.collectionView.registerClass(BookCell.self, forCellWithReuseIdentifier: "horizontalCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        (self.collectionView.collectionViewLayout as RAReorderableLayout).scrollDirection = .Horizontal
        self.applyGradation()
        
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        for (index, char) in enumerate(alphabet) {
            let charIndex = advance(alphabet.startIndex, index)
            var title = "BOOK "
            title += alphabet.substringWithRange(charIndex...charIndex)
            let color = UIColor(hue: 255.0 / 26.0 * CGFloat(index) / 255.0, saturation: 1.0, brightness: 0.9, alpha: 1.0)
            let book = Book(title: title, color: color)
            self.books.append(book)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, 0, 0)
        self.gradientLayer?.frame = self.gradientView.bounds
    }
    
    private func applyGradation() {
        self.gradientLayer = CAGradientLayer()
        self.gradientLayer!.frame = self.gradientView.bounds
        let mainColor = UIColor(white: 0, alpha: 0.3).CGColor
        let subColor = UIColor.clearColor().CGColor
        self.gradientLayer!.colors = [subColor, mainColor]
        self.gradientLayer!.locations = [0, 1]
        self.gradientView.layer.insertSublayer(self.gradientLayer, atIndex: 0)
    }
    
    // collectionView delegate datasource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.books.count
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
        cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("horizontalCell", forIndexPath: indexPath) as BookCell
        cell.book = self.books[indexPath.item]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, atIndexPath: NSIndexPath, didMoveToIndexPath toIndexPath: NSIndexPath) {
        let book = self.books.removeAtIndex(atIndexPath.item)
        self.books.insert(book, atIndex: toIndexPath.item)
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
            self.titleLabel.text = book?.title
            self.color = book?.color
        }
    }
    var color: UIColor? {
        didSet {
            self.backCoverView.backgroundColor = self.getDarkColor(color, minusValue: 20.0)
            self.frontCoverView.backgroundColor = color
            self.bindingView.backgroundColor = self.getDarkColor(color, minusValue: 50.0)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
    }
    
    private func configure() {
        self.backCoverView = UIView(frame: self.bounds)
        self.backCoverView.backgroundColor = self.getDarkColor(UIColor.redColor(), minusValue: 20.0)
        self.backCoverView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        self.pagesView = UIView(frame: CGRectMake(15.0, 0, CGRectGetWidth(self.bounds) - 25.0, CGRectGetHeight(self.bounds) - 5.0))
        self.pagesView.backgroundColor = UIColor.whiteColor()
        self.pagesView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        self.frontCoverView = UIView(frame: CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - 10.0))
        self.frontCoverView.backgroundColor = UIColor.redColor()
        self.frontCoverView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        self.bindingView = UIView(frame: CGRectMake(0, 0, 15.0, CGRectGetHeight(self.bounds)))
        self.bindingView.backgroundColor = self.getDarkColor(self.backCoverView?.backgroundColor, minusValue: 50.0)
        self.bindingView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.bindingView.layer.borderWidth = 1.0
        self.bindingView.layer.borderColor = UIColor.blackColor().CGColor
        
        self.titleLabel = UILabel(frame: CGRectMake(15.0, 30.0, CGRectGetWidth(self.bounds) - 16.0, 30.0))
        self.titleLabel.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        self.titleLabel.textColor = UIColor.blackColor()
        self.titleLabel.textAlignment = .Center
        self.titleLabel.font = UIFont.boldSystemFontOfSize(20.0)
        
        self.contentView.addSubview(self.backCoverView)
        self.contentView.addSubview(self.pagesView)
        self.contentView.addSubview(self.frontCoverView)
        self.contentView.addSubview(self.bindingView)
        self.contentView.addSubview(self.titleLabel)
        
        var backPath = UIBezierPath(roundedRect: self.backCoverView!.bounds, byRoundingCorners: .TopRight | .BottomRight, cornerRadii: CGSizeMake(10.0, 10.0))
        var backMask = CAShapeLayer()
        backMask.frame = self.backCoverView!.bounds
        backMask.path = backPath.CGPath
        var backLineLayer = CAShapeLayer()
        backLineLayer.frame = self.backCoverView!.bounds
        backLineLayer.path = backPath.CGPath
        backLineLayer.strokeColor = UIColor.blackColor().CGColor
        backLineLayer.fillColor = UIColor.clearColor().CGColor
        backLineLayer.lineWidth = 2.0
        self.backCoverView!.layer.mask = backMask
        self.backCoverView!.layer.insertSublayer(backLineLayer, atIndex: 0)
        
        var frontPath = UIBezierPath(roundedRect: self.frontCoverView!.bounds, byRoundingCorners: .TopRight | .BottomRight, cornerRadii: CGSizeMake(10.0, 10.0))
        var frontMask = CAShapeLayer()
        frontMask.frame = self.frontCoverView!.bounds
        frontMask.path = frontPath.CGPath
        var frontLineLayer = CAShapeLayer()
        frontLineLayer.path = frontPath.CGPath
        frontLineLayer.strokeColor = UIColor.blackColor().CGColor
        frontLineLayer.fillColor = UIColor.clearColor().CGColor
        frontLineLayer.lineWidth = 2.0
        self.frontCoverView!.layer.mask = frontMask
        self.frontCoverView!.layer.insertSublayer(frontLineLayer, atIndex: 0)
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
