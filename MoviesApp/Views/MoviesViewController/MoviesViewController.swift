//
//  MoviesViewController.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import UIKit
import Combine

final class MoviesViewController: UIViewController, UISearchBarDelegate, LoadingPresentable {
    private var viewModel: MovieViewModelImpl!
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
       
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 72.0, right: 0)
    

        return collectionView
    }()
    
    private var searchBar: UISearchBar = {
        let searchbar = UISearchBar(frame: .zero)
        searchbar.translatesAutoresizingMaskIntoConstraints = false
        return searchbar
    }()

    private var cancellables: Set<AnyCancellable> = []
    @Published private var isLoaded: Bool = false
    @Published private var searchText: String = ""
    private let loadMore = PassthroughSubject<Void, Never>()
    
    private lazy var collectionViewArchitector = CollectionViewArchitectorImpl(collectionView: self.collectionView)
    private lazy var dataSource = MoviesArchitectorDataSource(architector: self.collectionViewArchitector)
    
    // MARK: - Init

    init(with viewModel: MovieViewModelImpl) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionViewArchitector.dataSource = dataSource
        setupView()
        setupBindings()
        isLoaded = true
    }
    
    // MARK: - View helpers

    private func setupView() {
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        collectionView.collectionViewLayout = dataSource.collectionViewLayout
        searchBar.delegate = self
        view.backgroundColor = .white
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchText = searchBar.text ?? ""
    }

    private func setupBindings() {
        let input = (
            searchString: $searchText.eraseToAnyPublisher(),
            loadMore: loadMore.eraseToAnyPublisher()
        )
        
        viewModel.cellModels(input)
            .drive(subscriber: dataSource.dataSubscriber)
            .store(in: &cancellables)
        
        viewModel.errorPublisher
            .sink { _ in
              
            }
            .store(in: &cancellables)
    }
}
