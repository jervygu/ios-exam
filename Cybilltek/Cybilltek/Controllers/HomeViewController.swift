//
//  HomeViewController.swift
//  Cybilltek
//
//  Created by Jervy Umandap on 5/8/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        return tableView
    }()
    
    private var users = [User]()
    private var viewModels = [UserTableViewCellViewModel]()
    private var page = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        title = "Random Users"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .label
        
        view.addSubview(tableView)
        fetchUsers()
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh) , for: .valueChanged)
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
    }
    
    private func fetchUsers() {
        users.removeAll()
        
        if tableView.refreshControl?.isRefreshing == true{
            print("refreshing history...page: ", self.page)
        } else {
            print("fetching history..page: ", self.page)
        }
        
        APICaller.shared.getUsers(pagination: false, page: page) { [weak self] result in
            guard let strongSelf = self else { return }
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    strongSelf.tableView.refreshControl?.endRefreshing()
                    strongSelf.tableView.reloadData()
                }
            case .failure(let error):
                print("fetchUsers: \(error.localizedDescription)")
                let alert = UIAlertController(
                    title: "Fetch user failed",
                    message: error.localizedDescription,
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                strongSelf.present(alert, animated: true)
                break
            }
        }
    }
    
    private func createSpinnerFooterView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.width, height: 44))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        spinner.startAnimating()
        footerView.addSubview(spinner)
        return footerView
    }
    
    @objc private func didPullToRefresh() {
        print("refreshing")
        page = 1
        fetchUsers()
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
        let user = users[indexPath.row]
        
        let vc = UserDetailsViewController()
        vc.configure(with: user)
        vc.title = user.getFullName().capitalized
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (tableView.height - scrollView.height + 100) {
            print("Loading more")
            
            guard !APICaller.shared.isPaginating else {
                // we are already fethcing more data
                return
            }
            page += 1
            
            self.tableView.tableFooterView = createSpinnerFooterView()
            
            APICaller.shared.getUsers(pagination: true, page: page) { [weak self] result in
                guard let strongSelf = self else { return }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    strongSelf.tableView.tableFooterView = nil
                }
                
                switch result {
                case .success(let data):
                    strongSelf.users.append(contentsOf: data)
                    _ = data.map { user in
                        strongSelf.viewModels.append(
                            UserTableViewCellViewModel(imageURL: URL(string: user.picture.large),
                                                       name: user.getFullName(),
                                                       country: user.location.country,
                                                       email: user.email,
                                                       phone: user.phone))
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        strongSelf.tableView.reloadData()
                    }
                case .failure(_):
                    break
                }
            }
        }
        
        print("PAGE: \(page)")
        print("USERS: \(users.count)")
    }
    
}

