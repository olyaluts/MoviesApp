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
//    let image: String?
    let title: String
    
    var tapHandler: TapHandler?
    
    init(movie: Movie) {
        self.id = movie.id
//        self.image = movie.
        self.title = movie.title
    }
}
