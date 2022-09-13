//
//  OngoingTasksTableViewController.swift
//  Chenjie_Xiong_Final
//
//  Created by Chenjie Xiong on 7/26/22.
//

import UIKit
import Loaf
protocol OngingTasksTVCDelegate: AnyObject {
    func showOptions(for task: Task)
}
class OngoingTasksTableViewController: UITableViewController, Animatable {
    private let databaseManager = DatabaseManager()
    private let authManager = AuthManager()
    override func viewDidLoad() {
        super.viewDidLoad()
       addTasksListener()
    }
    private var tasks: [Task] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    weak var deletegate: OngingTasksTVCDelegate?
    private func addTasksListener() {
        guard let uid = authManager.getUserId() else {
            print("no user found")
            return
            
        }
        
        databaseManager.addTasksListener(forDoneTask: false, uid: uid) { [weak self] (result) in
            switch result {
            case .success(let tasks):
                self?.tasks = tasks
            case .failure(let error):
                self?.showToast(state: .error, message: error.localizedDescription)
            }
        }
    }
    private func handleActionButton(for task: Task) {
        guard let id = task.id else { return }
        databaseManager.updateTaskStatus(id: id, isDone: true) { [weak self] (result) in
            switch result {
            case .success:
                self?.showToast(state: Loaf.State.info, message: "Move to done")
            case .failure(let error):
                self?.showToast(state: Loaf.State.error, message: error.localizedDescription)
            }
        }
    }
}
extension OngoingTasksTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! OngoingTaskTableViewCell
        let task = self.tasks[indexPath.row]
        cell.actionButtonDidTap = {[weak self] in
            self?.handleActionButton(for: task)
        }
        cell.configure(wirh: task)
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = tasks[indexPath.row]
        deletegate?.showOptions(for: task)
    }
}
