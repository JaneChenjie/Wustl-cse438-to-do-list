//
//  DoneTaskTableViewCell.swift
//  Chenjie_Xiong_Final
//
//  Created by Chenjie Xiong on 7/28/22.
//

import UIKit

class DoneTaskTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel:UILabel!
    var actionButtonDidTap: (() -> Void)?
    func configue(with task: Task) {
        titleLabel.text = task.title
    }
    @IBAction func actionButtoonTapped(_ sender: UIButton) {
        actionButtonDidTap?()
    }
}
