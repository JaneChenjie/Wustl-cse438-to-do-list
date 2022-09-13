//
//  OnboardingViewController.swift
//  Chenjie_Xiong_Final
//
//  Created by Chenjie Xiong on 7/31/22.
//

import UIKit
class OnboardingViewController: UIViewController {
    private let navigationManager = NavigationManager.shared
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func getStartedButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showLoginScreen", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLoginScreen", let destination = segue.destination as? LoginViewController {
            destination.delegate = self
        }
    }
    
}
extension OnboardingViewController: LoginVCDelegate {
    func didLogin() {
 
        presentedViewController?.dismiss(animated: true, completion: { [unowned self] in
            self.navigationManager.show(scene: .tasks)
            print("log in and show main app")
        })
    }
    
    
}
