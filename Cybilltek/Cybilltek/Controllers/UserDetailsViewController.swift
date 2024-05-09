//
//  UserDetailsViewController.swift
//  Cybilltek
//
//  Created by Jervy Umandap on 5/8/24.
//

import UIKit
import Kingfisher

//    Avatar image
//    First name
//    Last name
//    Birthday
//    Age (derived from Birthday)
//    Email address
//    Mobile number
//    Address
//    Contact person
//    Contact person's phone number


class UserDetailsViewController: UIViewController {
    public let tableHeaderView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(UserDetailsTableViewCell.self, forCellReuseIdentifier: UserDetailsTableViewCell.identifier)
        tableView.allowsSelection = false
        return tableView
    }()
    
    var detailsModels = [UserDetailsTableViewCellViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func configure(with user: User) {
        createTableHeaderView(with: user.picture.large)
        createDetails(with: user)
    }
    
    func createDetails(with model: User) {
        detailsModels.append(UserDetailsTableViewCellViewModel(title: "First name", detail: model.name.first))
        detailsModels.append(UserDetailsTableViewCellViewModel(title: "Last name", detail: model.name.last))
        detailsModels.append(UserDetailsTableViewCellViewModel(title: "Birthday", detail: model.dob.date))
        detailsModels.append(UserDetailsTableViewCellViewModel(title: "Age", detail: "\(model.dob.age)"))
        detailsModels.append(UserDetailsTableViewCellViewModel(title: "Email address", detail: model.email))
        detailsModels.append(UserDetailsTableViewCellViewModel(title: "Mobile number", detail: model.cell))
        detailsModels.append(UserDetailsTableViewCellViewModel(title: "Address", detail: model.location.country))
        
    }
    
    
    private func createTableHeaderView(with urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        let headerViewHeight: CGFloat = 250
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: headerViewHeight))
        
        let imageSize: CGFloat = headerView.height - 50
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        
        headerView.addSubview(imageView)
        imageView.center = headerView.center
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageSize / 2
        
        imageView.kf.setImage(with: url)
        tableView.tableHeaderView = headerView
    }

}

extension UserDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailsModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserDetailsTableViewCell.identifier, for: indexPath) as? UserDetailsTableViewCell else {
            return UITableViewCell()
        }
        
        let model = detailsModels[indexPath.row]
        cell.configure(title: model.title, value: model.detail)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
