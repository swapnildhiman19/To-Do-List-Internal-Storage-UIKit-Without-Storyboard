//
//  ViewController.swift
//  Todoey
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {

//    var pendingItems :[String] = ["x","a","c","s","e","d","f","g","h","j","k","l","z","x","c","v","b","n","m"]
    var pendingItems: [Item] = [] // Item is now coming from CoreData

    // Reference the context from AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let defaults = UserDefaults.standard // store key value pairs consistently across the app

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        title = "To Do List" // Navigation bar title

        // Add Search Bar UI
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search Items"
        searchBar.sizeToFit() // Set the search bar's size
        tableView.tableHeaderView = searchBar

        //Load it from the userDefaults stored
//        pendingItems = defaults.object(forKey: "pendingItems") as? [Item] ?? []
        loadItems()

        //  pendingItems = ["x","a","c","s","e","d","f","g","h","j","k","l","z","x","c","v","b","n","m"]: Issue with this approach is if we are using reusable cell and the checkmark property is assigned to cell that's why when there are lot of rows in the table view and you have checked item at top then when you scroll at bottom you will see another cell of same checked state, if you use UITableViewCell() once the cell disappears from the top while scrolling it comes to bottom and when we go up again it get's reintialized, we need a value of checkmark related to it's own data Model and not to a cell which is getting reused everytime. TableView only stores the memory of the cell which are visible

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

    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
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

// MARK: - Search Bar Delegate Methods
extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // This method is called when the user taps the search button on the keyboard.
        // You can implement your search logic here.
        print("Search button clicked with text: \(searchBar.text ?? "")")
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        request.predicate = NSPredicate(format: "text contains[cd] %@", searchBar.text!)
        // Query to DB using NSPredicate
        
        request.sortDescriptors = [NSSortDescriptor(key: "text", ascending: true)]
        
        loadItems(with: request)
        
        // To dismiss the keyboard
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // This method is called every time the text in the search bar changes.
        // You can implement live search/filtering here.
        print("Search text changed to: \(searchText)")
        
        if searchText.isEmpty {
            // If the search text is empty, reload all items.
            loadItems()
            
            // Resign first responder on the main thread to dismiss the keyboard.
            DispatchQueue.main.async {
                searchBar.resignFirstResponder() // No longer cursor and keyboard now
            }
        }
    }
    
    /*
     ### Explanation in Layman's Terms

     Think of your app's user interface (UI) as being managed by a single, dedicated worker who can only do one task at a time. This worker operates on what's called the "main thread." All UI-related jobs, like showing the keyboard, hiding it, or updating your list, must be given to this worker.

     When you clear the text in the search bar, the `searchBar(_:textDidChange:)` method is called. At that exact moment, the UI worker is busy processing the text change. If you immediately tell it to also hide the keyboard, it's like giving the worker a new, conflicting order while they are still in the middle of the first one. This can sometimes cause the app to get confused or behave strangely.

     Using `DispatchQueue.main.async` is like leaving a polite note for the worker. The note says, "As soon as you finish your current task (updating the search bar's text), please do this next: hide the keyboard." This ensures the tasks are done in an orderly sequence, preventing any conflicts and keeping the UI running smoothly.

     ### Technical Details

     1.  **The Main Thread and UI Updates**: In iOS, all operations that modify the user interface must be performed on the main thread (also known as the UI thread). UIKit, the framework that manages UI components like `UISearchBar`, is not "thread-safe." This means if you try to update the UI from a background thread, you can cause unpredictable behavior, visual glitches, or crashes. The `searchBar(_:textDidChange:)` delegate method is, by default, already called on the main thread.

     2.  **The Role of `resignFirstResponder()`**: This method tells a UI element to give up its "first responder" status. For a `UISearchBar`, being the first responder means it is the active input field and has the keyboard displayed. Calling `resignFirstResponder()` is the programmatic way to dismiss the keyboard. Since this is a UI operation, it must happen on the main thread.

     3.  **Why `async`?**: If the delegate method is already on the main thread, why do we need `DispatchQueue.main.async`? The key is not about changing *which* thread the code runs on, but *when* it runs.

         *   When `searchBar(_:textDidChange:)` is triggered, the `UISearchBar` is in the middle of its own state update. It's actively handling the text change event.
         *   Calling `searchBar.resignFirstResponder()` directly and synchronously inside this method can create a conflict. You are telling the search bar to give up its active status while it is still processing an event that relies on it being active.
         *   By wrapping the call in `DispatchQueue.main.async`, you are scheduling this block of code to be executed on the main thread, but at the next available opportunity in the app's "run loop." This effectively pushes the `resignFirstResponder()` call to a moment just after the `UISearchBar` has finished its current text-change processing.

     In short, it decouples the action of dismissing the keyboard from the event that triggered it, ensuring the UI state changes happen cleanly and without interfering with each other.

     Here is the code block for reference:

     ```swift
     func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
         if searchText.isEmpty {
             loadItems()
             
             // Schedule the keyboard dismissal for the next run loop cycle on the main thread.
             // This prevents conflicts with the search bar's current state update.
             DispatchQueue.main.async {
                 searchBar.resignFirstResponder()
             }
         }
     }
     ```
     */
    
}
