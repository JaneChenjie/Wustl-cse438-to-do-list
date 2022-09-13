//
//  OngoingTaskTableViewCell.swift
//  Chenjie_Xiong_Final
//
//  Created by Chenjie Xiong on 7/27/22.
//

import UIKit

class OngoingTaskTableViewCell: UITableViewCell, Animatable {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    
    var actionButtonDidTap: (() -> Void)?
    
    @IBAction func ctionButtonTapped(_ sender: UIButton) {
        actionButtonDidTap?()
        
    }
    func configure(wirh task: Task) {
        titleLabel.text = task.title
        deadlineLabel.text = task.deadline?.toRelativeString()
        if task.deadline?.isOverDue() == true {
            deadlineLabel.textColor = .red
            deadlineLabel.font = UIFont(name: "AvenirNext-Medium", size: 12)
        }
    
    }
}
