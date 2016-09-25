RAReorderableLayout
=======================

#### A UICollectionView layout which you can move items with drag and drop.


## Screen shots
![screen shot1](https://github.com/ra1028/RAReorderableLayout/raw/master/Assets/screenshot1.png)
![screen shot2](https://github.com/ra1028/RAReorderableLayout/raw/master/Assets/screenshot2.png)


## Animation
![animated gif](https://github.com/ra1028/RAReorderableLayout/raw/master/Assets/animation.gif)

## Requirements
- Swift 3.0 / Xcode 8  
OS X 10.9 or later
iOS 8.0 or later
watchOS 2.0 or later
tvOS 9.0 or later

_Still wanna use swift2.2 or 2.3?_  
-> You can use [0.5.0](https://github.com/ra1028/RAReorderableLayout/tree/0.5.0) instead.

## Installation
__iOS8 or later__  

### CocoaPods
```ruby
# Podfile  
use_frameworks!  

target 'YOUR_TARGET_NAME' do
  pod 'RAReorderableLayout'
end

```
### Carthage
```ruby
 # Cartfile
 github "ra1028/RAReorderableLayout"
```

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

## License
RAReorderableLayout is available under the MIT license. See the LICENSE file for more info.
