//
//  ViewController.swift
//  Chenjie_Xiong_Final
//
//  Created by Chenjie Xiong on 7/25/22.
//

import UIKit
import Loaf
class TasksViewController: UIViewController, Animatable {

    @IBOutlet weak var menuSegmentedControl: UISegmentedControl!
    @IBOutlet weak var ongoingTasksContainerView: UIView!
    @IBOutlet weak var doneTasksContainerView: UIView!
    private let databaseManager = DatabaseManager()
    private let authManager = AuthManager()
    private let navigationManager = NavigationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupSegmentedControl()
        
    }
    private func setupSegmentedControl() {
        menuSegmentedControl.removeAllSegments()
        MenuSection.allCases.enumerated().forEach { (index, section) in
            menuSegmentedControl.insertSegment(withTitle: section.rawValue, at: index, animated: false)
        }
        menuSegmentedControl.selectedSegmentIndex = 0
        showContainerView(for: .ongoing)
    }
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            showContainerView(for: .ongoing)
        case 1:
            showContainerView(for: .done)
        default: break
        }
    }
    private func showContainerView(for section: MenuSection) {
        switch section {
        case .ongoing:
            ongoingTasksContainerView.isHidden = false
            doneTasksContainerView.isHidden = true
        case .done:
            ongoingTasksContainerView.isHidden = true
            doneTasksContainerView.isHidden = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNewTasks", let destination = segue.destination as? NewTasksViewController {
            destination.delegate = self
        } else if segue.identifier == "showOngingTasks" {
            let destination = segue.destination as? OngoingTasksTableViewController
            destination?.deletegate = self
        } else if segue.identifier == "showEditTask", let desination = segue.destination as? NewTasksViewController, let taskToEdit = sender as? Task {
            desination.taskToEdit = taskToEdit
            desination.delegate = self
        }
    }
    
    @IBAction func addTaskButtonTapped(_ sender: UIButton) {
       
        performSegue(withIdentifier: "showNewTasks", sender: nil)
    }
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        showMenuOptions()
    }
    private func showMenuOptions() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "Logout", style: .default) { _ in
            self.logoutUser()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        present(alertController, animated: true, completion: nil)
    }
    private func logoutUser() {
        authManager.logout { [unowned self] (result) in
            switch result {
            case .success:
                // redirect user to onboarding screen
                navigationManager.show(scene: .onboarding)
            case .failure(let error):
                self.showToast(state: .error, message: error.localizedDescription, duration: 3.0)
            }
        }
    }
    private func deleteTask(id: String) {
        databaseManager.deleteTask(id: id) { [weak self] (result) in
            switch result {
            case .success:
                self?.showToast(state: .success, message: "Task deleted sucessfully")
            case .failure(let error):
                self?.showToast(state: .error, message: error.localizedDescription)
            }
        }
    }
    private func editTask(task: Task) {
        performSegue(withIdentifier: "showEditTask", sender: task)
    }


}


extension TasksViewController: NewTasksVCDelegate {
    func didEditTask(_ task: Task) {
        presentedViewController?.dismiss(animated: true, completion: {
            guard let id = task.id else {return}
            self.databaseManager.editTask(id: id, title: task.title, deadline: task.deadline) { [weak self] (result) in
                switch result{
                case .success:
                    self?.showToast(state: .success, message: "Task updated sucessfully")
                case .failure(let error):
                    self?.showToast(state: .error, message: error.localizedDescription)
                  
                    
                
                }
            }
        })
    }
    
    func didAddTask(_ task: Task) {
        presentedViewController?.dismiss(animated: true, completion: { [unowned self] in
            self.databaseManager.addTask(task) { [weak self] (result) in
                switch result{
                case .success:
                    break
                case .failure(let error):
                    
                    self?.showToast(state: .error, message: error.localizedDescription)
                    
                
                }
            }
        })
        
    }
    
    
}
extension TasksViewController: OngingTasksTVCDelegate {
    func showOptions(for task: Task) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        let editAction = UIAlertAction(title: "Edit", style: .default) { [unowned self] _ in
            self.editTask(task: task)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {[unowned self] _ in
            guard let id = task.id else {return}
            self.deleteTask(id: id)
   
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        alertController.addAction(editAction)
        present(alertController, animated: true, completion: nil)
        
    }
}

