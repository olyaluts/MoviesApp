//
//  ReusableProviderContext.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import UIKit

protocol ReusableViewProviderContext {
    var reuseIdentifier: String { get }
    var kind: String { get }

    func registerReusableView(in collectionView: UICollectionView)
    func dequeueAndConfigure(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionReusableView?
}

final class ReusableViewProviderContextImpl<View: UICollectionReusableView>: ReusableViewProviderContext where View: GenericCollectionViewType {
    typealias ViewModel = View.ViewModel

    let kind: String
    var reuseIdentifier: String {
        String(describing: View.self)
    }

    // MARK: Private properties

    private let viewModel: ViewModel

    // MARK: Init

    init(viewModel: ViewModel, kind: String) {
        self.viewModel = viewModel
        self.kind = kind
    }

    // MARK: Internal methods

    func registerReusableView(in collectionView: UICollectionView) {
        collectionView.register(
            View.self,
            forSupplementaryViewOfKind: kind,
            withReuseIdentifier: reuseIdentifier
        )
    }

    func dequeueAndConfigure(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionReusableView? {
        let reusableView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        )
        guard let reusableView = reusableView as? View else {
            return nil
        }
        reusableView.configure(with: viewModel)
        return reusableView
    }
}
