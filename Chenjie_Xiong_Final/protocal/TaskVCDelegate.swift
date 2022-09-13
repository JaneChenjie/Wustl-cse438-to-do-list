//
//  TaskVCDelegate.swift
//  Chenjie_Xiong_Final
//
//  Created by Chenjie Xiong on 7/26/22.
//

import Foundation

protocol NewTasksVCDelegate: AnyObject {
    func didAddTask(_ task: Task)
    func didEditTask(_ task: Task)
}
