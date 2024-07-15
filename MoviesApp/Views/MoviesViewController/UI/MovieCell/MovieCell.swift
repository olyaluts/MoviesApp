//
//  MovieCell.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import UIKit

final class MovieCell: GenericCollectionViewCellImpl<MoviewCellModel> {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var genreLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var ratingLabel: UILabel = {
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
        
//        if let urlString = viewModel.image, let url = URL(string: urlString) {
//            imageView.imageFrom(url: url)
//        }
        
        titleLabel.text = viewModel.title
        
    }
    
    private func setupView() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(genreLabel)
        contentView.addSubview(ratingLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            genreLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            genreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            ratingLabel.centerYAnchor.constraint(equalTo: genreLabel.centerYAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(actionClicked))
        contentView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func actionClicked() {
        viewModel?.tapHandler?()
    }
}
