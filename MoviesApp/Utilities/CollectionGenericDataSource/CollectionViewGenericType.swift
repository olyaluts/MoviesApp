//
//  CollectionViewGenericType.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import UIKit

protocol GenericCollectionViewType: AnyObject {
    associatedtype ViewModel: GenericCollectionViewModel
    func configure(with viewModel: ViewModel)
}

class GenericCollectionReusableViewImpl<T: GenericCollectionViewModel>: UICollectionReusableView, GenericCollectionViewType {
    typealias ViewModel = T

    private(set) var viewModel: T?

    func configure(with viewModel: T) {
        self.viewModel = viewModel
        configureView()
    }

    func configureView() {}
}

class GenericCollectionViewCellImpl<T: GenericCollectionViewModel>: UICollectionViewCell, GenericCollectionViewType {
    typealias ViewModel = T

    private(set) var viewModel: T?

    func configure(with viewModel: T) {
        self.viewModel = viewModel
        configureView()
    }

    func configureView() {}
}

protocol GenericCollectionViewModel {
    var id: String { get }
}

extension GenericCollectionViewModel {
    var id: String {
        UUID().uuidString
    }
}

extension String: GenericCollectionViewModel {
    var id: String {
        self
    }
}

