//
//  RepeatitiveStudyDetailViewModel.swift
//  SlowStarter
//
//  Created by jdios on 5/23/25.
//

import Foundation
import UIKit

class RepeatitiveStudyDetailViewModel: ObservableObject {
    var playingLectureData: RepetitiveStudyDetailData?
    var repeatitiveStudyListCellDataset: [RepeatitiveStudyListCellData] = []
}
struct RepetitiveStudyDetailData {
    var lectureTitle: String
    var description: String
    var vods: [VOD]
    
}


struct RepeatitiveStudyListCellData {
    let title: String
    let url: URL
    var assignments: [Assignment]
    
}
