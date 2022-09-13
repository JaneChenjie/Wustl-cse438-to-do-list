//
//  Task.swift
//  Chenjie_Xiong_Final
//
//  Created by Chenjie Xiong on 7/26/22.
//

import Foundation
import FirebaseFirestoreSwift
struct Task: Identifiable, Codable {
    @DocumentID var id: String?
    @ServerTimestamp var createAt: Date?
    let title: String
    var isDone: Bool = false
    var doneAt: Date?
    var deadline: Date?
    let uid: String
}
