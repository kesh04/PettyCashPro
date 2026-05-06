//
//  ReceiptScannerView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-05-07.
//


import SwiftUI
import AVFoundation
import Vision
import UIKit



struct ScannedReceiptData {
    var merchantName: String = ""
    var amount: String       = ""
    var date: String         = ""
    var image: UIImage?      = nil
}



struct ReceiptScannerView: View {

    @Environment(\.dismiss) var dismiss
    var onScanComplete: (ScannedReceiptData) -> Void

    @State private var isScanning      = true
    @State private var isProcessing    = false
    @State private var scannedData     = ScannedReceiptData()
    @State private var showResults     = false
    @State private var flashOn         = false
    @State private var scanError: String? = nil

    var body: some View {
        ZStack {

        
            if isScanning {
                CameraPreviewView(
                    flashOn: $flashOn,
                    onCapture: { image in
                        isScanning   = false
                        isProcessing = true
                        processReceiptImage(image)
                    }
                )
                .ignoresSafeArea()

                VStack {
      
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                        Spacer()
                        Text("Scan Receipt")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Button { flashOn.toggle() } label: {
                            Image(systemName: flashOn ? "bolt.fill" : "bolt.slash.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(flashOn ? .yellow : .white)
                                .padding(12)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)

                    Spacer()

                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 300, height: 420)
                        .overlay(
                            VStack {
                                Spacer()
                                Text("Position receipt inside the frame")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.black.opacity(0.5))
                                    .cornerRadius(20)
                                    .padding(.bottom, 16)
                            }
                        )

                    Spacer()

                    Button {
                        NotificationCenter.default.post(name: .capturePhoto, object: nil)
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 72, height: 72)
                            Circle()
                                .stroke(Color.white.opacity(0.4), lineWidth: 4)
                                .frame(width: 84, height: 84)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }

            if isProcessing {
                Color.black.opacity(0.85).ignoresSafeArea()
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    Text("Scanning receipt...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    Text("Vision framework is extracting\nmerchant name, amount, and date")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
            }

            if showResults {
                Color.bgPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {

                        if let img = scannedData.image {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 220)
                                .cornerRadius(16)
                                .padding(.horizontal, 20)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            Text("EXTRACTED DATA")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.textSecondary)
                                .tracking(0.8)
                                .padding(.horizontal, 20)

                            VStack(spacing: 1) {
                                ScannedDataRow(
                                    icon: "building.2.fill",
                                    label: "Merchant",
                                    value: scannedData.merchantName.isEmpty
                                        ? "Not detected" : scannedData.merchantName,
                                    color: .primaryBlue,
                                    detected: !scannedData.merchantName.isEmpty
                                )
                                ScannedDataRow(
                                    icon: "banknote.fill",
                                    label: "Amount",
                                    value: scannedData.amount.isEmpty
                                        ? "Not detected" : "LKR \(scannedData.amount)",
                                    color: .approvedColor,
                                    detected: !scannedData.amount.isEmpty
                                )
                                ScannedDataRow(
                                    icon: "calendar",
                                    label: "Date",
                                    value: scannedData.date.isEmpty
                                        ? "Not detected" : scannedData.date,
                                    color: .accentOrange,
                                    detected: !scannedData.date.isEmpty
                                )
                            }
                            .background(Color.bgCard)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                            .padding(.horizontal, 20)
                        }

                        if let error = scanError {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.accentOrange)
                                Text(error)
                                    .font(.system(size: 13))
                                    .foregroundColor(.textSecondary)
                            }
                            .padding(14)
                            .background(Color.accentOrange.opacity(0.08))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }

                        VStack(spacing: 12) {
                            Button {
                                onScanComplete(scannedData)
                                dismiss()
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18))
                                    Text("Use Extracted Data")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(
                                    LinearGradient(
                                        colors: [Color.primaryBlue, Color.darkBlue],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .cornerRadius(14)
                            }

                            Button {
                                scannedData  = ScannedReceiptData()
                                showResults  = false
                                isProcessing = false
                                scanError    = nil
                                isScanning   = true
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 16))
                                    Text("Scan Again")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.primaryBlue)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color.primaryBlue.opacity(0.08))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.primaryBlue.opacity(0.3), lineWidth: 1)
                                )
                            }

                            Button { dismiss() } label: {
                                Text("Cancel")
                                    .font(.system(size: 16))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                    .padding(.top, 30)
                }
                .background(Color.bgPrimary.ignoresSafeArea())
                .overlay(
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.textSecondary)
                            .padding(20)
                    },
                    alignment: .topTrailing
                )
            }
        }
    }



    private func processReceiptImage(_ image: UIImage) {
        scannedData.image = image

        guard let cgImage = image.cgImage else {
            DispatchQueue.main.async {
                self.scanError    = "Could not process image."
                self.isProcessing = false
                self.showResults  = true
            }
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                DispatchQueue.main.async {
                    self.scanError    = "Text recognition failed. Try better lighting."
                    self.isProcessing = false
                    self.showResults  = true
                }
                return
            }

            let lines = observations.compactMap { $0.topCandidates(1).first?.string }

            DispatchQueue.main.async {
                self.scannedData.merchantName = self.extractMerchantName(from: lines)
                self.scannedData.amount       = self.extractAmount(from: lines)
                self.scannedData.date         = self.extractDate(from: lines)

                if self.scannedData.merchantName.isEmpty &&
                   self.scannedData.amount.isEmpty &&
                   self.scannedData.date.isEmpty {
                    self.scanError = "Could not extract data. Try scanning in better lighting."
                }

                self.isProcessing = false
                self.showResults  = true
            }
        }

        request.recognitionLevel       = .accurate
        request.recognitionLanguages   = ["en-US"]
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }



    private func extractMerchantName(from lines: [String]) -> String {
        let skip = ["receipt", "invoice", "tax", "vat", "total", "subtotal",
                    "cash", "change", "balance", "thank", "welcome",
                    "date", "time", "tel", "phone", "www", "http"]
        for line in lines.prefix(8) {
            let clean = line.trimmingCharacters(in: .whitespaces)
            let lower = clean.lowercased()
            if clean.count < 3 { continue }
            if clean.allSatisfy({ $0.isNumber || $0 == "." || $0 == "," || $0 == " " }) { continue }
            if skip.contains(where: { lower.contains($0) }) { continue }
            return clean
        }
        return ""
    }



    private func extractAmount(from lines: [String]) -> String {
        let keywords = ["grand total", "total amount", "net total",
                        "total", "amount due", "amount", "subtotal"]
        for keyword in keywords {
            for (i, line) in lines.enumerated() {
                if line.lowercased().contains(keyword) {
                    let candidates = [line, i + 1 < lines.count ? lines[i + 1] : ""]
                    for c in candidates {
                        if let amount = extractNumber(from: c) { return amount }
                    }
                }
            }
        }
        var largest: Double = 0
        var largestStr      = ""
        for line in lines {
            if let num = extractNumber(from: line),
               let val = Double(num.replacingOccurrences(of: ",", with: "")),
               val > largest {
                largest    = val
                largestStr = num
            }
        }
        return largestStr
    }



    private func extractDate(from lines: [String]) -> String {
        let patterns = [
            #"(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{2,4})"#,
            #"(\d{4})[\/\-\.](\d{1,2})[\/\-\.](\d{1,2})"#,
            #"(\d{1,2})\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+(\d{2,4})"#,
            #"(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+(\d{1,2}),?\s+(\d{4})"#
        ]
        for line in lines {
            for pattern in patterns {
                if let range = line.range(of: pattern, options: .regularExpression) {
                    return String(line[range])
                }
            }
        }
        return ""
    }



    private func extractNumber(from text: String) -> String? {
        guard let range = text.range(of: #"[\d,]+\.?\d{0,2}"#, options: .regularExpression) else {
            return nil
        }
        let numStr = String(text[range]).replacingOccurrences(of: ",", with: "")
        guard let val = Double(numStr), val > 0 else { return nil }
        return numStr
    }
}



struct ScannedDataRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    let detected: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.12))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .tracking(0.6)
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(detected ? .textPrimary : .textSecondary.opacity(0.5))
                    .italic(!detected)
            }
            Spacer()
            if detected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.approvedColor)
                    .font(.system(size: 16))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.bgCard)
    }
}



struct CameraPreviewView: UIViewControllerRepresentable {
    @Binding var flashOn: Bool
    var onCapture: (UIImage) -> Void

    func makeUIViewController(context: Context) -> CameraViewController {
        let vc       = CameraViewController()
        vc.onCapture = onCapture
        return vc
    }

    func updateUIViewController(_ vc: CameraViewController, context: Context) {
        vc.setFlash(on: flashOn)
    }
}


class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    var onCapture: ((UIImage) -> Void)?

    private var session      = AVCaptureSession()
    private var photoOutput  = AVCapturePhotoOutput()
    private var previewLayer : AVCaptureVideoPreviewLayer?
    private var device       : AVCaptureDevice?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(capturePhoto),
            name: .capturePhoto,
            object: nil
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.stopRunning()
    }

    private func setupCamera() {
        session.sessionPreset = .photo
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        self.device = device
        if session.canAddInput(input)        { session.addInput(input) }
        if session.canAddOutput(photoOutput) { session.addOutput(photoOutput) }

        let preview            = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity   = .resizeAspectFill
        preview.frame          = view.bounds
        view.layer.addSublayer(preview)
        previewLayer           = preview

        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }

    func setFlash(on: Bool) {
        guard let device = device, device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }

    @objc func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard error == nil,
              let data  = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        onCapture?(image)
    }
}



extension Notification.Name {
    static let capturePhoto = Notification.Name("capturePhoto")
}
