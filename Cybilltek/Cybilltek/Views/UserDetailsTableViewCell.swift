//
//  UserDetailsTableViewCell.swift
//  Cybilltek
//
//  Created by Jervy Umandap on 5/8/24.
//

import UIKit


class UserDetailsTableViewCell: UITableViewCell {
    static let identifier = "UserDetailsTableViewCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.layer.masksToBounds = true
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 0
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let titleLabelWidth = (contentView.width - 50) / 2
        let titleLabelHeight = contentView.height - 10
        titleLabel.frame = CGRect(
            x: 20,
            y: 5,
            width: titleLabelWidth,
            height: titleLabelHeight)
        
        valueLabel.frame = CGRect(
            x: titleLabel.right + 10,
            y: 5,
            width: titleLabelWidth,
            height: titleLabelHeight)
        
//        titleLabel.backgroundColor = .systemBlue
//        valueLabel.backgroundColor = .systemRed
        
    }
    
    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        valueLabel.text = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension UserDetailsTableViewCell {
    
}
