//
//  LoadingViewController.swift
//  Chenjie_Xiong_Final
//
//  Created by Chenjie Xiong on 8/1/22.
//

import UIKit

class LoadingViewController: UIViewController {
    
    private let authManager = AuthManager()
    private let navigationManager = NavigationManager.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showInitalScreen()
    }
    func showInitalScreen() {
        if authManager.isUserLogin() {
            navigationManager.show(scene: .tasks)
        } else {
            navigationManager.show(scene: .onboarding)
        }
    }
}
