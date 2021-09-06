//
//  TasksTVC.swift
//  ToDoRealm
//
//  Created by George on 6.08.21.
//

import UIKit
import RealmSwift

class TasksTVC: UITableViewController {

    var currentTasksList: TasksList!

    private var currentTasks: Results<Task>!
    private var completedTasks: Results<Task>!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = currentTasksList.name
        filteringTasks()
    }

    @IBAction func editTasks(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }

    @IBAction func addTasks(_ sender: Any) {
        alertForAddAndUpdate()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT" : "COMPLETED"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.note
        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]

        let deleteContextItem = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteTask(task)
            self.filteringTasks()
        }

        let editContextItem = UIContextualAction(style: .destructive, title: "Edit") { _, _, _ in
            self.alertForAddAndUpdate(task)
        }

        let doneContextItem = UIContextualAction(style: .destructive, title: "Done") { _, _, _ in
            StorageManager.done(task)
            self.filteringTasks()
        }

        editContextItem.backgroundColor = .orange
        doneContextItem.backgroundColor = .green

        let swipeActions = UISwipeActionsConfiguration(actions: [deleteContextItem, editContextItem, doneContextItem])

        return swipeActions
    }

    private func filteringTasks() {
        currentTasks = currentTasksList.tasks.filter("isComplete = false")
        completedTasks = currentTasksList.tasks.filter("isComplete = true")
        tableView.reloadData()
    }

    private func alertForAddAndUpdate(_ taskName: Task? = nil) {
        let title = "Task value"
        let message = taskName == nil ? "Insert task" : "Update task"
        let doneButton = taskName == nil ? "Save" : "Update"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var taskTF: UITextField!
        var noteTF: UITextField!

        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            guard let newTask = taskTF.text, !newTask.isEmpty else { return }

            if let taskName = taskName {
                if let newNote = noteTF.text, !newNote.isEmpty {
                    StorageManager.editTask(taskName, newTask: newTask, newNote: newNote)
                } else {
                    StorageManager.editTask(taskName, newTask: newTask, newNote: "")
                }
                self.filteringTasks()
            } else {
                let task = Task()
                task.name = newTask
                if let note = noteTF.text, !note.isEmpty {
                    task.note = note
                }
                StorageManager.saveTask(self.currentTasksList, task: task)
                self.filteringTasks()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        alert.addTextField { textField in
            taskTF = textField
            taskTF.placeholder = "New task"

            if let taskName = taskName {
                taskTF.text = taskName.name
            }
        }

        alert.addTextField { textField in
            noteTF = textField
            noteTF.placeholder = "Note"

            if let taskName = taskName {
                noteTF.text = taskName.note
            }
        }

        present(alert, animated: true)
    }
}
