//
//  CollectionViewArchitectorDataSource.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import UIKit

protocol CollectionViewArchitectorDataSource: AnyObject {
    var sections: [CollectionViewSection] { get }
    var emptyView: UIView? { get }
    var collectionViewLayout: UICollectionViewLayout { get }
}

extension CollectionViewArchitectorDataSource {
    func sectionFor(index: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        sections[index].layoutSectionProvider(index, environment)
    }
}
