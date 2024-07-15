//
//  CellProviderContext.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import UIKit

protocol CellProviderContext {
    var id: ArchitectorCellProviderID { get set }
    var cellIdentifier: String { get }
    var didSelectHandler: (() -> Void)? { get set }
    var willDisplayHandler: ((UICollectionViewCell) -> Void)? { get set }
    var didEndDisplayHandlerForSection: ((Int) -> Void)? { get set }
    func registerCell(in collectionView: UICollectionView)
    func dequeueAndConfigure(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell
    func update()
}

final class CellProviderContextImpl<Cell: UICollectionViewCell>: CellProviderContext where Cell: GenericCollectionViewType {
    typealias ViewModel = Cell.ViewModel

    var id: ArchitectorCellProviderID
    var didSelectHandler: (() -> Void)?
    var willDisplayHandler: ((UICollectionViewCell) -> Void)?
    var didEndDisplayHandlerForSection: ((Int) -> Void)?
    var cellIdentifier: String {
        String(describing: Cell.self)
    }

    // MARK: Private properties

    private let cellModel: ViewModel

    // MARK: Init

    init(cellModel: ViewModel) {
        id = cellModel.id
        self.cellModel = cellModel
    }

    // MARK: Internal methods

    func registerCell(in collectionView: UICollectionView) {
        collectionView.register(Cell.self, forCellWithReuseIdentifier: cellIdentifier)
    }

    func dequeueAndConfigure(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        guard let genericCell = cell as? Cell else {
            return UICollectionViewCell()
        }
        genericCell.configure(with: cellModel)
        return cell
    }

    func update() {
        id = UUID().uuidString
    }
}
