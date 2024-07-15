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
    private let baseUrl = "https://api.themoviedb.org/3/movie"
    
    init(networkClient: NetworkProtocol = NetworkClient.shared) {
        self.networkClient = networkClient
    }
    func searchMovies(searchString: String, pageNumber: Int) -> AnyPublisher<[Movie]?, Error> {
        Future<[Movie]?, Error> { [weak self] promise in
            guard let self = self else { return }
            let url = "\(baseUrl)/popular"
            self.networkClient.request(url, method: .get, parameters: nil, headers: nil) { (result: Result<MoviesResponse, Error>) in
                switch result {
                case .success(let moviesResponse):
                    promise(.success(moviesResponse.results))
                    
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    
//https://api.themoviedb.org/3/search/movie
//https://api.themoviedb.org/3/movie/{movie_id}/images
}
