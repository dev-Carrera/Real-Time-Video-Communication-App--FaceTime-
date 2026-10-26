//
//  CameraViewController.swift
//  FaceTime
//
//  Created by Raul Carrera on 6/10/26.
//

import AVFoundation

#if os(iOS)
import UIKit

class iOSCameraViewController: UIViewController {

    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?

    func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }

        session.addInput(input)

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        view.layer.addSublayer(preview)

        self.captureSession = session
        self.previewLayer = preview

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
}

#elseif os(macOS)
import AppKit

class MacCameraViewController: NSViewController {

    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?

    override func loadView() {
        // Give the controller a view since it's created programmatically
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 640, height: 480))
        self.view.wantsLayer = true
    }

    func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("Unable to access camera")
            return
        }

        session.addInput(input)

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds

        // Mirror the preview (like a selfie/mirror view)
        preview.connection?.automaticallyAdjustsVideoMirroring = false
        preview.connection?.isVideoMirrored = true

        view.layer = CALayer()
        view.layer?.addSublayer(preview)

        self.captureSession = session
        self.previewLayer = preview

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        previewLayer?.frame = view.bounds
    }
}

#endif
