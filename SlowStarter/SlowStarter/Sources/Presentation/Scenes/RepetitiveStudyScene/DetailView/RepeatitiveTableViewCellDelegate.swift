//
//  RepeatitiveTableViewCellDelegate.swift
//  SlowStarter
//
//  Created by jdios on 6/12/25.
//

import Foundation

protocol RepeatitiveTableViewCellDelegate: AnyObject {
    func repeatitiveCell(_ cell: RepeatitiveTableViewCell, didTapPointButtonAtIndex index: Int)
}
