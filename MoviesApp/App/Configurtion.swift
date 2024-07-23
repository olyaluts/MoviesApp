//
//  Configurtion.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 18.07.2024.
//

import Foundation

enum EnvironmentType {
    case development
    case staging
    case production
}

final class Configuration {
    public lazy var typeEnvironment: EnvironmentType = {
        #if DEVELOPMENT
            return .development
        #elseif STAGING
            return .staging
        #else
            return .production
        #endif
    }()

    public lazy var baseURL: String = {
        switch typeEnvironment {
        case .development:
            return "developmentURL"
        case .staging:
            return "stagingURL"
        case .production:
            return "https://api.themoviedb.org/3"
        }
    }()
}
