//
//  Pagination.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 22.07.2024.
//

import Foundation

final class Pagination {
    var currentPage: Int
    var totalPages: Int
    var itemsPerPage: Int
    var totalItems: Int
    
    init(currentPage: Int = 1, itemsPerPage: Int, totalItems: Int) {
        self.currentPage = currentPage
        self.itemsPerPage = itemsPerPage
        self.totalItems = totalItems
        self.totalPages = (totalItems + itemsPerPage - 1) / itemsPerPage
    }
    
    var isFirstPage: Bool {
        return currentPage == 1
    }
    
    var isLastPage: Bool {
        return currentPage == totalPages
    }
    
    var hasNextPage: Bool {
        return currentPage < totalPages
    }
    
    var hasPreviousPage: Bool {
        return currentPage > 1
    }
    
    func goToFirstPage() {
        currentPage = 1
    }
    
    func goToLastPage() {
        currentPage = totalPages
    }
    
    func goToNextPage() {
        if hasNextPage {
            currentPage += 1
        }
    }
    
    func goToPreviousPage() {
        if hasPreviousPage {
            currentPage -= 1
        }
    }
    
    func setPage(_ page: Int) {
        if page >= 1 && page <= totalPages {
            currentPage = page
        }
    }
}
