//
//  HorizontalViewController.swift
//  RAReorderableLayout-Demo
//
//  Created by Ryo Aoyama on 11/17/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

import UIKit

class HorizontalViewController: UIViewController, RAReorderableLayoutDelegate, RAReorderableLayoutDataSource {
    
    @IBOutlet var topCollectionView: UICollectionView!
    
    @IBOutlet weak var middleCollectionView: UICollectionView!
    
    @IBOutlet weak var bottomCollectionView: UICollectionView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "RAReorderableLayout"
        self.topCollectionView.registerClass(BookCell.self, forCellWithReuseIdentifier: "horizontalCell1")
        self.middleCollectionView.registerClass(BookCell.self, forCellWithReuseIdentifier: "horizontalCell2")
        self.bottomCollectionView.registerClass(BookCell.self, forCellWithReuseIdentifier: "horizontalCell3")
        self.topCollectionView.delegate = self
        self.topCollectionView.dataSource = self
        self.middleCollectionView.delegate = self
        self.middleCollectionView.dataSource = self
        self.bottomCollectionView.delegate = self
        self.bottomCollectionView.dataSource = self
        (self.topCollectionView.collectionViewLayout as RAReorderableLayout).scrollDirection = .Horizontal
        (self.middleCollectionView.collectionViewLayout as RAReorderableLayout).scrollDirection = .Horizontal
        (self.bottomCollectionView.collectionViewLayout as RAReorderableLayout).scrollDirection = .Horizontal
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.view.setNeedsLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.topCollectionView.contentSize.height = self.topCollectionView.bounds.height
        self.middleCollectionView.contentSize.height = self.middleCollectionView.bounds.height
        self.bottomCollectionView.contentSize.height = self.bottomCollectionView.bounds.height
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(130.0, 150.0)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: BookCell
        
        if collectionView.tag == 0 {
            cell = self.topCollectionView.dequeueReusableCellWithReuseIdentifier("horizontalCell1", forIndexPath: indexPath) as BookCell
        }else if collectionView.tag == 1 {
            cell = self.middleCollectionView.dequeueReusableCellWithReuseIdentifier("horizontalCell2", forIndexPath: indexPath) as BookCell
        }else {
            cell = self.bottomCollectionView.dequeueReusableCellWithReuseIdentifier("horizontalCell3", forIndexPath: indexPath) as BookCell
        }
        
        return cell
    }
}

class BookCell: UICollectionViewCell {
    private var backCoverView: UIView?
    private var pagesView: UIView?
    private var frontCoverView: UIView?
    private var bindingView: UIView?
    var titleLabel: UILabel?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    func configure() {
        let size = self.contentView.bounds.size
        
        self.backCoverView = UIView(frame: self.contentView.bounds)
        self.backCoverView!.backgroundColor = UIColor.redColor()
        self.backCoverView!.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.backCoverView!.userInteractionEnabled = false
        
        self.pagesView = UIView(frame: CGRectMake(10.0, 0, size.width - 15.0, size.height - 5.0))
        self.pagesView!.backgroundColor = UIColor.whiteColor()
        self.pagesView!.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        self.frontCoverView = UIView(frame: CGRectMake(0, 0, size.width, size.height - 10.0))
        self.frontCoverView!.backgroundColor = UIColor.redColor()
        self.frontCoverView!.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        self.bindingView = UIView(frame: CGRectMake(0, 0, 10.0, size.height))
        self.bindingView!.backgroundColor = UIColor(white: 0, alpha:0.3)
        self.bindingView!.autoresizingMask = .FlexibleHeight
        
        self.titleLabel = UILabel(frame: CGRectMake(10.0, 30.0, self.frontCoverView!.bounds.width - 10.0, 30.0))
        self.titleLabel!.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        self.titleLabel!.textAlignment = .Center
        self.titleLabel!.font = UIFont.boldSystemFontOfSize(20.0)
        self.titleLabel!.text = "Book"
        self.titleLabel!.autoresizingMask = .FlexibleWidth
        
        self.backCoverView!.addSubview(self.pagesView!)
        self.backCoverView!.addSubview(self.frontCoverView!)
        self.backCoverView!.addSubview(self.bindingView!)
        self.backCoverView!.addSubview(self.titleLabel!)
        self.contentView.addSubview(self.backCoverView!)
        
        var backPath = UIBezierPath(roundedRect: self.backCoverView!.bounds, byRoundingCorners: .TopRight | .BottomRight, cornerRadii: CGSizeMake(10.0, 10.0))
        var backMask = CAShapeLayer()
        backMask.frame = self.backCoverView!.bounds
        backMask.path = backPath.CGPath
        self.backCoverView!.layer.mask = backMask
        
        var frontPath = UIBezierPath(roundedRect: self.frontCoverView!.bounds, byRoundingCorners: .TopRight | .BottomRight, cornerRadii: CGSizeMake(10.0, 10.0))
        var frontMask = CAShapeLayer()
        frontMask.frame = self.frontCoverView!.bounds
        frontMask.path = frontPath.CGPath
        self.frontCoverView!.layer.mask = frontMask
    }
}
