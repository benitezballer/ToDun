//
//  ViewController.swift
//  ToDun
//
//  Created by El Benitez on 10/25/18.
//  Copyright © 2018 Eleuterio Benitez. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newItem1 = Item()
        newItem1.title = "Find Mike"
        itemArray.append(newItem1)

        let newItem2 = Item()
        newItem2.title = "Buy Eggos"
        itemArray.append(newItem2)

        let newItem3 = Item()
        newItem3.title = "Destroy Demogorgon"
        itemArray.append(newItem3)

        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
            itemArray = items
        } //loads list from previously saved array
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
//        let currentItem = itemArray[indexPath.row]
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        //sets property to its opposite
        
        tableView.reloadData() //reload tableview to show checkmarks
        tableView.deselectRow(at: indexPath, animated: true)//doesn't stay grey
    }
    
    //MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New ToDun Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //What will happen once user clicks add button
            if let txtFldTxt = textField.text {
                let newItem = Item()
                newItem.title = txtFldTxt
                self.itemArray.append(newItem)
                self.defaults.set(self.itemArray, forKey: "TodoListArray")
                self.tableView.reloadData()
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

