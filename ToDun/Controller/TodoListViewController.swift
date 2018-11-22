//
//  ViewController.swift
//  ToDun
//
//  Created by El Benitez on 10/25/18.
//  Copyright © 2018 Eleuterio Benitez. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var todoItems: Results<Item>?
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        self.navigationItem.title = selectedCategory?.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        guard let colorHex = selectedCategory?.color else {fatalError()}
        updateNavBar(withHexCode: colorHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "faf9f9")
    }
    
    func updateNavBar(withHexCode colorHexCode: String){
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist.")}
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError()}
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
        searchBar.barTintColor = navBarColor
    }
    
    //MARK - Table View Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = todoItems?[indexPath.row].title
            cell.accessoryType = item.done ? .checkmark : .none
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }
    
    //MARK - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] { //setting checkmark
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)//doesn't stay grey
    }
    
    //Delete items with swipe function
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }

    //MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New ToDun Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //What will happen once user clicks add button
            if let currentCategory = self.selectedCategory {

                do { try self.realm.write {
                    let newItem = Item()
                    newItem.title = textField.text ?? ""
                    newItem.dateCreated = Date()
                    currentCategory.items.append(newItem)
                    self.realm.add(newItem)
                    }
                }
                catch {
                    print("error, could not enter new item:\(error)")
                }
            }
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
}

//MARK: Search bar methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
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
