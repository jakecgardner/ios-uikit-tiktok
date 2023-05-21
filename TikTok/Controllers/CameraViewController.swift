//
//  CameraViewController.swift
//  TikTok
//
//  Created by jake on 4/6/23.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    var captureSession = AVCaptureSession()
    var videoDevice: AVCaptureDevice?
    var videoOutput = AVCaptureMovieFileOutput()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var recordedPlayerLayer: AVPlayerLayer?
    var recordedVideoURL: URL?
    
    private let cameraView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.clipsToBounds = true
        return view
    }()
    
    private let recordButton = RecordButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        
        setupCamera()
        
        view.addSubview(recordButton)
        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -160),
            recordButton.heightAnchor.constraint(equalToConstant: 120),
            recordButton.widthAnchor.constraint(equalToConstant: 120),
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    @objc private func didTapClose() {
        navigationItem.rightBarButtonItem = nil
        recordButton.isHidden = false
        
        if let _ = recordedPlayerLayer {
            recordedPlayerLayer?.removeFromSuperlayer()
            recordedPlayerLayer = nil
        } else {
            captureSession.stopRunning()
            tabBarController?.tabBar.isHidden = false
            tabBarController?.selectedIndex = 0
        }
    }
    
    @objc private func didTapRecord() {
        if videoOutput.isRecording {
            videoOutput.stopRecording()
            recordButton.toggle(for: .stopped)
        } else {
            guard var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            url.appendPathComponent("video.mov")
            try? FileManager.default.removeItem(at: url)
            videoOutput.startRecording(to: url, recordingDelegate: self)
            recordButton.toggle(for: .recording)
        }
    }
    
    func setupCamera() {
        view.addSubview(cameraView)
        cameraView.frame = view.bounds
        
        if let audioDevice = AVCaptureDevice.default(for: .audio) {
            if let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
               captureSession.canAddInput(audioInput) {
                captureSession.addInput(audioInput)
            }
        }
        
        if let videoDevice = AVCaptureDevice.default(for: .video) {
            if let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
               captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
        }
        
        captureSession.sessionPreset = .hd1280x720
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = view.bounds
        
        if let videoLayer = videoPreviewLayer {
            cameraView.layer.addSublayer(videoLayer)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard error == nil else {
            let alert = UIAlertController(title: "Oops", message: "Something went wrong", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        print("Finished recording to \(outputFileURL.absoluteString)")
        
        recordedVideoURL = outputFileURL
        
        UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
            
        let player = AVPlayer(url: outputFileURL)
        recordedPlayerLayer = AVPlayerLayer(player: player)
        if let preview = recordedPlayerLayer {
            preview.videoGravity = .resizeAspectFill
            preview.frame = cameraView.bounds
            cameraView.layer.addSublayer(preview)
            recordedPlayerLayer?.player?.play()
            recordButton.isHidden = true
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(didTapNext))
    }
    
    @objc private func didTapNext() {
        guard let url = recordedVideoURL else {
            return
        }
        
        let captionVc = CaptionViewController(with: url)
        navigationController?.pushViewController(captionVc, animated: true)
    }
}
