//
//  MoviesViewController.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import UIKit
import Combine

final class MoviesViewController: UIViewController, UISearchBarDelegate, LoadingPresentable, UIScrollViewDelegate, UICollectionViewDelegate {
    private var viewModel: MovieViewModelImpl!
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.refreshControl = refreshControl
        
        return collectionView
    }()
    
    private let searchBar: UISearchBar = {
        let searchbar = UISearchBar(frame: .zero)
        searchbar.translatesAutoresizingMaskIntoConstraints = false
        return searchbar
    }()
    
    private lazy var actionSheet: UIAlertController = {
        let actionSheet = UIAlertController(
            title: viewModel.actionTitle,
            message: nil,
            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(
            title: NSLocalizedString("cancel",
                                     comment: "Cancel"),
            style: .cancel, handler: nil))
        return actionSheet
    }()
    
    private var lastContentOffset: Double = 0.0
    
    private var cancellables: Set<AnyCancellable> = []
    @Published private var isLoaded: Bool = false
    @Published private var searchText: String = ""
    
    private let loadMore = PassthroughSubject<Void, Never>()
    private let reload = PassthroughSubject<Void, Never>()
    private let discover = PassthroughSubject<Void, Never>()
    
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
        navigationItem.title = viewModel.navigationTitle
        searchBar.placeholder = viewModel.placeholder
        
        let genresButton = UIBarButtonItem(
            title: "Genres",
            style: .plain,
            target: self,
            action: #selector(showGenres))
        navigationItem.rightBarButtonItem = genresButton
        
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
        collectionView.delegate = self
        searchBar.delegate = self
        view.backgroundColor = .white
    }
    
    private func setupBindings() {
        let input = (
            searchString: $searchText.eraseToAnyPublisher(),
            loadMore: loadMore.eraseToAnyPublisher(),
            reload: reload.eraseToAnyPublisher(),
            discover: discover.eraseToAnyPublisher()
        )
        
        viewModel.isLoadingPublisher
            .sink { isLoading in
                if !isLoading {
                    self.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        viewModel.cellModels(input)
            .drive(subscriber: dataSource.dataSubscriber)
            .store(in: &cancellables)
        
        viewModel.errorPublisher
            .sink { [weak self] _ in
                self?.showError()
            }
            .store(in: &cancellables)
        
        viewModel.loadGenres(loaded: $isLoaded.eraseToAnyPublisher())
            .sink { [weak self] genres in
                genres.forEach({ genre in
                    self?.actionSheet.addAction(UIAlertAction(
                        title: genre.name,
                        style: .default,
                        handler: { [weak self] _ in
                            self?.viewModel.selectedGenreId = genre.id
                            self?.discover.send(())
                        }))
                })
            }
            .store(in: &cancellables)
    }
    
    private func showError() {
        let alert = UIAlertController(
            title: NSLocalizedString("error", comment: "Error"),
            message: NSLocalizedString("errorMessage", comment: "Oops.. Something went wrong"),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("OK", comment: "OK"),
            style: .default,
            handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Search bar delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchText = searchBar.text ?? ""
    }
    
    // MARK: - Scroll view delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            loadMore.send()
        }
        lastContentOffset = contentYoffset
    }
    
    @objc private func refreshData() {
        refreshControl.beginRefreshing()
        reload.send(())
    }
    
    @objc private func showGenres() {
        present(actionSheet, animated: true, completion: nil)
    }
}
