//
//  BasicVideoPlayerViewController.swift
//  SlowStarter
//
//  Created by 이재용 on 5/14/25.
//

import UIKit
import AVKit
import AVFoundation
import SnapKit

class BasicVideoPlayerViewController: UIViewController {
    private var playVideoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
    }
    
    private func setupPlayButton() {
        playVideoButton = UIButton(type: .system)
        playVideoButton.setTitle("Play Video", for: .normal)
        
        playVideoButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playVideoButton)
        
        playVideoButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        
        
    }
    
    @objc private func playButtonTapped() {
        print("Play button tapped!")
        guard let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") else {
            print("Error: Invalid video URL")
            return
        }
        
        let player = AVPlayer(url: url)
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
        
    }
    
}

#Preview {
    BasicVideoPlayerViewController()
}
