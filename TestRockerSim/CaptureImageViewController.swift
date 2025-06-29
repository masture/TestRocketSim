//
//  PhotoBoothViewController.swift
//  TestRockerSim
//
//  Created by Pankaj Kulkarni on 29/6/25.
//


import UIKit
import AVFoundation

class CaptureImageViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let photoOutput = AVCapturePhotoOutput()
    private let imageStackView = UIStackView()
    private let captureButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
        setupUI()
    }

    private func setupCamera() {
        captureSession.sessionPreset = .photo
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: frontCamera),
              captureSession.canAddInput(input) else { return }
        captureSession.addInput(input)
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        captureSession.startRunning()
    }

    private func setupUI() {
        // Image stack view
        imageStackView.axis = .horizontal
        imageStackView.alignment = .center
        imageStackView.distribution = .equalSpacing
        imageStackView.spacing = 8
        imageStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageStackView)

        // Capture button
        captureButton.setTitle("📸", for: .normal)
        captureButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
        captureButton.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        captureButton.layer.cornerRadius = 32
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        view.addSubview(captureButton)

        // Constraints
        NSLayoutConstraint.activate([
            imageStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            imageStackView.heightAnchor.constraint(equalToConstant: 64),

            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: imageStackView.topAnchor, constant: -24),
            captureButton.widthAnchor.constraint(equalToConstant: 64),
            captureButton.heightAnchor.constraint(equalToConstant: 64)
        ])
    }

    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 64),
            imageView.heightAnchor.constraint(equalToConstant: 64)
        ])
        imageStackView.addArrangedSubview(imageView)
    }
}
