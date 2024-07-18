//
//  MoviesBuilder.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
typealias IntHandler = (Int) -> Void

protocol MoviesBuilder {
    func set(movieTap: @escaping (String) -> Void)
    func set(movies: [Movie])
    func build() -> [MovieCellModelType]
}

final class MoviesBuilderImpl: MoviesBuilder {
    private var movies: [Movie]?
    private var movieTap: ((String) -> Void)?
    private var sections: [MovieCellModelType] = []
    
    func set(movies: [Movie]) {
        self.movies = movies
    }
    func set(movieTap: @escaping (String) -> Void) {
        self.movieTap = movieTap
    }
    
    func build() -> [MovieCellModelType] {
        guard let movies = movies else { return [] }
        var types: [MovieCellModelType] = []
        var moviesModels: [MoviewCellModel] = []
        movies.forEach { movie in
            let cellModel = MoviewCellModel(movie: movie)
            cellModel.tapHandler = { [weak self] in
//                self?.movieTap?(movie.id ?? "")
            }
            moviesModels.append(cellModel)
        }
        types.append(MovieCellModelType.movie(moviesModels))
        sections = types
        
        return types
    }
}
