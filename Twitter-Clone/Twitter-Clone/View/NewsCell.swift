//
//  NewsCell.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 7/24/24.
//

import UIKit

protocol NewsCellDelegate: class {
    
}

class NewsCell: UITableViewCell {
    // MARK: - Properties
    var news: News? {
        didSet {
            configure()
        }
    }
    
    weak var delegate: NewsCellDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 0
        return label
    }()
    
    private let newsImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.setDimensions(width: .greatestFiniteMagnitude, height: 200)
        iv.layer.cornerRadius = 10
        iv.backgroundColor = .twitterBlue
        return iv
    }()
    
    private let customTextView = CustomTextView()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(newsImageView)
        newsImageView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 30, paddingLeft: 30, paddingRight: 30)
        
        let labelStack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 10
        
        addSubview(labelStack)
        labelStack.anchor(top: newsImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 30, paddingLeft: 30, paddingRight: 30)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    // MARK: - API
    
    // MARK: - Helpers
    func configure() {
        guard let news = news else { return }
        let viewModel = NewsViewModel(news: news)
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        newsImageView.sd_setImage(with: viewModel.urlToImage)
    }
}
