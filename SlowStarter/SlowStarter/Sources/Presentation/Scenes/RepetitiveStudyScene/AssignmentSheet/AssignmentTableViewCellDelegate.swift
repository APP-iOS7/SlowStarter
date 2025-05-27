//
//  AssignmentTableViewCellDelegate.swift
//  SlowStarter
//
//  Created by jdios on 5/22/25.
//

import Foundation

protocol AssignmentTableViewCellDelegate: AnyObject {
    func didTapAssignmentButton(in cell: AssignmentTableViewCell)
}
