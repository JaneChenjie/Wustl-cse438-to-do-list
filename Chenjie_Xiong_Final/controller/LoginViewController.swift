//
//  LoginViewController.swift
//  Chenjie_Xiong_Final
//
//  Created by Chenjie Xiong on 8/1/22.
//

import UIKit
import Combine
class LoginViewController: UIViewController, Animatable {
    weak var delegate: LoginVCDelegate?
    private let authManager = AuthManager()
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    private var subscribers = Set<AnyCancellable>()
    @Published var errorString: String = ""
    @Published var isLoginSucessful = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeForm()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }
    private func observeForm() {
        $errorString.sink { [unowned self] (errorMessage) in
            self.errorLabel.text = errorMessage
            
        }.store(in: &subscribers)
        $isLoginSucessful.sink { [unowned self] (isSucessful) in
            if isSucessful {
                self.delegate?.didLogin()
            }
        }.store(in: &subscribers)
    }
    @IBAction func loginWithButtonTapped(_ sender: UIButton) {
        

        guard let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty else {
            errorString = "Incomplete Form"
            return
        }
        errorString = ""
        showLoadingAnimation()
        authManager.login(withEmail: email, password: password) { [weak self] (result) in
            self?.hideLoadingAnimation()
            switch result {
            case .success:
                self?.isLoginSucessful = true
            case .failure(let error):
                self?.errorString = error.localizedDescription
            }
        }
   
        
    }
    @IBAction func signUpButtonTapped(_ sender: UIButton) {

        guard let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty else {
            errorString = "Incomplete Form"
            return
        }
        errorString = ""
        showLoadingAnimation()
        authManager.signUp(withEmail: email, password: password) { [weak self] (result) in
            self?.hideLoadingAnimation()
            switch result {
            case .success:
                self?.isLoginSucessful = true
            case .failure(let error):
                self?.errorString = error.localizedDescription
            }
        }
    }
}
