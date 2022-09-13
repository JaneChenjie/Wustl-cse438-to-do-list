//
//  DoneTasksTableViewController.swift
//  Chenjie_Xiong_Final
//
//  Created by Chenjie Xiong on 7/26/22.
//

import UIKit
import Loaf
class DoneTasksTableViewController: UITableViewController, Animatable {
    override func viewDidLoad() {
        super.viewDidLoad()
        addTasksListener()
   
    }
    private let databaseManager = DatabaseManager()
    private let authManager = AuthManager()
    
    private var tasks: [Task] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    private func addTasksListener() {
        guard let uid = authManager.getUserId() else {
            print("no user found")
            return
            
        }
        databaseManager.addTasksListener(forDoneTask: true, uid: uid) { [weak self] (result) in
            switch result {
            case .success(let tasks):
                self?.tasks = tasks
            case .failure(let error):
                self?.showToast(state: Loaf.State.error, message: error.localizedDescription)
            }
        }
    }
    private func handleActionButton(for task: Task) {
        guard let id = task.id else { return }
        databaseManager.updateTaskStatus(id: id, isDone: false) { [weak self] (result) in
            switch result {
            case .success:
                self?.showToast(state: Loaf.State.info, message: "Moved to ongoing")
            case .failure(let error):
                self?.showToast(state: Loaf.State.error, message: error.localizedDescription)
            }
        }
    }
}
extension DoneTasksTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! DoneTaskTableViewCell
        let task = tasks[indexPath.row]
        cell.configue(with: task)
        cell.actionButtonDidTap = { [weak self] in
            self?.handleActionButton(for: task)
        }
        return cell
    }
}
