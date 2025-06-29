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
    private let scrollView = UIScrollView()
    private let closeButton = UIButton(type: .system)
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        setupCloseButton()
        setupCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.captureSession.stopRunning()
            for input in self.captureSession.inputs {
                self.captureSession.removeInput(input)
            }
            for output in self.captureSession.outputs {
                self.captureSession.removeOutput(output)
            }
            DispatchQueue.main.async {
                self.previewLayer?.session = nil
                self.previewLayer?.removeFromSuperlayer()
            }
        }
    }
    
    private func setupCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .photo
            guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                  let input = try? AVCaptureDeviceInput(device: frontCamera),
                  self.captureSession.canAddInput(input) else { return }
            self.captureSession.addInput(input)
            if self.captureSession.canAddOutput(self.photoOutput) {
                self.captureSession.addOutput(self.photoOutput)
            }
            self.captureSession.commitConfiguration()
            DispatchQueue.main.async {
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                self.previewLayer.videoGravity = .resizeAspectFill
                self.previewLayer.frame = self.view.bounds
                self.view.layer.insertSublayer(self.previewLayer, at: 0)
            }
            self.captureSession.startRunning()
        }
    }
    
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = true
        view.addSubview(scrollView)
        
        imageStackView.axis = .horizontal
        imageStackView.alignment = .center
        imageStackView.distribution = .equalSpacing
        imageStackView.spacing = 8
        imageStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(imageStackView)
        
        captureButton.setTitle("📸", for: .normal)
        captureButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
        captureButton.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        captureButton.layer.cornerRadius = 32
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        view.addSubview(captureButton)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            scrollView.heightAnchor.constraint(equalToConstant: 64),
            
            imageStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: scrollView.topAnchor, constant: -24),
            captureButton.widthAnchor.constraint(equalToConstant: 64),
            captureButton.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    private func setupCloseButton() {
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        closeButton.layer.cornerRadius = 22
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        
        // 1. Create a snapshot view of the captured image for animation
        let snapshotView = UIImageView(image: image)
        snapshotView.image = image
        snapshotView.contentMode = .scaleAspectFill
        snapshotView.frame = view.bounds
        snapshotView.layer.masksToBounds = true
        view.addSubview(snapshotView)
        
        // 2. Prepare the target frame in the stack view
        let targetFrameInStack = imageStackView.convert(CGRect(x: 0, y: 0, width: 64, height: 64), to: view)
        
        // 3. Animate existing images to the right
        let shiftDistance: CGFloat = 72 // 64 + 8 spacing
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            for (_, subview) in self.imageStackView.arrangedSubviews.enumerated() {
                subview.transform = CGAffineTransform(translationX: shiftDistance, y: 0)
            }
        }, completion: nil)
        
        // 4. Animate the snapshot shrinking to the leftmost slot
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            snapshotView.frame = targetFrameInStack
            snapshotView.layer.cornerRadius = 8
        }, completion: { _ in
            // 5. Insert the new image view at index 0
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 8
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 64),
                imageView.heightAnchor.constraint(equalToConstant: 64)
            ])
            self.imageStackView.insertArrangedSubview(imageView, at: 0)
            
            // 6. Remove the snapshot and reset transforms
            snapshotView.removeFromSuperview()
            for subview in self.imageStackView.arrangedSubviews {
                subview.transform = .identity
            }
        })
    }
}
