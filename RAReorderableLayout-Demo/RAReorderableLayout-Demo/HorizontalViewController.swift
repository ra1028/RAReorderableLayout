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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "RAReorderableLayout"
        collectionView.register(BookCell.self, forCellWithReuseIdentifier: "horizontalCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        (collectionView.collectionViewLayout as! RAReorderableLayout).scrollDirection = .horizontal
        applyGradation()
        
        let aScalars = "A".unicodeScalars
        let zScalars = "Z".unicodeScalars
        let aAsciiCode = aScalars[aScalars.startIndex].value
        let zAsciiCode = zScalars[zScalars.startIndex].value
        books = (aAsciiCode...zAsciiCode)
            .flatMap(UnicodeScalar.init)
            .map(Character.init)
            .enumerated()
            .map {
                let title = "Book \(String($1))"
                let color = UIColor(hue: 255.0 / 26.0 * CGFloat($0) / 255.0, saturation: 1.0, brightness: 0.9, alpha: 1.0)
                return .init(title: title, color: color)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = gradientView.bounds
    }
    
    private func applyGradation() {
        gradientLayer = CAGradientLayer()
        gradientLayer!.frame = gradientView.bounds
        let mainColor = UIColor(white: 0, alpha: 0.3).cgColor
        let subColor = UIColor.clear.cgColor
        gradientLayer!.colors = [subColor, mainColor]
        gradientLayer!.locations = [0, 1]
        gradientView.layer.insertSublayer(gradientLayer!, at: 0)
    }
    
    // collectionView delegate datasource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130.0, height: 170.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 20.0, 0, 20.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: BookCell
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "horizontalCell", for: indexPath) as! BookCell
        cell.book = books[(indexPath as NSIndexPath).item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, at: IndexPath, willMoveTo toIndexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, at: IndexPath, didMoveTo toIndexPath: IndexPath) {
        let book = books.remove(at: at.item)
        books.insert(book, at: toIndexPath.item)
    }
    
    func scrollTrigerEdgeInsetsInCollectionView(_ collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 50, 0, 50)
    }
    
    func scrollSpeedValueInCollectionView(_ collectionView: UICollectionView) -> CGFloat {
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
        backCoverView.backgroundColor = getDarkColor(UIColor.red, minusValue: 20.0)
        backCoverView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        pagesView = UIView(frame: CGRect(x: 15.0, y: 0, width: bounds.width - 25.0, height: bounds.height - 5.0))
        pagesView.backgroundColor = UIColor.white
        pagesView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        frontCoverView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - 10.0))
        frontCoverView.backgroundColor = UIColor.red
        frontCoverView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        bindingView = UIView(frame: CGRect(x: 0, y: 0, width: 15.0, height: bounds.height))
        bindingView.backgroundColor = getDarkColor(backCoverView?.backgroundColor, minusValue: 50.0)
        bindingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bindingView.layer.borderWidth = 1.0
        bindingView.layer.borderColor = UIColor.black.cgColor
        
        titleLabel = UILabel(frame: CGRect(x: 15.0, y: 30.0, width: bounds.width - 16.0, height: 30.0))
        titleLabel.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        
        contentView.addSubview(backCoverView)
        contentView.addSubview(pagesView)
        contentView.addSubview(frontCoverView)
        contentView.addSubview(bindingView)
        contentView.addSubview(titleLabel)
        
        let backPath = UIBezierPath(roundedRect: backCoverView!.bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: 10.0, height: 10.0))
        let backMask = CAShapeLayer()
        backMask.frame = backCoverView!.bounds
        backMask.path = backPath.cgPath
        let backLineLayer = CAShapeLayer()
        backLineLayer.frame = backCoverView!.bounds
        backLineLayer.path = backPath.cgPath
        backLineLayer.strokeColor = UIColor.black.cgColor
        backLineLayer.fillColor = UIColor.clear.cgColor
        backLineLayer.lineWidth = 2.0
        backCoverView!.layer.mask = backMask
        backCoverView!.layer.insertSublayer(backLineLayer, at: 0)
        
        let frontPath = UIBezierPath(roundedRect: frontCoverView!.bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: 10.0, height: 10.0))
        let frontMask = CAShapeLayer()
        frontMask.frame = frontCoverView!.bounds
        frontMask.path = frontPath.cgPath
        let frontLineLayer = CAShapeLayer()
        frontLineLayer.path = frontPath.cgPath
        frontLineLayer.strokeColor = UIColor.black.cgColor
        frontLineLayer.fillColor = UIColor.clear.cgColor
        frontLineLayer.lineWidth = 2.0
        frontCoverView!.layer.mask = frontMask
        frontCoverView!.layer.insertSublayer(frontLineLayer, at: 0)
    }
    
    private func getDarkColor(_ color: UIColor?, minusValue: CGFloat) -> UIColor? {
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
