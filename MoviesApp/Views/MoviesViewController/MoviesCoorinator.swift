//
//  MoviesCoorinator.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import UIKit
import Inject
import Swinject


// MARK: - Dependency Injection Container

let container = Container { container in
    container.register(NetworkProtocol.self) { _ in
        NetworkClient() as NetworkProtocol
    }
    container.register(MovieService.self) { resolver in
        let networkClient = resolver.resolve(NetworkProtocol.self)!
        return MovieService(networkClient: networkClient)
    }
}

final class MoviesCoorinator {
    var navigationController: UINavigationController

    // MARK: Internal methods

    init(with navigation: UINavigationController) {
        navigationController = navigation
    }

    func start() {
        let landingViewController = createLandingViewController()
        navigationController.pushViewController(landingViewController, animated: true)
    }

    // MARK: Private methods

    private func createLandingViewController() -> UIViewController {
       
        let movieService = container.resolve(MovieService.self)!
               let context = MovieViewModelImpl.ServiceContext(service: movieService,
                                                               builder: MoviesBuilderImpl())
        let handlers = MovieViewModelImpl.Handlers { [weak self] id in
            guard let self = self else {return}
            self.showDetails(id: id)
        }
        

        let viewModel = MovieViewModelImpl(context: context,
                                           handlers: handlers)

        let vc = Inject.ViewControllerHost(MoviesViewController(with: viewModel))
        return vc
    }
    
    private func showDetails(id: String) {
        //TODO: show details
    }
}
