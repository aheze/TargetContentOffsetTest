//
//  ViewController.swift
//  TargetContentOffsetTest
//
//  Created by Zheng on 11/16/21.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource {
    let colors: [UIColor] = [.red, .green, .blue]
    lazy var collectionView: UICollectionView = {
        let flowLayout = PagingFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.decelerationRate = .fast
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = collectionView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return 3 }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.contentView.backgroundColor = colors[indexPath.item]
        return cell
    }
}


class PagingFlowLayout: UICollectionViewFlowLayout {
    
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    /// actual content offset used by `prepare`
    var currentOffset = CGFloat(0)
    
    var contentSize = CGSize.zero /// the scrollable content size of the collection view
    override var collectionViewContentSize: CGSize { return contentSize } /// pass scrollable content size back to the collection view
    
    /// pass attributes to the collection view flow layout
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributes.filter { rect.intersects($0.frame) }
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        let cellWidth = collectionView.bounds.width
        let cellHeight = collectionView.bounds.height
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        var currentOrigin = CGFloat(0)
        
        for index in 0..<3 {
            let attribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            attribute.frame = CGRect(x: currentOrigin, y: 0, width: cellWidth, height: cellHeight)
            layoutAttributes.append(attribute)
            currentOrigin += cellWidth
        }
        
        self.contentSize = CGSize(width: currentOrigin, height: cellHeight)
        self.layoutAttributes = layoutAttributes
        currentOffset = collectionView.contentOffset.x
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let contentOffset = collectionView?.contentOffset.x ?? 0
        let closestPoint = layoutAttributes.min {
            abs($0.frame.origin.x - contentOffset) < abs($1.frame.origin.x - contentOffset)
        }
        return closestPoint?.frame.origin ?? proposedContentOffset
    }
}

