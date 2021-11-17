//
//  ViewController.swift
//  TargetContentOffsetTest
//
//  Created by Zheng on 11/16/21.
//

import UIKit

class PagingFlowLayout: UICollectionViewFlowLayout {
    var layoutAttributes = [UICollectionViewLayoutAttributes]() /// custom attributes
    var contentSize = CGSize.zero /// the scrollable content size of the collection view
    override var collectionViewContentSize: CGSize { return contentSize } /// pass scrollable content size back to the collection view
    
    /// pass attributes to the collection view flow layout
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? { return layoutAttributes[indexPath.item] }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? { return layoutAttributes.filter { rect.intersects($0.frame) } }
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        let cellWidth = collectionView.bounds.width
        let cellHeight = collectionView.bounds.height
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        var currentCellOrigin = CGFloat(0) /// used for each cell's origin
        
        for index in 0..<3 { /// hardcoded, but only for now
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            attributes.frame = CGRect(x: currentCellOrigin, y: 0, width: cellWidth, height: cellHeight)
            layoutAttributes.append(attributes)
            currentCellOrigin += cellWidth
        }
        
        self.contentSize = CGSize(width: currentCellOrigin, height: cellHeight)
        self.layoutAttributes = layoutAttributes
    }
    
    /// center the cell
    /// this is called when the finger lifts, but NOT when the device rotates!
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let contentOffset = collectionView?.contentOffset.x ?? 0
        let closestPoint = layoutAttributes.min { abs($0.frame.origin.x - contentOffset) < abs($1.frame.origin.x - contentOffset) }
        return closestPoint?.frame.origin ?? proposedContentOffset
    }
}

class ViewController: UIViewController, UICollectionViewDataSource {
    
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
    
    let colors: [UIColor] = [.red, .green, .blue]
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return 3 }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.contentView.backgroundColor = colors[indexPath.item]
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = collectionView /// setup
    }
}
