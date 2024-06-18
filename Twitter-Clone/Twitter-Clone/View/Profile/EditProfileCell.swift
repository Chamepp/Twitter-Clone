//
//  EditProfileCell.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 6/15/24.
//

import UIKit

protocol EditProfileCellDelegate: class {
    func updateUserInfo(_ cell: EditProfileCell)
}

class EditProfileCell: UITableViewCell {
    // MARK: - Properties
    var viewModel: EditProfileViewModel? {
        didSet {
            configure()
        }
    }
    
    weak var delegate: EditProfileCellDelegate?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var infoTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "User Data", isSecure: false, textColor: UIColor.twitterBlue)
        tf.addTarget(self, action: #selector(handleUpdateUserInfo), for: .editingDidEnd)
        tf.text = "User Data"
        return tf
    }()
    
    var bioTextView: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Bio", isSecure: false, textColor: UIColor.twitterBlue)
        tf.addTarget(self, action: #selector(handleUpdateUserInfo), for: .editingDidEnd)
        tf.text = "Bio"
        return tf
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        addSubview(titleLabel)
        titleLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        titleLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 16)
        
        addSubview(infoTextField)
        infoTextField.anchor(top: topAnchor, left: titleLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 16, paddingRight: 8)
        
        addSubview(bioTextView)
        bioTextView.anchor(top: topAnchor, left: titleLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 16, paddingRight: 8)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateUserInfo), name: UITextView.textDidEndEditingNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc func handleUpdateUserInfo() {
        delegate?.updateUserInfo(self)
    }
    
    @objc func handleTextInputChange() {
        
    }
    
    // MARK: - API
    
    // MARK: - Helpers
    func configure() {
        guard let viewModel = viewModel else { return }
        
        infoTextField.isHidden = viewModel.shouldHideTextField
        bioTextView.isHidden = viewModel.shouldHideTextView
        
        titleLabel.text = viewModel.titleText
        
        
        infoTextField.text = viewModel.optionValue
        bioTextView.text = viewModel.optionValue
    }
}
