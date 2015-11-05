RAReorderableLayout
=======================

#### A UICollectionView layout which you can move items with drag and drop.


## Screen shots
![screen shot1](https://github.com/ra1028/RAReorderableLayout/raw/master/Assets/screenshot1.png)
![screen shot2](https://github.com/ra1028/RAReorderableLayout/raw/master/Assets/screenshot2.png)


## Animation
![animated gif](https://github.com/ra1028/RAReorderableLayout/raw/master/Assets/animation.gif)


## Installation
__iOS8__  

### CocoaPods
```ruby
# Podfile  
use_frameworks!  
pod "RAReorderableLayout"  
```
### Carthage
```ruby
 # Cartfile
 github "ra1028/RAReorderableLayout"
 ```

__iOS7__  
1. Simply copy RAReorderableLayout.swift into your project.


## Usage
Setup your collection view to use RAReorderableLayout.  
You must reorder cells information array in RAReorderableLayoutDelegate protocol to support reordering capability.  
Specifically, please refer to Demo-project.


## Protocol

Delegate
```
optional func collectionView(collectionView: UICollectionView, atIndexPath: NSIndexPath, willMoveToIndexPath toIndexPath: NSIndexPath)
optional func collectionView(collectionView: UICollectionView, atIndexPath: NSIndexPath, didMoveToIndexPath toIndexPath: NSIndexPath)

optional func collectionView(collectionView: UICollectionView, allowMoveAtIndexPath indexPath: NSIndexPath) -> Bool
optional func collectionView(collectionView: UICollectionView, atIndexPath: NSIndexPath, canMoveToIndexPath: NSIndexPath) -> Bool

optional func collectionView(collectionView: UICollectionView, collectionViewLayout layout: RAReorderableLayout, willBeginDraggingItemAtIndexPath indexPath: NSIndexPath)
optional func collectionView(collectionView: UICollectionView, collectionViewLayout layout: RAReorderableLayout, didBeginDraggingItemAtIndexPath indexPath: NSIndexPath)
optional func collectionView(collectionView: UICollectionView, collectionViewLayout layout: RAReorderableLayout, willEndDraggingItemToIndexPath indexPath: NSIndexPath)
optional func collectionView(collectionView: UICollectionView, collectionViewLayout layout: RAReorderableLayout, didEndDraggingItemToIndexPath indexPath: NSIndexPath)
```

Datasource
```
optional func collectionView(collectionView: UICollectionView, reorderingItemAlphaInSection section: Int) -> CGFloat
optional func scrollTrigerEdgeInsetsInCollectionView(collectionView: UICollectionView) -> UIEdgeInsets
optional func scrollTrigerPaddingInCollectionView(collectionView: UICollectionView) -> UIEdgeInsets
optional func scrollSpeedValueInCollectionView(collectionView: UICollectionView) -> CGFloat
```


## Property
```
var trigerInsets: UIEdgeInsets = UIEdgeInsetsMake(100.0, 100.0, 100.0, 100.0)
var trigerPadding: UIEdgeInsets = UIEdgeInsetsZero
var scrollSpeedValue: CGFloat = 10.0
```


## License
RAReorderableLayout is available under the MIT license. See the LICENSE file for more info.
