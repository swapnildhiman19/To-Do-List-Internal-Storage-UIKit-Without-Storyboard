//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class ToDoListHomeViewController: UITableViewController {

//    var pendingItems :[String] = ["x","a","c","s","e","d","f","g","h","j","k","l","z","x","c","v","b","n","m"]
    var pendingItems: [Item] = [] // Item is now coming from CoreData
    
    // Reference the context from AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let defaults = UserDefaults.standard // store key value pairs consistently across the app
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        title = "To Do List" // Navigation bar title
        
        //Load it from the userDefaults stored
//        pendingItems = defaults.object(forKey: "pendingItems") as? [Item] ?? []
        loadItems()
        
        //  pendingItems = ["x","a","c","s","e","d","f","g","h","j","k","l","z","x","c","v","b","n","m"]: Issue with this approach is if we are using reusable cell and the checkmark property is assigned to cell that's why when there are lot of rows in the table view and you have checked item at top then when you scroll at bottom you will see another cell of same checked state, if you use UITableViewCell() once the cell disappears from the top while scrolling it comes to bottom and when we go up again it get's reintialized, we need a value of checkmark related to it's own data Model and not to a cell which is getting reused everytime. TableView only stores the memory of the cell which are visible
        
        // Rather than using UserDefaults we can make our own custom plist to store the Item Model using NSCoder
        let dataFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("pendingItems.plist")
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        // need to add a bar button item to add new tasks on Navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTask))
    }
    /*
    When using UserDefaults way of storing the data
    
    func loadItems(){
        // Need to convert the Data from UserDefaults to Item model and then pass it further
        
        // if we were using our own custom plist
//        let data = try? Data(contentsOf: dataFilePath!)
//        let decoder = PropertyListDecoder() // if you  are purely remaining in Apple ecosystem and doesn't want to send the data through API use PropertyListDecoder instead of JSONDecoder
        
        
        if let data = defaults.data(forKey: "pendingItems"){
            let decoder = JSONDecoder()
            do {
                pendingItems = try decoder.decode([Item].self, from: data)
                print("Items loaded successfully: \(pendingItems.count) items")
            } catch {
                print("Error decoding items: \(error)")
            }
        } else {
            print("No saved items found")
        }
    }
    
    func saveItems() {
        // Need to convert the Item model to Data to store in UserDefaults using encoder
        
//        let encoder = PropertyListEncoder(): If we are using our own custom plist
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(pendingItems)
            defaults.set(data, forKey: "pendingItems")
//            data.write(to: destinationPath!): If we are using our own custom plist
            print("Items saved successfully")
        } catch {
            print("Error encoding items: \(error)")
        }
    }
     
     @objc func addNewTask() {
         var userEnteredTextField = UITextField() // Create a text field for user input

         let alert = UIAlertController(title: "Add New To-Do Task", message: nil, preferredStyle: .alert)

         let addAction = UIAlertAction(title: "Add Item", style: .default) { [weak self] _ in
          // what will happen when the user taps the button
             print("success")
          // using userEnteredTextField.text to get the text entered by the user
 //            self?.pendingItems.append(userEnteredTextField.text ?? "") // Append the new item to the pendingItems array
             
             let newItem = Item(text: userEnteredTextField.text ?? "")
             self?.pendingItems.append(newItem)
             
             // Adding to UserDefaults also ( saves in plist file )
 //            self?.defaults.set(self?.pendingItems, forKey: "pendingItems")
             self?.saveItems()
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
     */
    
    // MARK: - Core Data CRUD methods

    func saveItems() {
        do {
            try context.save()
//            tableView.reloadData()
        } catch {
            print("❌ Error saving context: \(error)")
        }
    }
    
    func loadItems() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        do {
            pendingItems = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("❌ Error loading items: \(error)")
        }
    }
    
    @objc func addNewTask() {
        var userEnteredTextField = UITextField()
        let alert = UIAlertController(title: "Add New To-Do Task", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Create new item"
            userEnteredTextField = textField
        }
        let addAction = UIAlertAction(title: "Add Item", style: .default) { [weak self] _ in
            guard let self = self, let text = userEnteredTextField.text, !text.isEmpty else { return }
//            let newItem = Item(context: self.context)
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let newItem = Item(context: context)
            newItem.text = text
            newItem.done = false
//            self.pendingItems.append(newItem) : Context sambhaal lega loadItems ke time
            self.saveItems()
            self.loadItems()
        }
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pendingItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let item = pendingItems[indexPath.row]
        cell.textLabel?.text = item.text
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }

    // MARK: - Table view delegate
    
    //deleting the element by adding the swiping feature
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete {
            let itemToDelete = pendingItems[indexPath.row]
            context.delete(itemToDelete)
            saveItems()
            loadItems()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected item: \(pendingItems[indexPath.row])")
        // need to give a checkmark when we select a row and uncheck when we select again
//        if let cell = tableView.cellForRow(at: indexPath) {
//            if cell.accessoryType == .checkmark {
//                cell.accessoryType = .none // Uncheck
//            } else {
//                cell.accessoryType = .checkmark // Check
//            }
//        }
        
        // Need to have done state as per the data model and not according to the cell
        pendingItems[indexPath.row].done = !pendingItems[indexPath.row].done
        
//        pendingItems[indexPath.row].setValue("Completed", forKey: "text")
        
        saveItems()
        
        // Reload this specific row, to call cellForRowAt method
        tableView.reloadRows(at: [indexPath], with: .none)
        
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after selection
    }
}


