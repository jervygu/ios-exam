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
        tableView.isHidden = true
        return tableView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .large
        indicator.startAnimating()
        indicator.isHidden = false
        return indicator
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
        view.addSubview(loadingIndicator)
        fetchUsers()
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh) , for: .valueChanged)
        
        tableView.isHidden = users.isEmpty
        loadingIndicator.isHidden = !users.isEmpty
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
        loadingIndicator.center = view.center
        loadingIndicator.frame = view.bounds
        
    }
    
    private func fetchUsers() {
        if tableView.refreshControl?.isRefreshing == true{
            print("refreshing history...page: ", self.page)
        } else {
            print("fetching history..page: ", self.page)
        }
        
        APICaller.shared.getUsers(pagination: false, page: page) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let data):
                strongSelf.clearFetchedUsers()
                
                strongSelf.users = data
                _ = data.map { user in
                    strongSelf.viewModels.append(
                        UserTableViewCellViewModel(imageURL: URL(string: user.picture.large),
                                                   name: user.name.titleFullName.capitalized,
                                                   country: user.location.country,
                                                   email: user.email,
                                                   phone: user.phone))
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    strongSelf.tableView.refreshControl?.endRefreshing()
                    strongSelf.loadingIndicator.stopAnimating()
                    strongSelf.loadingIndicator.isHidden = !strongSelf.users.isEmpty
                    strongSelf.tableView.isHidden = strongSelf.users.isEmpty
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
    
    private func clearFetchedUsers() {
        users.removeAll()
        viewModels.removeAll()
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
        
        print("Users count \(users.count)")
        print("viewModels count \(viewModels.count)")
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
        vc.title = user.name.fullName.capitalized
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height - scrollView.height + 100) {
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
                                                       name: user.name.titleFullName.capitalized,
                                                       country: user.location.country,
                                                       email: user.email,
                                                       phone: user.phone))
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            strongSelf.tableView.reloadData()
                        }
                    }
                case .failure(_):
                    break
                }
            }
        }
        
        print("PAGE: \(page)")
        
        print("Users count \(users.count)")
        print("viewModels count \(viewModels.count)")
    }
    
}

