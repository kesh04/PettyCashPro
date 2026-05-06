//
//  SubmitRequestView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//

import SwiftUI
import PhotosUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}

struct SubmitRequestView: View {

    @Binding var selectedTab: Int
    @EnvironmentObject var staffVM: StaffViewModel

    @State private var scannedReceipt       = false
    @State private var selectedImageData: Data?
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showSourcePicker     = false
    @State private var showReceiptScanner   = false
    @State private var showScanBadge        = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    Text("New Request")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppDesign.screenPadding)
                        .padding(.top, 20)
                        .padding(.bottom, 24)

                    VStack(spacing: 16) {

                        Button {
                            hideKeyboard()
                            showReceiptScanner = true
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.primaryBlue.opacity(0.12))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "viewfinder.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.primaryBlue)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Scan Receipt")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.textPrimary)
                                    Text("Auto-fill amount & date using Vision AI")
                                        .font(.system(size: 12))
                                        .foregroundColor(.textSecondary)
                                }
                                Spacer()
                                if showScanBadge {
                                    Text("Auto-filled ✓")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.approvedColor)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.approvedColor.opacity(0.1))
                                        .cornerRadius(8)
                                } else {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.textSecondary)
                                }
                            }
                            .padding(14)
                            .background(Color.bgCard)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        showScanBadge
                                            ? Color.approvedColor.opacity(0.4)
                                            : Color.primaryBlue.opacity(0.3),
                                        lineWidth: 1.5
                                    )
                            )
                        }
                        .buttonStyle(.plain)

      
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("AMOUNT (LKR)")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.textSecondary)
                                    .tracking(0.8)
                                if showScanBadge && !staffVM.amount.isEmpty {
                                    Text("✓ scanned")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.approvedColor)
                                }
                            }
                            InputField(placeholder: "Rs 0.00",
                                       text: $staffVM.amount,
                                       keyboardType: .decimalPad)
                        }

     
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CATEGORY")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.textSecondary)
                                .tracking(0.8)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(ExpenseCategory.allCases) { category in
                                        CategoryChip(
                                            category: category,
                                            isSelected: staffVM.selectedCategory == category
                                        ) {
                                            staffVM.selectedCategory = category
                                        }
                                    }
                                }
                                .padding(.horizontal, 2)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("REASON")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.textSecondary)
                                    .tracking(0.8)
                                if showScanBadge && !staffVM.reason.isEmpty {
                                    Text("✓ scanned")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.approvedColor)
                                }
                            }
                            ZStack(alignment: .topLeading) {
                                if staffVM.reason.isEmpty {
                                    Text("Explain the purpose of this expense...")
                                        .font(.system(size: 16))
                                        .foregroundColor(.textSecondary.opacity(0.6))
                                        .padding(16)
                                }
                                TextEditor(text: $staffVM.reason)
                                    .font(.system(size: 16))
                                    .frame(height: 100)
                                    .padding(12)
                                    .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Spacer()
                                            Button("Done") { hideKeyboard() }
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primaryBlue)
                                        }
                                    }
                            }
                            .background(Color.bgCard)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borderColor, lineWidth: 1))
                        }

                        PriorityToggleCard(isUrgent: $staffVM.isUrgent)

                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.bgCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                                        .foregroundColor(Color.borderColor)
                                )

                            if let image = selectedImage {
                                VStack(spacing: 12) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 120)
                                        .cornerRadius(12)
                                    HStack(spacing: 20) {
                                        Button(action: {
                                            selectedImage     = nil
                                            selectedImageData = nil
                                            scannedReceipt    = false
                                            showScanBadge     = false
                                        }) {
                                            Label("Remove", systemImage: "trash")
                                                .font(.system(size: 14))
                                                .foregroundColor(.red)
                                        }
                                        Button(action: {
                                            hideKeyboard()
                                            showSourcePicker = true
                                        }) {
                                            Label("Change", systemImage: "arrow.2.circlepath")
                                                .font(.system(size: 14))
                                                .foregroundColor(.primaryBlue)
                                        }
                                    }
                                }
                                .padding(20)
                            } else {
                                VStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.primaryBlue.opacity(0.1))
                                            .frame(width: 72, height: 72)
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(.primaryBlue)
                                    }
                                    Text("Tap to Upload Receipt")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.textSecondary)
                                        .tracking(1)
                                    HStack(spacing: 16) {
                                        Button(action: {
                                            hideKeyboard()
                                            sourceType           = .camera
                                            isShowingImagePicker = true
                                        }) {
                                            Label("Camera", systemImage: "camera")
                                                .font(.system(size: 12))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.primaryBlue.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                        Button(action: {
                                            hideKeyboard()
                                            sourceType           = .photoLibrary
                                            isShowingImagePicker = true
                                        }) {
                                            Label("Gallery", systemImage: "photo")
                                                .font(.system(size: 12))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.primaryBlue.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(.vertical, 32)
                            }
                        }
                        .frame(height: selectedImage != nil ? 220 : 200)
                        .onTapGesture {
                            if selectedImage == nil {
                                hideKeyboard()
                                showSourcePicker = true
                            }
                        }

                        Button {
                            hideKeyboard()
                            staffVM.submitRequestWithImage(imageData: selectedImageData)
                        } label: {
                            HStack(spacing: 10) {
                                if staffVM.isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: staffVM.isUrgent ? "bolt.fill" : "paperplane.fill")
                                        .font(.system(size: 16))
                                    Text(staffVM.isUrgent ? "Submit Urgent Request" : "Submit Request")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    colors: staffVM.isUrgent
                                        ? [Color(hex: "#FF6B35"), Color(hex: "#E84E0F")]
                                        : [Color.primaryBlue, Color.darkBlue],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                            .shadow(
                                color: (staffVM.isUrgent ? Color(hex: "#FF6B35") : Color.primaryBlue).opacity(0.3),
                                radius: 8, x: 0, y: 4
                            )
                        }
                        .disabled(staffVM.amount.isEmpty || staffVM.reason.isEmpty)
                        .opacity((staffVM.amount.isEmpty || staffVM.reason.isEmpty) ? 0.5 : 1)
                    }
                    .padding(.horizontal, AppDesign.screenPadding)
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: staffVM.isUrgent)
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: selectedImage)

                    Spacer().frame(height: 40)
                }
            }
            .onTapGesture { hideKeyboard() }
            .background(Color.bgPrimary.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        hideKeyboard()
                        selectedTab = 0
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 17))
                        }
                        .foregroundColor(.primaryBlue)
                    }
                }
            }
            .confirmationDialog("Upload Receipt", isPresented: $showSourcePicker, titleVisibility: .visible) {
                Button("Camera") {
                    sourceType           = .camera
                    isShowingImagePicker = true
                }
                Button("Photo Library") {
                    sourceType           = .photoLibrary
                    isShowingImagePicker = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $staffVM.showSubmitSuccess) {
                SubmitSuccessSheet()
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(
                    sourceType: sourceType,
                    selectedImage: $selectedImage,
                    selectedImageData: $selectedImageData,
                    scannedReceipt: $scannedReceipt
                )
            }
     
            .fullScreenCover(isPresented: $showReceiptScanner) {
                ReceiptScannerView { scannedData in
                    if !scannedData.amount.isEmpty {
                        staffVM.amount = scannedData.amount
                    }
                    if !scannedData.merchantName.isEmpty {
                        staffVM.reason = scannedData.merchantName
                        if !scannedData.date.isEmpty {
                            staffVM.reason += " - \(scannedData.date)"
                        }
                    }
                    if let image = scannedData.image {
                        selectedImage     = image
                        selectedImageData = image.jpegData(compressionQuality: 0.8)
                    }
                    withAnimation { showScanBadge = true }
                }
            }
        }
    }
}


struct PriorityToggleCard: View {
    @Binding var isUrgent: Bool

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { isUrgent.toggle() }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isUrgent ? Color(hex: "#FF6B35").opacity(0.12) : Color.bgCard)
                        .frame(width: 44, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isUrgent ? Color(hex: "#FF6B35").opacity(0.5) : Color.borderColor, lineWidth: 1)
                        )
                    Image(systemName: isUrgent ? "bolt.fill" : "bolt")
                        .font(.system(size: 20))
                        .foregroundColor(isUrgent ? Color(hex: "#FF6B35") : .textSecondary)
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("Priority")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.textPrimary)
                        if isUrgent {
                            Text("URGENT")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color(hex: "#FF6B35"))
                                .padding(.horizontal, 7).padding(.vertical, 3)
                                .background(Color(hex: "#FF6B35").opacity(0.12))
                                .cornerRadius(6)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    Text(isUrgent ? "Manager will be notified immediately"
                                  : "Mark as urgent for immediate attention")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }
                Spacer()
                ZStack {
                    Capsule()
                        .fill(isUrgent ? Color(hex: "#FF6B35") : Color(UIColor.systemGray5))
                        .frame(width: 46, height: 26)
                    Circle()
                        .fill(.white)
                        .frame(width: 20, height: 20)
                        .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                        .offset(x: isUrgent ? 10 : -10)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isUrgent ? Color(hex: "#FF6B35").opacity(0.05) : Color.bgCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isUrgent ? Color(hex: "#FF6B35").opacity(0.5) : Color.borderColor, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    @Binding var selectedImageData: Data?
    @Binding var scannedReceipt: Bool
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType    = sourceType
        picker.delegate      = context.coordinator
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
            if let image = image {
                parent.selectedImage     = image
                parent.selectedImageData = image.jpegData(compressionQuality: 0.8)
                parent.scannedReceipt    = true
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct CategoryChip: View {
    let category: ExpenseCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon).font(.system(size: 13))
                Text(category.rawValue).font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .textPrimary)
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(isSelected ? Color.primaryBlue : Color.bgCard)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.primaryBlue : Color.borderColor, lineWidth: 1))
        }
    }
}


struct SubmitSuccessSheet: View {
    @EnvironmentObject var staffVM: StaffViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle().fill(Color.approvedColor.opacity(0.15)).frame(width: 100, height: 100)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60)).foregroundColor(.approvedColor)
            }
            VStack(spacing: 8) {
                Text("Request Submitted!")
                    .font(.system(size: 24, weight: .bold)).foregroundColor(.textPrimary)
                Text("Your manager will be notified\nand will review your request shortly.")
                    .font(.system(size: 15)).foregroundColor(.textSecondary).multilineTextAlignment(.center)
            }
            Spacer()
            Button { staffVM.showSubmitSuccess = false } label: {
                Text("Done")
                    .font(.system(size: 17, weight: .semibold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 54)
                    .background(Color.primaryBlue).cornerRadius(14)
            }
            .padding(.horizontal, 30).padding(.bottom, 40)
        }
        .padding(.top, 40)
    }
}

#Preview {
    SubmitRequestView(selectedTab: .constant(1))
        .environmentObject(StaffViewModel())
}
