//
//  ItemsViewController.swift
//  Docket
//
//  Created by ASHMIT SHUKLA on 06/12/21.
//

import UIKit
import SwipeCellKit
import RealmSwift
import ChameleonFramework

class ItemsViewController: UITableViewController,UISearchControllerDelegate {
    let realm=try! Realm()
    var ItemList:Results<Item>?
    var selectedCategory:Category?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.rowHeight=70
        loadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ItemList?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemViewCell",for: indexPath) as! SwipeTableViewCell
        cell.delegate=self
        
        if let item = ItemList?[indexPath.row]{
            
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            let pr=CGFloat(CGFloat(indexPath.row)/CGFloat(ItemList?.count ?? 1))
            cell.textLabel?.textColor = FlatWhite().darken(byPercentage: pr)
            cell.backgroundColor = UIColor(hexString: (selectedCategory?.background ?? "1D98FC"))!.darken(byPercentage: pr)
        }
        return cell
    }
//MARK: - Table view Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = ItemList?[indexPath.row]{
            do{
                try realm.write{
                item.done = !item.done
            }
                
            }
            catch{
                print(error)
            }
        }
        tableView.reloadData()
    }
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textfield=UITextField()
        let alert=UIAlertController(title: "Add Item", message: "", preferredStyle: .alert)
        let action=UIAlertAction(title: "Add", style: .default) { action in
            if let newCategory = self.selectedCategory
            {
                do{
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title=textfield.text!
                        newItem.done=false
                        newItem.createdDate = Date()
                        newCategory.items.append(newItem)
                        self.tableView.reloadData()
                    }
                }
                catch{
                    print(error)
                }
            }
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder="Type Something"
            textfield=alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    //MARK: - Data modification
    func save(item: Item)
    {
        do{
            try realm.write{
                realm.add(item)
            }
        }
        catch{
            print(error)
        }
        tableView.reloadData()
    }
    func loadData()
    {
        ItemList=selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
}

extension ItemsViewController: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            if let toBeDeleted = self.ItemList?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(toBeDeleted)
                }
            }
            catch{
                print(error)
            }
            }
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
}
//MARK: - search bar
extension ItemsViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadData()
        ItemList = ItemList?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "createdDate",ascending: true)
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count != 0{
            loadData()
            ItemList = ItemList?.filter("title CONTAINS[cd] %@",searchBar.text!).sorted(byKeyPath: "createdDate",ascending: true)
            tableView.reloadData()
        }
        else{
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
