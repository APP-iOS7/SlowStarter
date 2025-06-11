//
//  AssignmentTableViewCellDelegate.swift
//  SlowStarter
//
//  Created by jdios on 5/22/25.
//

import Foundation

protocol AssignmentTableViewCellDelegate: AnyObject {
    
    func didTapCellDeleteButton(in cell: AssignmentTableViewCell)
    
    func didTapCellEditButton(in cell: AssignmentTableViewCell)
    
    func cell(_ cell: AssignmentTableViewCell, didFinishEditingMemo newMemo: String)
    
    func didTapImageView(in cell: AssignmentTableViewCell)
    
    func assignmentCellDidToggleEditMode(in cell: AssignmentTableViewCell)
}
