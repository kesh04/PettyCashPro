//
//  ATMLocation.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//

import SwiftUI
import MapKit
import CoreLocation


struct ATMFinderView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
    )
    @State private var selectedATM: ATMLocation? = nil
    @State private var showList = false

   
    let atmLocations: [ATMLocation] = [
        ATMLocation(name: "Peoples Bank ATM", bank: "Peoples Bank",
                    coordinate: CLLocationCoordinate2D(latitude: 6.9284, longitude: 79.8619), distance: 0.15),
        ATMLocation(name: "Commercial Bank ATM", bank: "Commercial Bank",
                    coordinate: CLLocationCoordinate2D(latitude: 6.9260, longitude: 79.8635), distance: 0.31),
        ATMLocation(name: "BOC ATM - Fort", bank: "Bank of Ceylon",
                    coordinate: CLLocationCoordinate2D(latitude: 6.9305, longitude: 79.8580), distance: 0.44),
        ATMLocation(name: "HNB ATM", bank: "Hatton National Bank",
                    coordinate: CLLocationCoordinate2D(latitude: 6.9248, longitude: 79.8600), distance: 0.58),
        ATMLocation(name: "Sampath Bank ATM", bank: "Sampath Bank",
                    coordinate: CLLocationCoordinate2D(latitude: 6.9291, longitude: 79.8655), distance: 0.72),
        ATMLocation(name: "Nations Trust ATM", bank: "Nations Trust Bank",
                    coordinate: CLLocationCoordinate2D(latitude: 6.9240, longitude: 79.8640), distance: 0.90),
        ATMLocation(name: "DFCC Bank ATM", bank: "DFCC Bank",
                    coordinate: CLLocationCoordinate2D(latitude: 6.9318, longitude: 79.8598), distance: 1.10),
    ]

    var sortedATMs: [ATMLocation] {
        atmLocations.sorted { $0.distance < $1.distance }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
     
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Nearby ATMs")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.textPrimary)
                        Text("Find cash near you")
                            .font(.system(size: 13))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.4)) { showList.toggle() }
                    } label: {
                        Image(systemName: showList ? "map.fill" : "list.bullet")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.primaryBlue)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, AppDesign.screenPadding)
                .padding(.top, 20)
                .padding(.bottom, 14)

        
                if let nearest = sortedATMs.first {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.accentGreen.opacity(0.15))
                                .frame(width: 40, height: 40)
                            Image(systemName: "location.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.accentGreen)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Nearest: \(nearest.name)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.textPrimary)
                            Text("\(nearest.formattedDistance) away · \(nearest.bank)")
                                .font(.system(size: 12))
                                .foregroundColor(.textSecondary)
                        }
                        Spacer()
                        Button("Directions") {
                            openInMaps(atm: nearest)
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.accentGreen)
                        .cornerRadius(10)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                    .padding(.horizontal, AppDesign.screenPadding)
                    .padding(.bottom, 12)
                }

                if showList {
                    // List view
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(sortedATMs) { atm in
                                ATMListRow(atm: atm, isSelected: selectedATM?.id == atm.id) {
                                    withAnimation { selectedATM = atm }
                                }
                                .padding(.horizontal, AppDesign.screenPadding)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.bottom, 20)
                    }
                } else {
        
                    ZStack(alignment: .bottom) {
                        Map(coordinateRegion: $region, annotationItems: atmLocations) { atm in
                            MapAnnotation(coordinate: atm.coordinate) {
                                ATMMapPin(atm: atm, isSelected: selectedATM?.id == atm.id) {
                                    withAnimation { selectedATM = atm }
                                }
                            }
                        }
                        .cornerRadius(16)
                        .padding(.horizontal, AppDesign.screenPadding)

                       
                        if let selected = selectedATM {
                            ATMDetailCard(atm: selected) {
                                openInMaps(atm: selected)
                            } onDismiss: {
                                withAnimation { selectedATM = nil }
                            }
                            .padding(.horizontal, AppDesign.screenPadding)
                            .padding(.bottom, 20)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
            }
            .background(Color.bgPrimary.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private func openInMaps(atm: ATMLocation) {
        let coordinate = atm.coordinate
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = atm.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}


struct ATMMapPin: View {
    let atm: ATMLocation
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.primaryBlue : Color.white)
                        .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    Image(systemName: "banknote.fill")
                        .font(.system(size: isSelected ? 18 : 14))
                        .foregroundColor(isSelected ? .white : .primaryBlue)
                }
        
                Triangle()
                    .fill(isSelected ? Color.primaryBlue : Color.white)
                    .frame(width: 10, height: 8)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}


struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}


struct ATMListRow: View {
    let atm: ATMLocation
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.primaryBlue : Color.primaryBlue.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: "banknote.fill")
                        .font(.system(size: 18))
                        .foregroundColor(isSelected ? .white : .primaryBlue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(atm.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    Text(atm.bank)
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(atm.formattedDistance)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primaryBlue)
                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.accentGreen)
                        Text("Available")
                            .font(.system(size: 11))
                            .foregroundColor(.accentGreen)
                    }
                }
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.primaryBlue : Color.clear, lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}


struct ATMDetailCard: View {
    let atm: ATMLocation
    let onDirections: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(atm.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.textPrimary)
                    Text(atm.bank)
                        .font(.system(size: 13))
                        .foregroundColor(.textSecondary)
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.primaryBlue)
                        Text(atm.formattedDistance + " away")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primaryBlue)
                    }
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(Color.bgPrimary)
                        .cornerRadius(14)
                }
            }

            Divider().padding(.vertical, 12)

            Button(action: onDirections) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.system(size: 16))
                    Text("Get Directions in Maps")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    LinearGradient(colors: [Color.primaryBlue, Color.darkBlue],
                                   startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 8)
    }
}
