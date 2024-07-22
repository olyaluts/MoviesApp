//
//  MoviewService.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import Combine

final class MovieService {
    private let networkClient: NetworkProtocol
    private let baseUrl = App.configuration.baseURL
    
    init(networkClient: NetworkProtocol) {
        self.networkClient = networkClient
    }
    
    // TODO: we should add cache here
    func searchMovies(searchString: String, pageNumber: Int) -> AnyPublisher<Page<Movie>?, Error> {
        Future<Page<Movie>?, Error> { [weak self] promise in
            guard let self = self else { return }
            let url = "\(baseUrl)/search/movie"
            let parameters = ["query": searchString,
                              "page": pageNumber]
            self.networkClient.request(
                url,
                method: .get,
                parameters: parameters)
            { (result: Result<Page<Movie>, Error>) in
                switch result {
                case .success(let page):
                    promise(.success(page))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func loadGenres() -> AnyPublisher<[Genre]?, Error> {
        Future<[Genre]?, Error> { [weak self] promise in
            guard let self = self else { return }
            let url = "\(baseUrl)/genre/movie/list"
            self.networkClient.request(
                url,
                method: .get,
                parameters: nil)
            { (result: Result<[Genre], Error>) in
                switch result {
                case .success(let genres):
                    promise(.success(genres))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}
