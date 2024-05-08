//
//  HomeViewController.swift
//  Cybilltek
//
//  Created by Jervy Umandap on 5/8/24.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        return tableView
    }()
    
    private var users = [User]()
    private var viewModels = [UserTableViewCellViewModel]()
    
    private var userViewModel = UserViewModel()
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        title = "Random Users"
        
//        tableView.delegate = self
//        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .label
        
        view.addSubview(tableView)
//        fetchUsers()
        userViewModel.fetchUsers()
        tableViewBindings()
    }
    
    private func fetchUsers() {
        APICaller.shared.getUsers { [weak self] result in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                
                switch result {
                case .success(let model):
                    strongSelf.users = model
                    strongSelf.viewModels = model.compactMap({
                        UserTableViewCellViewModel(
                            imageURL: URL(string: $0.picture.large),
                            name: "\($0.name.first) \($0.name.last)",
                            country: $0.location.country,
                            email: $0.email,
                            phone: $0.phone)
                    })
                    strongSelf.tableView.reloadData()
                case .failure(let error):
                    print("fetchUsers: \(error.localizedDescription)")
                    break
                }
            }
        }
    }
    
    func tableViewBindings() {
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        userViewModel.users.bind(to: tableView.rx.items(cellIdentifier: UserTableViewCell.identifier, cellType: UserTableViewCell.self)) { (row, item, cell) in
            
            cell.configure(withViewModel: UserTableViewCellViewModel(
                imageURL: URL(string: item.picture.large),
                name: item.name.first,
                country: "\(item.name.first) \(item.name.last)",
                email: item.email,
                phone: item.phone))
            
        }.disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        let viewModel = viewModels[indexPath.row]
        cell.configure(withViewModel: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

