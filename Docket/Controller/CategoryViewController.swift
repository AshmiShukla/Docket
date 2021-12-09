//
//  CategoryViewController.swift
//  Docket
//
//  Created by ASHMIT SHUKLA on 06/12/21.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class CategoryViewController: UITableViewController {
    let realm=try! Realm()
    var categories:Results<Category>?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.rowHeight=70
        loadCategories()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryViewCell",for: indexPath) as! SwipeTableViewCell
        cell.delegate=self
        cell.backgroundColor=UIColor(hexString: categories?[indexPath.row].background ?? "1D98F6")
        cell.textLabel?.text=categories?[indexPath.row].name
        return cell
    }
    //MARK: - Table View delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToParent", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ItemsViewController
        if let indexpath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories?[indexpath.row]
        }
    }
    @IBAction func addButtonPressedHard(_ sender: UIBarButtonItem) {
        var textfield=UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action=UIAlertAction(title: "ADD", style: .default) { action in
            let newCategory=Category()
            
            newCategory.name=textfield.text!
            
            let rang1=UIColor.randomFlat().hexValue()
            newCategory.background=rang1
            self.saveCategory(category: newCategory)
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder="Type Something"
            textfield=alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    //MARK: - Data Modification
    func saveCategory(category:Category)
    {
        do{
            try realm.write{
                realm.add(category)
            }
        }
        catch{
            print(error)
        }
        tableView.reloadData()
    }
    func loadCategories()
    {
        categories=realm.objects(Category.self)
        tableView.reloadData()
    }
}

extension CategoryViewController: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            if let toBeDeleted = self.categories?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(toBeDeleted)
                }
            }
            catch{
                print(error)
            }
//                tableView.reloadData()
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
