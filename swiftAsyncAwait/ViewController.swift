//
//  ViewController.swift
//  swiftAsyncAwait
//
//  Created by mac on 22/04/2022.
//

import UIKit

struct User: Codable {
	let name: String
}

class ViewController: UIViewController, UITableViewDataSource {

	let url = URL(string: "https://jsonplaceholder.typicode.com/users")
	
	private var users = [User]()
	
	private let tableview: UITableView = {
		let table = UITableView()
		table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		return table
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(tableview)
		tableview.frame = view.bounds
		tableview.dataSource = self
		
		async {
			let result = await fetchUsers()
			switch result {
				case .success(let users):
					self.users = users
					DispatchQueue.main.async {
						self.tableview.reloadData()
					}
				case .failure(let error):
					print(error)
			}
			
		}
	}
	
	enum Errors: Error {
		case failedToGetUsers
	}
	
	private func fetchUsers() async -> Result<[User], Error> {
		guard let url = url else {
			return .failure(Errors.failedToGetUsers)
		}
		do {
			let (data, _) = try await URLSession.shared.data(from: url)
			users = try JSONDecoder().decode([User].self, from: data)
			return .success(users)
		}
		catch {
			return .failure(error)
		}
		
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		users.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = users[indexPath.row].name
		return cell
	}

}

