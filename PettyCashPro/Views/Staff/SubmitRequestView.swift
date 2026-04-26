//
//  SubmitRequestView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//

import SwiftUI
import PhotosUI

struct SubmitRequestView: View {
    @EnvironmentObject var staffVM: StaffViewModel
    @State private var showReceiptScanner = false
    @State private var showManualEntry = false
    @State private var manualToggle = false
    @State private var scannedReceipt = false
    

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

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

         
                    VStack(spacing: 20) {
                        VStack(spacing: 16) {
                       
                            VStack(alignment: .leading, spacing: 8) {
                                Text("AMOUNT (LKR)")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.textSecondary)
                                    .tracking(0.8)
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
                                Text("REASON")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.textSecondary)
                                    .tracking(0.8)

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
                                }
                                .background(Color.bgPrimary)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borderColor, lineWidth: 1))
                            }

     
                            VStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color.bgPrimary)
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
                                                    selectedImage = nil
                                                    selectedImageData = nil
                                                    scannedReceipt = false
                                                }) {
                                                    Label("Remove", systemImage: "trash")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(.red)
                                                }
                                                
                                                Button(action: {
                                                    showImagePickerOptions()
                                                }) {
                                                    Label("Change", systemImage: "arrow.2.circlepath")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(.primaryBlue)
                                                }
                                            }
                                        }
                                        .padding(20)
                                    } else if scannedReceipt {
                                   
                                        VStack(spacing: 14) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 48))
                                                .foregroundColor(.approvedColor)
                                            Text("Receipt Scanned!")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.approvedColor)
                                            Text("Amount auto-filled from receipt")
                                                .font(.system(size: 13))
                                                .foregroundColor(.textSecondary)
                                        }
                                        .padding(.vertical, 32)
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
                                                    sourceType = .camera
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
                                                    sourceType = .photoLibrary
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
                                    if selectedImage == nil && !scannedReceipt {
                                        showImagePickerOptions()
                                    }
                                }
                            }
                            
                     
                            Button {
                           
                                staffVM.submitRequestWithImage(imageData: selectedImageData)
                            } label: {
                                HStack(spacing: 10) {
                                    if staffVM.isSubmitting {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "paperplane.fill")
                                            .font(.system(size: 16))
                                        Text("Submit Request")
                                            .font(.system(size: 17, weight: .semibold))
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(
                                    LinearGradient(colors: [Color.primaryBlue, Color.darkBlue],
                                                   startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(14)
                                .shadow(color: Color.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .disabled(staffVM.amount.isEmpty || staffVM.reason.isEmpty)
                            .opacity((staffVM.amount.isEmpty || staffVM.reason.isEmpty) ? 0.5 : 1)
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    .padding(.horizontal, AppDesign.screenPadding)
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: manualToggle)
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: scannedReceipt)
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: selectedImage)

                    Spacer().frame(height: 40)
                }
            }
            .background(Color.bgPrimary.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $staffVM.showSubmitSuccess) {
                SubmitSuccessSheet()
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(sourceType: sourceType, selectedImage: $selectedImage, selectedImageData: $selectedImageData, scannedReceipt: $scannedReceipt)
            }
        }
    }
    
    private func showImagePickerOptions() {
    
        let alert = UIAlertController(title: "Upload Receipt", message: "Choose source", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            sourceType = .camera
            isShowingImagePicker = true
        })
        alert.addAction(UIAlertAction(title: "Gallery", style: .default) { _ in
            sourceType = .photoLibrary
            isShowingImagePicker = true
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(alert, animated: true)
        }
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
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                parent.selectedImage = image
                parent.selectedImageData = image.jpegData(compressionQuality: 0.8)
                parent.scannedReceipt = true
                
            } else if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.selectedImageData = image.jpegData(compressionQuality: 0.8)
                parent.scannedReceipt = true
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}


extension StaffViewModel {
    func submitRequestWithImage(imageData: Data?) {
        // Your existing submit logic
        // Add imageData to your Firestore document or API call
        
        // Example of how you might upload the image:
        // if let imageData = imageData {
        //     uploadImageToStorage(imageData) { imageURL in
        //         self.submitRequestWithImageURL(imageURL)
        //     }
        // } else {
        //     self.submitRequest()
        // }
        
  
        self.submitRequest()
        
        // You can also store the image in your view model
        // self.receiptImageData = imageData
    }
}

struct CategoryChip: View {
    let category: ExpenseCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 13))
                Text(category.rawValue)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? Color.primaryBlue : Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.primaryBlue : Color.borderColor, lineWidth: 1)
            )
        }
    }
}

struct SubmitSuccessSheet: View {
    @EnvironmentObject var staffVM: StaffViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.approvedColor.opacity(0.15))
                    .frame(width: 100, height: 100)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.approvedColor)
            }

            VStack(spacing: 8) {
                Text("Request Submitted!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.textPrimary)
                Text("Your manager will be notified\nand will review your request shortly.")
                    .font(.system(size: 15))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button {
                staffVM.showSubmitSuccess = false
            } label: {
                Text("Done")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.primaryBlue)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .padding(.top, 40)
    }
}

// Preview
#Preview {
    SubmitRequestView()
        .environmentObject(StaffViewModel())
}
