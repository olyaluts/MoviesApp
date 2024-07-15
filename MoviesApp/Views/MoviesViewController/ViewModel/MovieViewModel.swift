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
                              loadMore: VoidPublisher)) -> AnyPublisher<[MovieCellModelType], Never>
//    func cellModels(_ input: (loaded: BoolPublisher,
//                              loadMore: VoidPublisher)) -> AnyPublisher<[MovieCellModelType], Never>
}

final class MovieViewModelImpl: MovieViewModel {
    struct Handlers {
        let openDetails: (String) -> Void
    }
    
    struct ServiceContext {
        let service: MovieService
        let builder: MoviesBuilder
    }

    let navigationTitle: String = ""
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
                                  loadMore: VoidPublisher)) -> AnyPublisher<[MovieCellModelType], Never> {

            func loadMovies(searchString: String, pageNumber: Int) -> AnyPublisher<[Movie]?, Never> {
                context.service.searchMovies(searchString: searchString, pageNumber: pageNumber)
                    .replaceError(with: nil)
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

            let itemsPublisher = Publishers.Merge(loadingStartedPublisher, loadMorePublisher)
                .map { result -> [Movie] in
                    guard let result = result else { return [] }
                    return result
                }
                .eraseToAnyPublisher()

            return itemsPublisher
                .map { data -> [MovieCellModelType] in
                    self.pageNumber += 1
                    return map(movies: data)
                }
                .handleEvents(receiveOutput: { _ in
                    loadMoreIsLoading = false
                    self.loadingSubject.send(false)
                })
                .eraseToAnyPublisher()
        }

//    func cellModels(_ input: (loaded: BoolPublisher,
//                              loadMore: VoidPublisher)) -> AnyPublisher<[MovieCellModelType], Never> {
////        var reload = input.reload
//        
//        func loadMovies(searchString: String, pageNumber: Int) -> AnyPublisher<[Movie]?, Never> {
//            context.service.searchMovies(searchString: searchString, pageNumber: pageNumber)
//                .replaceError(with: nil)
//                .eraseToAnyPublisher()
//        }
//
//        func map(movies: [Movie]) -> [MovieCellModelType] {
//            context.builder.set(movies: movies)
//            return context.builder.build()
//        }
//        
//        let loadingStartedPublisher = input.loaded
//            .filter { $0 == true }
////            .merge(with: input.reload.map { true })
//            .handleEvents(receiveOutput: { self.loadingSubject.send($0) })
//            .flatMap { [weak self] _ -> AnyPublisher<[Movie]?, Never> in
//                loadMovies(searchString: "", pageNumber: self?.startPageNumber ?? 0)
//            }
//
//        var loadMoreIsLoading = false
//        let loadMorePublisher = input.loadMore
//            .filter { !loadMoreIsLoading }
//            .flatMap { [weak self] _ -> AnyPublisher<[Movie]?, Never> in
//                loadMoreIsLoading = true
//                return loadMovies(searchString: "", pageNumber: self?.startPageNumber ?? 0)
//            }
//
//        let itemsPublisher = Publishers.Merge(loadingStartedPublisher, loadMorePublisher)
//            .map { result -> [Movie] in
//                guard let result = result
//                else { return ([]) }
//                return (result)
//            }
//            .eraseToAnyPublisher()
//
//        return itemsPublisher
//            .map { data -> [MovieCellModelType] in
//                self.pageNumber = self.pageNumber + 1
//                return map(movies: data)
//            }
//            .handleEvents(receiveOutput: { _ in
//                loadMoreIsLoading = false
//                self.loadingSubject.send(false)
//            })
//            .eraseToAnyPublisher()
//    }
}
