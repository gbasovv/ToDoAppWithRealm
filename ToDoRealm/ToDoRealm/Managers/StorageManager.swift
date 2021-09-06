//
//  StorageManager.swift
//  ToDoRealm
//
//  Created by George on 6.08.21.
//

import Foundation
import RealmSwift

let realm = try! Realm()

class StorageManager {

    static func deleteAll() {
        try! realm.write {
            realm.deleteAll()
        }
    }

    static func saveTasksList(tasksList: TasksList) {
        try! realm.write {
            realm.add(tasksList)
        }
    }

    static func deleteList(_ tasksList: TasksList) {
        try! realm.write {
            let tasks = tasksList.tasks
            realm.delete(tasks)
            realm.delete(tasksList)
        }
    }

    static func editList(_ tasksList: TasksList, newListName: String) {
        try! realm.write {
            tasksList.name = newListName
        }
    }

    static func allDone(_ tasksList: TasksList) {
        try! realm.write {
            tasksList.tasks.setValue(true, forKey: "isComplete")
        }
    }

    static func saveTask(_ tasksList: TasksList, task: Task) {
        try! realm.write {
            tasksList.tasks.append(task)
        }
    }

    static func editTask(_ task: Task, newTask: String, newNote: String) {
        try! realm.write {
            task.name = newTask
            task.note = newNote
        }
    }

    static func deleteTask(_ task: Task) {
        try! realm.write {
            realm.delete(task)
        }
    }

    static func done(_ task: Task) {
        try! realm.write {
            task.isComplete.toggle()
        }
    }
}
