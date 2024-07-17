//
//  MoviesCoorinator.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import UIKit
import Inject

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
        let context = MovieViewModelImpl.ServiceContext(service: MovieService(networkClient: NetworkClient()),
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
