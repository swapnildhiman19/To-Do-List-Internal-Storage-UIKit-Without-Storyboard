//
//  CategoryViewController.swift
//  Todoey
//
//  Created by EasyAiWithSwapnil on 11/09/25.
//

import CoreData
import Foundation
import UIKit

class CategoryViewController : UIViewController {
    
    let tableView = UITableView()
    
    let searchBar = UISearchBar()
    
    //CRUD operations
    
    var categories : [Category] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        title = "Category" // Navigation bar title
        
        loadItems()
        
        // need to add a bar button item to add new tasks on Navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTask))
        constructView()
    }
    
    private func constructView(){
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        //TODO: Register the tableView
        //Needed if would have used reusable cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Category")
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    
    @objc func addNewTask() {
        var enteredTextField = UITextField()
        let alert = UIAlertController(title: "Create Category", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Create a new category"
            enteredTextField = textField
        }
        
        let addAlertAction = UIAlertAction(title: "Add Category", style: .default) { [weak self] action in
            guard let self = self, let text = enteredTextField.text, !text.isEmpty else { return }
            let newCategory = Category(context: context)
            newCategory.name = enteredTextField.text
            saveItems()
        }
        
        alert.addAction(addAlertAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func saveItems() {
        do {
            try context.save()
            try categories = context.fetch(Category.fetchRequest())
            tableView.reloadData()
        } catch {
            print("❌ Error saving context: \(error)")
        }
    }
    
    private func loadItems(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
           categories = try context.fetch(request)
           tableView.reloadData()
        } catch {
            print("❌ Error loading context: \(error)")
        }
    }
    
}

extension CategoryViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Here we will call the Items which are in this category and open ToDoListViewController
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CategoryViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell()
        let cell = tableView.dequeueReusableCell(withIdentifier: "Category", for: indexPath)
        let category = categories[indexPath.row]
        if #available(iOS 14.0, *) {
            var config = cell.defaultContentConfiguration()
            config.text = category.name
            cell.contentConfiguration = config
        } else {
            // Fallback on earlier versions
        }
        return cell
    }
}
