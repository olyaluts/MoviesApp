//
//  LoadingPresentable.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import UIKit

protocol LoadingPresentable: LoadingProtocol {
    var topLoadingAnchor: NSLayoutYAxisAnchor { get }
    var bottomLoadingAnchor: NSLayoutYAxisAnchor { get }
    var leadingLoadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingLoadingAnchor: NSLayoutXAxisAnchor { get }
    func showLoading()
    func hideLoading()
}

extension LoadingPresentable where Self: UIViewController {
    var topLoadingAnchor: NSLayoutYAxisAnchor { view.topAnchor }
    var bottomLoadingAnchor: NSLayoutYAxisAnchor { view.bottomAnchor }
    var leadingLoadingAnchor: NSLayoutXAxisAnchor { view.leadingAnchor }
    var trailingLoadingAnchor: NSLayoutXAxisAnchor { view.trailingAnchor }

    func showLoading() {
        guard getLoadingView() == nil else { return }
        let loadingView = LoadingView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: topLoadingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: bottomLoadingAnchor),
            loadingView.leadingAnchor.constraint(equalTo: leadingLoadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: trailingLoadingAnchor),
        ])
        loadingView.beginAnimating()
    }

    func hideLoading() {
        guard let loadingView = getLoadingView() else { return }
        loadingView.stopAnimating(completion: {
        })
        loadingView.removeFromSuperview()
    }

    private func getLoadingView() -> LoadingView? {
        for view in view.subviews {
            guard let view = view as? LoadingView else { continue }
            return view
        }
        return nil
    }
}
