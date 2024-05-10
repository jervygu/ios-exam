//
//  HomeViewController.swift
//  Cybilltek
//
//  Created by Jervy Umandap on 5/8/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
    
    private var userEntity = [User_Entity]()
    
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
        
        getSavedUsers()
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
        loadingIndicator.center = view.center
        loadingIndicator.frame = view.bounds
        
    }
    
    private func saveFetchedUsers(fetchedUsers: [User]) {
        
        context.perform { [weak self] in
            guard let strongSelf = self else { return }
            
            fetchedUsers.forEach { user in
                let userToSave = User_Entity(context: strongSelf.context)
                
                userToSave.user_dob = user.dob.date
                userToSave.user_age = Int64(user.dob.age)
                
                userToSave.user_email = user.email
                userToSave.user_gender = user.gender
                userToSave.user_location = user.location.fullAddress
                
                userToSave.user_title = user.name.title
                userToSave.user_first_name = user.name.first
                userToSave.user_last_name = user.name.last
                
                userToSave.user_phone = user.phone
                userToSave.user_picture = user.picture.large
            }
            
            do {
                try strongSelf.context.save()
            } catch {
                print("Failed to save users: \(error.localizedDescription)")
            }
            
        }
    }
    
    private func clearSavedUsers() {
        do {
            let usersToRemove = try context.fetch(User_Entity.fetchRequest())
            usersToRemove.forEach { user in
                context.delete(user)
            }
            try context.save()
        } catch {
            print("Failed to clear saved Users: \(error.localizedDescription)")
        }
    }
    
    private func getSavedUsers()  {
        do {
            let savedUsers = try context.fetch(User_Entity.fetchRequest())
            print("savedUsers \(savedUsers)")
            print("savedUsers Count \(savedUsers.count)")
        } catch {
            print("Failed to get saved users: \(error.localizedDescription)")
        }
    }
    
    private func useSavedUsers() -> [User] {
        var users = [User]()
        do {
            let savedUsers = try context.fetch(User_Entity.fetchRequest())
            users = savedUsers.map { user in
                User(id: ID(name: user.id.debugDescription, value: ""),
                     gender: user.user_gender ?? "-",
                     name: Name(title: user.user_title ?? "-",
                                first: user.user_first_name ?? "-",
                                last: user.user_last_name ?? "-"),
                     location: Location(street: Street(number: 0, name: ""),
                                        city: user.user_location ?? "-",
                                        state: "",
                                        country: ""),
                     email: user.user_email ?? "-",
                     dob: Dob(date: user.user_dob ?? "-", age: Int(user.user_age)),
                     phone: user.user_phone ?? "-",
                     picture: Picture(large: user.user_picture ?? "-"),
                     nat: "")
            }
            
            print("savedUsers \(savedUsers)")
            print("savedUsers Count \(savedUsers.count)")
        } catch {
            print("Failed to get saved users: \(error.localizedDescription)")
        }
        
        return users
    }
    
    private func fetchUsers() {
        if tableView.refreshControl?.isRefreshing == true {
            print("refreshing history...page: ", self.page)
        } else {
            print("fetching history..page: ", self.page)
        }
        
        APICaller.shared.getUsers(pagination: false, page: page) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let data):
                APICaller.shared.isPaginating = false
                strongSelf.clearFetchedUsers()
                
                let sortedData = data.sorted(by: { $0.name.last < $1.name.last })
                
                strongSelf.users = sortedData
                
                
                // save fetched users
                strongSelf.saveFetchedUsers(fetchedUsers: sortedData)
                
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
                let dismiss = UIAlertAction(title: "Dismiss", style: .default) { action in
                    
                    strongSelf.users = strongSelf.useSavedUsers().sorted(by: { $0.phone < $1.phone })
                    DispatchQueue.main.async {
                        strongSelf.tableView.refreshControl?.endRefreshing()
                        strongSelf.loadingIndicator.stopAnimating()
                        strongSelf.loadingIndicator.isHidden = true
                        strongSelf.tableView.isHidden = false
                        strongSelf.tableView.reloadData()
                    }
                }
                alert.addAction(dismiss)
                DispatchQueue.main.async {
                    strongSelf.present(alert, animated: true)
                }
                break
            }
        }
    }
    
    private func clearFetchedUsers() {
        users.removeAll()
        clearSavedUsers()
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
        page = 1
        fetchUsers()
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        let user = users[indexPath.row]
        cell.configure(with: user)
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
                    let sortedData = data.sorted(by: { $0.name.last < $1.name.last })
                    
                    strongSelf.users.append(contentsOf: data)
                    // save more users
                    strongSelf.saveFetchedUsers(fetchedUsers: sortedData)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        strongSelf.tableView.reloadData()
                    }
                    
                case .failure(let error):
                    print("Load more: \(error.localizedDescription)")
                    let alert = UIAlertController(
                        title: "Fetch user failed",
                        message: error.localizedDescription,
                        preferredStyle: .alert)
                    let dismiss = UIAlertAction(title: "Dismiss", style: .default) { action in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            strongSelf.tableView.tableFooterView = nil
                        }
                    }
                    alert.addAction(dismiss)
                    DispatchQueue.main.async {
                        strongSelf.present(alert, animated: true)
                    }
                    break
                }
            }
        }
        
        print("PAGE: \(page)")
        
        print("Users count \(users.count)")
    }
    
}

