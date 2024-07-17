//
//  String.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 17.07.2024.
//

import Foundation

extension String {
    func localized(comment: String? = nil) -> String {
        let _comment = comment != nil ? comment! : self
        return NSLocalizedString(self, comment: _comment)
    }
}
