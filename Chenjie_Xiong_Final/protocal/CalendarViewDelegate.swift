//
//  CalendarViewDelegate.swift
//  Chenjie_Xiong_Final
//
//  Created by Chenjie Xiong on 7/31/22.
//

import Foundation
protocol CalendarViewDelegate: AnyObject {
    func calendarViewDidSelectDate(date: Date)
    func calendarViewDidTapRemoveButton()
}
