//
//  Page.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 22.07.2024.
//

import Foundation

struct Page<T: Decodable>: Decodable {
    let page: Int
    let results: [T]
    let totalResults: Int
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalResults = "total_results"
        case totalPages = "total_pages"
    }
}
