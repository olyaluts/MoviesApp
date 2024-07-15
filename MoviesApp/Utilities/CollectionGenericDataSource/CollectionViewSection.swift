//
//  CollectionViewSection.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import UIKit

protocol CollectionViewSection: AnyObject {
    typealias LayoutSectionProvider = (Int, NSCollectionLayoutEnvironment) -> (NSCollectionLayoutSection)
    var id: ArchitectorSectionID { get }
    var cellContexts: [CellProviderContext] { get }
    var supplementaryViewContexts: [String: ReusableViewProviderContext] { get }

    var layoutSectionProvider: LayoutSectionProvider { get }

    func append(context: CellProviderContext)
    func append(contexts: [CellProviderContext])
    func resetContexts(_ contexts: [CellProviderContext])
    func removeContext(at index: Int)
    func reloadContext(at index: Int, with context: CellProviderContext)
}

final class CollectionViewSectionImpl: CollectionViewSection {
    let id: String
    var layoutSectionProvider: LayoutSectionProvider = { _, _ in
        let estimatedSize = CGFloat(44.0)
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(estimatedSize)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(estimatedSize)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       repeatingSubitem: item,
                                                       count: 1)
        let section = NSCollectionLayoutSection(group: group)
        return section
    }

    var cellContexts: [CellProviderContext]
    var supplementaryViewContexts: [String: ReusableViewProviderContext]

    // MARK: Init

    // NOTE that section identifier must be uniq for diffable datasource

    init(
        identifier: String,
        contexts: [CellProviderContext],
        supplementaryViewContexts: [ReusableViewProviderContext] = []
    ) {
        id = identifier
        self.supplementaryViewContexts = supplementaryViewContexts
            .reduce(into: [String: ReusableViewProviderContext]()) { dictionary, context in
                dictionary[context.kind] = context
            }
        cellContexts = contexts
    }

    // MARK: Internal methods

    func append(context: CellProviderContext) {
        cellContexts.append(context)
    }

    func append(contexts: [CellProviderContext]) {
        cellContexts.append(contentsOf: contexts)
    }

    func removeContext(at index: Int) {
        cellContexts.remove(at: index)
    }

    func resetContexts(_ contexts: [CellProviderContext]) {
        cellContexts = contexts
    }

    func reloadContext(at index: Int, with context: CellProviderContext) {
        cellContexts[index] = context
    }
}
