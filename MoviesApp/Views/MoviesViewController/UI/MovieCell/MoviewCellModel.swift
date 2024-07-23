//
//  MoviewCellModel.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
typealias TapHandler = (() -> Void)

final class MoviewCellModel: GenericCollectionViewModel {
    let id: Int?
    let title: String
    let image: String?
    
    var tapHandler: TapHandler?
    
    init(movie: Movie) {
        self.id = movie.id
        self.title = movie.title
        if let imageString = movie.posterPath {
            self.image = App.configuration.posterImg(imageString: imageString)
        } else {
            self.image = nil
        }
    }
}
