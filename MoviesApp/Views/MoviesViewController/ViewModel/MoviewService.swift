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
    
    func searchMovies(searchString: String, pageNumber: Int) -> AnyPublisher<[Movie]?, Error> {
        Future<[Movie]?, Error> { [weak self] promise in
            guard let self = self else { return }
            let url = "\(baseUrl)/search/movie"
            let parameters = ["query": searchString,
                              "page": pageNumber]
            self.networkClient.request(
                url, 
                method: .get,
                parameters: parameters)
            { (result: Result<MoviesResponse, Error>) in
                switch result {
                case .success(let moviesResponse):
                    promise(.success(moviesResponse.results))
                    
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}
