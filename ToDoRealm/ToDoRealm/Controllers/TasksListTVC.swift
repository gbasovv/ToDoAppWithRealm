//
//  TasksListTVC.swift
//  ToDoRealm
//
//  Created by George on 6.08.21.
//

import UIKit
import RealmSwift

class TasksListTVC: UITableViewController {

    var tasksLists: Results<TasksList>!
    var notificationToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        tasksLists = realm.objects(TasksList.self).sorted(byKeyPath: "name")
        notificationToken = tasksLists.observe { change in
            switch change {
            case .initial:
                print("initial element")
            case .update(_, let deletions, let insertions, let modifications):
                print("deletions: \(deletions)")
                print("insertions: \(insertions)")
                print("modifications: \(modifications)")
            case .error(let error):
                print("error: \(error)")
            }
        }
        navigationItem.leftBarButtonItem = editButtonItem
    }

    @IBAction func sortingList(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            tasksLists = tasksLists.sorted(byKeyPath: "name")
        } else {
            tasksLists = tasksLists.sorted(byKeyPath: "date")
        }
        tableView.reloadData()
    }

    @IBAction func addTasks(_ sender: UIBarButtonItem) {
        alertForAddAndUpdate()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksLists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksListCell", for: indexPath)
        let tasksList = tasksLists[indexPath.row]
        cell.configure(with: tasksList)
        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let currentList = tasksLists[indexPath.row]

        let deleteContextItem = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteList(currentList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }

        let editContextItem = UIContextualAction(style: .destructive, title: "Edit") { _, _, _ in
            self.alertForAddAndUpdate(currentList, complition: {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            })
        }

        let doneContextItem = UIContextualAction(style: .destructive, title: "Done") { _, _, _ in
            StorageManager.allDone(currentList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        doneContextItem.backgroundColor = .green
        editContextItem.backgroundColor = .orange

        let swipeActions = UISwipeActionsConfiguration(actions: [deleteContextItem, editContextItem, doneContextItem])

        return swipeActions
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let tasksList = tasksLists[indexPath.row]
            let tasksTVC = segue.destination as! TasksTVC
            tasksTVC.currentTasksList = tasksList
        }
    }

    private func alertForAddAndUpdate(_ listName: TasksList? = nil, complition: (() -> Void)? = nil) {

        let title = listName == nil ? "New List" : "Edit List"
        let message = "Insert list name"
        let doneButtonName = listName == nil ? "Save" : "Update"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var alertTextField: UITextField!

        let saveAction = UIAlertAction(title: doneButtonName, style: .default) { _ in
            guard let newList = alertTextField.text, !newList.isEmpty else { return }

            if let listName = listName {
                StorageManager.editList(listName, newListName: newList)
                if let complition = complition {
                    complition()
                }
            } else {
                let tasksList = TasksList()
                tasksList.name = newList

                StorageManager.saveTasksList(tasksList: tasksList)
                self.tableView.insertRows(at: [IndexPath(row: self.tasksLists.count - 1, section: 0)], with: .automatic)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        alert.addTextField { textField in
            alertTextField = textField
            alertTextField.placeholder = "List name"

            if let listName = listName {
                alertTextField.text = listName.name
            }
        }

        present(alert, animated: true)
    }
}
