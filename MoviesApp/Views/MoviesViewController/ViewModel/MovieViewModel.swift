//
//  MovieViewModel.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import Combine

typealias BoolPublisher = AnyPublisher<Bool, Never>
typealias VoidPublisher = AnyPublisher<Void, Never>
typealias StringPublisher = AnyPublisher<String, Never>

enum MovieCellModelType {
    case Movie([MoviewCellModel])
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
    
    let navigationTitle: String = "Popular Movies"
    
    let isLoadingPublisher: BoolPublisher
    private let loadingSubject: PassthroughSubject<Bool, Never>
    
    let startPageNumber: Int = 1
    var pageNumber: Int = 1
    
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
        
        func loadMovies(searchString: String, pageNumber: Int) -> AnyPublisher<[Movie]?, Never> {
            context.service.searchMovies(searchString: searchString,
                                         pageNumber: pageNumber)
            .replaceError(with: nil,
                          errorHandler: errorHandler)
            .eraseToAnyPublisher()
        }
        
        func map(movies: [Movie]) -> [MovieCellModelType] {
            context.builder.set(movies: movies)
            return context.builder.build()
        }
        
        let loadingStartedPublisher = input.searchString
            .filter { !$0.isEmpty }
            .handleEvents(receiveOutput: { _ in self.loadingSubject.send(true) })
            .flatMap { [weak self] searchString -> AnyPublisher<[Movie]?, Never> in
                self?.pageNumber = self?.startPageNumber ?? 1
                return loadMovies(searchString: searchString, pageNumber: self?.startPageNumber ?? 1)
            }
        
        var loadMoreIsLoading = false
        let loadMorePublisher = input.loadMore
            .filter { !loadMoreIsLoading }
            .flatMap { [weak self] _ -> AnyPublisher<[Movie]?, Never> in
                loadMoreIsLoading = true
                return loadMovies(searchString: "", pageNumber: self?.pageNumber ?? 1)
            }
        
        let reloadPublisher = input.reload
                .combineLatest(input.searchString)
                .handleEvents(receiveOutput: { _ in
                    self.pageNumber = self.startPageNumber
                    self.loadingSubject.send(true)
                })
                .flatMap { (_, searchString) in
                    loadMovies(searchString: searchString, pageNumber: self.startPageNumber)
                }
                .eraseToAnyPublisher()
            
    let itemsPublisher = Publishers.Merge3(loadingStartedPublisher, loadMorePublisher, reloadPublisher)
                .map { result -> [Movie]? in
                    guard let result = result else { return nil }
                    return result
                }
                .eraseToAnyPublisher()
        
        return itemsPublisher
            .map { data -> [MovieCellModelType] in
                self.pageNumber += 1
                return map(movies: data ?? [])
            }
            .handleEvents(receiveOutput: { _ in
                loadMoreIsLoading = false
                self.loadingSubject.send(false)
            })
            .eraseToAnyPublisher()
    }
}
