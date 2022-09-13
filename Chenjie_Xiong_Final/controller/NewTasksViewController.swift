//
//  NewTasksViewController.swift
//  Chenjie_Xiong_Final
//
//  Created by Chenjie Xiong on 7/26/22.
//

import UIKit
import Combine
class NewTasksViewController:
    UIViewController {
    
    
    @IBOutlet weak var containerViewButtomConstrain: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var taskFieldView: UITextField!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deadLineLabel: UILabel!
    weak var delegate:NewTasksVCDelegate?
    private var subscribers = Set<AnyCancellable>()
    private let authManager = AuthManager()
    var taskToEdit: Task?
    
    @Published private var taskString:String?
    @Published private var deadline: Date?
    
    private lazy var calendarView: CalendarView = {
        let view = CalendarView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
     
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        observeForm()
        setupGesture()
        observeKeyboard()
        
       
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        taskFieldView.becomeFirstResponder()
    }
    private func setupView() {
        backgroundView.backgroundColor = UIColor.init(white: 0.3, alpha: 0.4)
        containerViewButtomConstrain.constant = -containerView.frame.height
        if let taskToEdit = taskToEdit {
            taskFieldView.text = taskToEdit.title
            deadline = taskToEdit.deadline
           
            saveButton.setTitle("Update", for: .normal)
            
            calendarView.selectDate(date: taskToEdit.deadline)
        }
    }
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    private func observeForm() {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification).map {(notification) -> String? in (notification.object as? UITextField)?.text}.sink { [unowned self] (text) in
            self.taskString = text
        }.store(in: &subscribers)
        $taskString.sink { (text) in
            self.saveButton.isEnabled = text?.isEmpty == false
        }.store(in: &subscribers)
        $deadline.sink {
            (date) in
            
            self.deadLineLabel.text = date?.toString() ?? ""
        }.store(in: &subscribers)
    }
    private func observeKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        let keyboardHeight = getKeyboardHeight(notification: notification)
        
        containerViewButtomConstrain.constant = keyboardHeight - (200 + 8)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {[unowned self] in
            self.containerViewButtomConstrain.constant = keyboardHeight - (200 + 8)
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        containerViewButtomConstrain.constant = -containerView.frame.height
        
    }
    private func getKeyboardHeight(notification: Notification) -> CGFloat {
        guard let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return 0 }
        return keyboardHeight
    }
    @objc private func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func calendarButtonTapped(_ sender: Any) {
        taskFieldView.resignFirstResponder()
        showCalendar()
    }
    private func showCalendar() {
        view.addSubview(calendarView)
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
           
            
        ])
    }
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let taskString = self.taskString,
        let uid = authManager.getUserId() else {
            return
        }
        var task = Task(title: taskString, deadline: deadline, uid: uid)
        if let id = taskToEdit?.id{
            task.id = id
        }
        if taskToEdit == nil {
            delegate?.didAddTask(task)
        } else {
            delegate?.didEditTask(task)
        }
    }
    private func dismissCalendarView(completion: () -> Void) {
        calendarView.removeFromSuperview()
        completion()
    }
}
extension NewTasksViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if calendarView.isDescendant(of: view) {
            if touch.view?.isDescendant(of: calendarView) == false {
                dismissCalendarView { [unowned self] in
                    self.taskFieldView.becomeFirstResponder()
                }
            }
            return false
        }
        return true
    }
}
extension NewTasksViewController: CalendarViewDelegate {
    func calendarViewDidSelectDate(date: Date) {
        dismissCalendarView {
            self.taskFieldView.becomeFirstResponder()
            self.deadline = date
        }
       
        
    }
    
    func calendarViewDidTapRemoveButton() {
        dismissCalendarView {
            self.taskFieldView.becomeFirstResponder()
            self.deadline = nil
        }
    }
    
    
}
