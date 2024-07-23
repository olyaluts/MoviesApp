//
//  MoviesArchitectorDataSource.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import Combine
import UIKit

final class MoviesArchitectorDataSource: CollectionViewArchitectorDataSource, RXDataSource {
    private(set) var sections: [CollectionViewSection] = []
    
    lazy var emptyView: UIView? = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private weak var architector: CollectionViewArchitector?
    
    lazy var collectionViewLayout: UICollectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { [weak self] (
            index: Int,
            environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            self?.sectionFor(index: index, environment: environment)
        }
        
        return layout
    }()
    
    init(architector: CollectionViewArchitector) {
        self.architector = architector
    }
    
    func set(data: [MovieCellModelType]) {
        defer { architector?.reload() }
        guard data.count > 0 else { return }
        var sections: [CollectionViewSection] = []
        
        data.forEach { cellModels in
            switch cellModels {
            case let .movie(models):
                let sectionInset: CGFloat = 12
                let itemHeight: CGFloat = 600
                
                let moduleContexts: [CellProviderContext] = models.map { cellModel in
                    let context = CellProviderContextImpl<MovieCell>(cellModel: cellModel)
                    context.didSelectHandler = {}
                    return context
                }
                
                let section = CollectionViewSectionImpl(
                    identifier: "MovieCellContext \(sections.count)",
                    contexts: moduleContexts
                )
                
                section.layoutSectionProvider = { _, _ in
                    let itemLayoutSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(itemHeight)
                    )
                    let item = NSCollectionLayoutItem(layoutSize: itemLayoutSize)
                    let groupLayoutSize = itemLayoutSize
                    let group =  NSCollectionLayoutGroup.horizontal(
                        layoutSize: groupLayoutSize,
                        subitem: item, 
                        count: 1)
                  
                    group.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                    
                    let section = NSCollectionLayoutSection(group: group)
                    section.contentInsets.leading = sectionInset
                    section.contentInsets.trailing = sectionInset
                    section.interGroupSpacing = sectionInset
                    return section
                }
                sections.append(section)
            }
            self.sections = sections
        }
    }
}
