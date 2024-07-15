//
//  LoadingView.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import UIKit

final class LoadingView: UIView {
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    private var isAnimating = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupActivityIndicator()
    }
    
    func beginAnimating() {
        guard !isAnimating else { return }
        
        alpha = 0.0
        isHidden = false
        activityIndicator.startAnimating()
        isAnimating = true
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: nil)
    }
    
    func stopAnimating(completion: (() -> Void)?) {
        guard isAnimating else {
            if let completion = completion { completion() }
            return
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: { _ in
            self.isHidden = true
            self.activityIndicator.stopAnimating()
            self.isAnimating = false
            
            if let completion = completion { completion() }
        })
    }
    
    private func setup() {
        backgroundColor = .white
    }
    
    private func setupActivityIndicator() {
        addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

