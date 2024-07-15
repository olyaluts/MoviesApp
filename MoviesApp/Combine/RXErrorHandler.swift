//
//  RXErrorHandler.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import Combine

final class RXErrorHandler {
    let errorSubject = PassthroughSubject<Error, Never>()
    lazy var errorPublisher: AnyPublisher<Error, Never> = {
        errorSubject.eraseToAnyPublisher()
    }()
}

