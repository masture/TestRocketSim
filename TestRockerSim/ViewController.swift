//
//  ViewController.swift
//  TestRockerSim
//
//  Created by Pankaj Kulkarni on 29/6/25.
//

import UIKit

class ViewController: UIViewController {

    override func loadView() {
        super.loadView()
        
        setupUI()
    }
    
    fileprivate func setupUI() {
        view.backgroundColor = .systemMint
        
        addButton()
    }
    
    fileprivate func addButton() {
        let button = UIButton(type: .system)
        button.setTitle("Capture Image", for: .normal)
        button.addTarget(self, action: #selector(captureImageTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc
    fileprivate func captureImageTapped() {
        print("Capture Image button tapped")
        let captureImageVC = CaptureImageViewController()
        present(captureImageVC, animated: true, completion: nil)
    }
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

