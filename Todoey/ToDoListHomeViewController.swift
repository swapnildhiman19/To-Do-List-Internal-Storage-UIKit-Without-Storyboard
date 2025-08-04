//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class ToDoListHomeViewController: UITableViewController {

    var pendingItems :[String] = []

    let defaults = UserDefaults.standard // store key value pairs consistently across the app
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        title = "To Do List" // Navigation bar title
        
        //Load it from the userDefaults stored
        pendingItems = defaults.object(forKey: "pendingItems") as? [String] ?? []

        // need to add a bar button item to add new tasks on Navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTask))
    }

    @objc func addNewTask() {
        var userEnteredTextField = UITextField() // Create a text field for user input

        let alert = UIAlertController(title: "Add New To-Do Task", message: nil, preferredStyle: .alert)

        let addAction = UIAlertAction(title: "Add Item", style: .default) { [weak self] _ in
         // what will happen when the user taps the button
            print("success")
         // using userEnteredTextField.text to get the text entered by the user
            self?.pendingItems.append(userEnteredTextField.text ?? "") // Append the new item to the pendingItems array
            
            // Adding to UserDefaults also ( saves in plist file )
            self?.defaults.set(self?.pendingItems, forKey: "pendingItems")
            self?.tableView.reloadData() // Reload the table view to reflect the new item
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
            print("Cancelled")
        }

        // attach the textfield to the alert
        alert.addTextField { textField in
            textField.placeholder = "Create new item" // Placeholder text
            // since the scope of this text field is only within this closure, we can use the textField directly
            userEnteredTextField = textField
            //  self.pendingItems.append(textField.text ?? "") -> Can't use this here because we need to append after the user has clicked on Add Item button
        }

        alert.addAction(addAction) // attach the action to the alert
        alert.addAction(cancelAction)

        // need to present this alert to the user
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pendingItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = pendingItems[indexPath.row]
        return cell
    }

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected item: \(pendingItems[indexPath.row])")
        // need to give a checkmark when we select a row and uncheck when we select again
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none // Uncheck
            } else {
                cell.accessoryType = .checkmark // Check
            }
        }
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after selection
    }
}


