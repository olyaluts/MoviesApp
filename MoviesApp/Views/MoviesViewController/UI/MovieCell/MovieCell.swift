//
//  MovieCell.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import UIKit
import SDWebImage

final class MovieCell: GenericCollectionViewCellImpl<MoviewCellModel> {
    private let imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleBackgroundView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.alpha = 0.9
        return view
    }()
        
    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let genreLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureView() {
        guard let viewModel = viewModel else { return }
        
        if let urlString = viewModel.image, let url = URL(string: urlString) {
            imageView.sd_setImage(with: url)
        }
        titleLabel.text = viewModel.title
    }
    
    private func setupView() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleBackgroundView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(genreLabel)
        contentView.addSubview(ratingLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            titleBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            titleBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleBackgroundView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.centerYAnchor.constraint(equalTo: titleBackgroundView.centerYAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: titleBackgroundView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: titleBackgroundView.trailingAnchor, constant: -16),

            genreLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            genreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            ratingLabel.centerYAnchor.constraint(equalTo: genreLabel.centerYAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(actionClicked))
        contentView.addGestureRecognizer(tapGestureRecognizer)
        
        titleBackgroundView.layer.cornerRadius = 5
        titleBackgroundView.clipsToBounds = true
    }

    @objc private func actionClicked() {
        viewModel?.tapHandler?()
    }
}
