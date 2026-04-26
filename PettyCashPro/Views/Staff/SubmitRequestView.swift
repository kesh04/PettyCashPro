//
//  SubmitRequestView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//

import SwiftUI

struct SubmitRequestView: View {
    @EnvironmentObject var staffVM: StaffViewModel
    @State private var showReceiptScanner = false
    @State private var showManualEntry = false
    @State private var manualToggle = false
    @State private var scannedReceipt = false

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

                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color.bgPrimary)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                                                .foregroundColor(Color.borderColor)
                                        )

                                    VStack(spacing: 14) {
                                        if scannedReceipt {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 48))
                                                .foregroundColor(.approvedColor)
                                            Text("Receipt Scanned!")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.approvedColor)
                                            Text("Amount auto-filled from receipt")
                                                .font(.system(size: 13))
                                                .foregroundColor(.textSecondary)
                                        } else {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.primaryBlue.opacity(0.1))
                                                    .frame(width: 72, height: 72)
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 28))
                                                    .foregroundColor(.primaryBlue)
                                            }
                                            Text("Upload Image")
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundColor(.textSecondary)
                                                .tracking(1)
                                        }
                                    }
                                    .padding(.vertical, 32)
                                }
                                .frame(height: 200)
                           
                                .onTapGesture {
                                    withAnimation(.spring()) { scannedReceipt = true }
                                    if !staffVM.amount.isEmpty { return }
                                    staffVM.amount = "2400"
                                }
                      
                                Button {
                                    staffVM.submitRequest()
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
                    }
                    .padding(.horizontal, AppDesign.screenPadding)
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: manualToggle)
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: scannedReceipt)

                    Spacer().frame(height: 40)
                }
            }
            .background(Color.bgPrimary.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $staffVM.showSubmitSuccess) {
                SubmitSuccessSheet()
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
