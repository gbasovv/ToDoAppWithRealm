//
//  TasksList.swift
//  ToDoRealm
//
//  Created by George on 6.08.21.
//

import Foundation
import RealmSwift

class TasksList: Object {
    @objc dynamic var name = ""
    @objc dynamic var date = Date()
    let tasks = List<Task>()
}
