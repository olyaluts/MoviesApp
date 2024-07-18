//
//  MovieViewModel.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import Combine

enum MovieCellModelType {
    case movie([MoviewCellModel])
}

protocol MovieViewModel {
    var isLoadingPublisher: BoolPublisher { get }
    var errorPublisher: AnyPublisher<Error, Never> { get }
    var navigationTitle: String { get }
    func cellModels(_ input: (searchString: StringPublisher,
                              loadMore: VoidPublisher,
                              reload: VoidPublisher)) -> AnyPublisher<[MovieCellModelType], Never>
}

final class MovieViewModelImpl: MovieViewModel {
    struct Handlers {
        let openDetails: (String) -> Void
    }
    
    struct ServiceContext {
        let service: MovieService
        let builder: MoviesBuilder
    }
    
    let navigationTitle: String = "Popular Movies".localized()
    
    let isLoadingPublisher: BoolPublisher
    private let loadingSubject: PassthroughSubject<Bool, Never>
    
    private let startPageNumber: Int = 1
    private var pageNumber: Int = 1
    private var currentMovies = CurrentValueSubject<[Movie], Never>([])
    
    private let errorHandler = RXErrorHandler()
    var errorPublisher: AnyPublisher<Error, Never> { errorHandler.errorPublisher }
    
    private let context: ServiceContext
    
    init(context: ServiceContext, handlers: Handlers) {
        self.context = context
        context.builder.set(movieTap: handlers.openDetails)
        
        loadingSubject = PassthroughSubject<Bool, Never>()
        isLoadingPublisher = loadingSubject.eraseToAnyPublisher()
    }
    
    func cellModels(_ input: (searchString: StringPublisher,
                              loadMore: VoidPublisher,
                              reload: VoidPublisher)) -> AnyPublisher<[MovieCellModelType], Never> {
        
        func loadMovies(searchString: String, pageNumber: Int) -> AnyPublisher<[Movie], Never> {
            context.service.searchMovies(searchString: searchString, pageNumber: pageNumber)
                .replaceError(with: [])
                .compactMap { $0 }
                .eraseToAnyPublisher()
        }
        
        func map(movies: [Movie]) -> [MovieCellModelType] {
            context.builder.set(movies: movies)
            return context.builder.build()
        }
        
        let loadingStartedPublisher = input.searchString
            .filter { !$0.isEmpty }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.pageNumber = self?.startPageNumber ?? 1
                self?.loadingSubject.send(true)
                self?.currentMovies.send([])
            })
            .flatMap { [weak self] searchString -> AnyPublisher<[Movie], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                return loadMovies(searchString: searchString, pageNumber: self.startPageNumber)
                    .handleEvents(receiveOutput: { newMovies in
                        self.currentMovies.send(newMovies)
                    })
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        var loadMoreIsLoading = false
        let loadMorePublisher = input.loadMore
            .filter { !loadMoreIsLoading }
            .combineLatest(input.searchString)
            .handleEvents(receiveOutput: { _ in
                loadMoreIsLoading = true
                self.loadingSubject.send(true)
            })
            .flatMap { [weak self] (_, searchString) -> AnyPublisher<[Movie], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                return loadMovies(searchString: searchString, pageNumber: self.pageNumber)
                    .handleEvents(receiveOutput: { newMovies in
                        self.currentMovies.send(self.currentMovies.value + newMovies)
                        self.pageNumber += 1
                        self.loadingSubject.send(false)
                        loadMoreIsLoading = false
                    })
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        let reloadPublisher = input.reload
            .combineLatest(input.searchString)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.pageNumber = self?.startPageNumber ?? 1
                self?.loadingSubject.send(true)
                self?.currentMovies.send([])
            })
            .flatMap { (_, searchString) -> AnyPublisher<[Movie], Never> in
                loadMovies(searchString: searchString, pageNumber: self.startPageNumber)
                    .handleEvents(receiveOutput: { newMovies in
                        self.currentMovies.send(newMovies)
                    })
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        let itemsPublisher = Publishers.Merge3(loadingStartedPublisher, loadMorePublisher, reloadPublisher)
            .eraseToAnyPublisher()
        
        return itemsPublisher
            .map { [weak self] _ in
                guard let self = self else { return [] }
                return map(movies: self.currentMovies.value)
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.loadingSubject.send(false)
            })
            .eraseToAnyPublisher()
    }
}
