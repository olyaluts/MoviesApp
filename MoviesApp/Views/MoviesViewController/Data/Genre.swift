//
//  Genre.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 22.07.2024.
//

import Foundation

struct Genre: Decodable {
    let id: Int
    let name: String
}

struct GenresResponse: Decodable {
    let genres: [Genre]
}
