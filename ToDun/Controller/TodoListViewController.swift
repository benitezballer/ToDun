//
//  ViewController.swift
//  ToDun
//
//  Created by El Benitez on 10/25/18.
//  Copyright © 2018 Eleuterio Benitez. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    //MARK - Table View Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        let item = itemArray[indexPath.row]
        
        cell.accessoryType = item.done ? .checkmark : .none
        //if item.done true then gets checkmark
        //value = condition ? valueIfTrue : valueIfFalse
        return cell
    }
    
    //MARK - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        //sets property to its opposite
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)//doesn't stay grey
    }
    
    //MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New ToDun Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //What will happen once user clicks add button
            if let txtFldTxt = textField.text {
                let newItem = Item(context: self.context)
                newItem.title = txtFldTxt
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                self.itemArray.append(newItem)
                self.saveItems()
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems() {
        do{
            try context.save()
        }
        catch {
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        do {
            itemArray = try context.fetch(request)
        } catch {
            print ("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
}

//MARK: Search bar methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {//search bar has been emptied
            loadItems()
            DispatchQueue.main.async {//brings this action to the front of the line
                searchBar.resignFirstResponder()
            }
        }
    }
}
