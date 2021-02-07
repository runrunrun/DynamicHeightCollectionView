//
//  CustomFlowLayout.swift
//  DynamicHeightCollectionView
//
//  Created by Kunwar, Hari on 1/30/21.
//

import UIKit

final class CustomFlowLayout: UICollectionViewFlowLayout {
    private let numberOfColumns: Int
    private let cellPadding: CGFloat = 10

    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }

        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    private var cellWidth: CGFloat {
        return contentWidth/CGFloat(numberOfColumns) - minimumInteritemSpacing
    }

    init(numberOfColumns: Int) {
        self.numberOfColumns = numberOfColumns
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)?.map{ $0.copy() } as? [UICollectionViewLayoutAttributes]
        attributes?.forEach({ layoutAttributes in
            if layoutAttributes.representedElementCategory == .cell {
                if let newFrame = layoutAttributesForItem(at: layoutAttributes.indexPath)?.frame {
                    layoutAttributes.frame = newFrame
                }
            }
        })

        // Vertically Align Attributes
        attributes?
            .reduce([CGFloat: (CGFloat, [UICollectionViewLayoutAttributes])]()) {
                guard $1.representedElementCategory == .cell else { return $0 }
                return $0.merging([ceil($1.center.y): ($1.frame.origin.y, [$1])]) {
                    ($0.0 < $1.0 ? $0.0 : $1.0, $0.1 + $1.1)
                }
            }
            .values.forEach { minY, line in
                line.forEach {
                    $0.frame = $0.frame.offsetBy(
                        dx: 0,
                        dy: minY - $0.frame.origin.y
                    )
                }
            }

        return attributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else {
            fatalError()
        }

        guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
            return nil
        }

        // 0, 1, 2, 3, 4, 5, 6, 7, 8
        let currentColumn = indexPath.row%numberOfColumns

        let x = sectionInset.left + cellWidth*CGFloat(currentColumn) + CGFloat(currentColumn)*minimumInteritemSpacing

        layoutAttributes.frame.origin.x = x
        layoutAttributes.frame.size.width = cellWidth
        return layoutAttributes
    }
}
