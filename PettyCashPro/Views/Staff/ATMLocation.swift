//
//  ATMLocation.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine



struct EquatableCoordinate: Equatable {
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}



struct NearbyATM: Identifiable {
    let id = UUID()
    let name: String
    let bank: String
    let coordinate: CLLocationCoordinate2D
    let mapItem: MKMapItem
}

class ATMLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: EquatableCoordinate? = nil
    @Published var authStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        let status = manager.authorizationStatus
        authStatus = status
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }
        manager.stopUpdatingLocation()
        DispatchQueue.main.async {
            self.userLocation = EquatableCoordinate(
                latitude: loc.coordinate.latitude,
                longitude: loc.coordinate.longitude
            )
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse ||
               manager.authorizationStatus == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        }
    }
}


struct RouteMapView: UIViewRepresentable {
    var region: MKCoordinateRegion
    var atms: [NearbyATM]
    var selectedATMId: UUID?
    var route: MKRoute?
    var onSelectATM: (NearbyATM) -> Void

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsUserLocation = true
        map.setRegion(region, animated: false)
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        map.setRegion(region, animated: true)


        let existing = map.annotations.compactMap { $0 as? ATMAnnotation }
        let existingIds = Set(existing.map { $0.atmId })
        let newIds = Set(atms.map { $0.id })


        let toRemove = existing.filter { !newIds.contains($0.atmId) }
        map.removeAnnotations(toRemove)

 
        for atm in atms where !existingIds.contains(atm.id) {
            let ann = ATMAnnotation(atm: atm)
            map.addAnnotation(ann)
        }


        for ann in map.annotations.compactMap({ $0 as? ATMAnnotation }) {
            if let view = map.view(for: ann) as? ATMAnnotationView {
                view.setSelected(ann.atmId == selectedATMId, animated: true)
            }
        }


        let existing_overlays = map.overlays.filter { $0 is MKPolyline }
        map.removeOverlays(existing_overlays)
        if let route = route {
            map.addOverlay(route.polyline, level: .aboveRoads)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: RouteMapView
        init(_ parent: RouteMapView) { self.parent = parent }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let atmAnn = annotation as? ATMAnnotation else { return nil }
            let id = "ATMPin"
            let view = (mapView.dequeueReusableAnnotationView(withIdentifier: id) as? ATMAnnotationView)
                ?? ATMAnnotationView(annotation: atmAnn, reuseIdentifier: id)
            view.annotation = atmAnn
            view.setSelected(atmAnn.atmId == parent.selectedATMId, animated: false)
            return view
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor.systemBlue
                renderer.lineWidth = 5
                renderer.lineCap = .round
                renderer.lineJoin = .round
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let atmAnn = view.annotation as? ATMAnnotation else { return }
            parent.onSelectATM(atmAnn.atm)
        }
    }
}


class ATMAnnotation: NSObject, MKAnnotation {
    let atm: NearbyATM
    let atmId: UUID
    var coordinate: CLLocationCoordinate2D { atm.coordinate }
    var title: String? { atm.name }

    init(atm: NearbyATM) {
        self.atm = atm
        self.atmId = atm.id
    }
}

class ATMAnnotationView: MKAnnotationView {
    private let bgCircle = UIView()
    private let iconView = UIImageView()
    private let triangle = UIView()
    private var isATMSelected = false

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        frame = CGRect(x: 0, y: 0, width: 44, height: 52)
        centerOffset = CGPoint(x: 0, y: -26)
        backgroundColor = .clear

        bgCircle.layer.cornerRadius = 18
        bgCircle.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        bgCircle.backgroundColor = UIColor.white
        bgCircle.layer.shadowColor = UIColor.black.cgColor
        bgCircle.layer.shadowOpacity = 0.2
        bgCircle.layer.shadowRadius = 4
        bgCircle.layer.shadowOffset = CGSize(width: 0, height: 2)

        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        iconView.image = UIImage(systemName: "banknote.fill", withConfiguration: config)
        iconView.tintColor = UIColor.systemBlue
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 8, y: 8, width: 20, height: 20)
        bgCircle.addSubview(iconView)


        let triangleLayer = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 5, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 8))
        path.addLine(to: CGPoint(x: 10, y: 8))
        path.close()
        triangleLayer.path = path.cgPath
        triangleLayer.fillColor = UIColor.white.cgColor
        triangle.layer.addSublayer(triangleLayer)
        triangle.frame = CGRect(x: 13, y: 36, width: 10, height: 8)

        addSubview(bgCircle)
        addSubview(triangle)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        isATMSelected = selected
        let color = selected ? UIColor.systemBlue : UIColor.white
        let iconColor = selected ? UIColor.white : UIColor.systemBlue
        let scale: CGFloat = selected ? 1.2 : 1.0

        if animated {
            UIView.animate(withDuration: 0.25) {
                self.bgCircle.backgroundColor = color
                self.iconView.tintColor = iconColor
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        } else {
            bgCircle.backgroundColor = color
            iconView.tintColor = iconColor
            transform = CGAffineTransform(scaleX: scale, y: scale)
        }


        if let layer = triangle.layer.sublayers?.first as? CAShapeLayer {
            layer.fillColor = color.cgColor
        }
    }
}



struct ATMFinderView: View {
    @StateObject private var locationManager = ATMLocationManager()

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var atmLocations: [NearbyATM] = []
    @State private var selectedATM: NearbyATM? = nil
    @State private var showList = false
    @State private var hasZoomedToUser = false
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchError: String? = nil


    @State private var activeRoute: MKRoute? = nil
    @State private var isLoadingRoute = false
    @State private var routeSteps: [String] = []
    @State private var showingSteps = false
    @State private var routeDistance = ""
    @State private var routeTime = ""
    @State private var navigationATM: NearbyATM? = nil

    func searchNearbyATMs(near coordinate: CLLocationCoordinate2D) {
        isSearching = true
        searchError = nil
        atmLocations = []

        let userLoc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let queries = [
            "ATM", "bank",
            "Commercial Bank", "Peoples Bank", "Bank of Ceylon",
            "HNB", "Sampath Bank", "Seylan Bank",
            "Nations Trust Bank", "DFCC Bank"
        ]

        let group = DispatchGroup()
        var allItems: [MKMapItem] = []
        let lock = NSLock()

        for query in queries {
            group.enter()
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 50000,
                longitudinalMeters: 50000
            )
            MKLocalSearch(request: request).start { response, _ in
                if let items = response?.mapItems {
                    lock.lock(); allItems.append(contentsOf: items); lock.unlock()
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            isSearching = false
            var seen = Set<String>()
            let unique = allItems.filter { item in
                guard let name = item.name else { return false }
                let key = "\(name)_\(String(format: "%.4f", item.placemark.coordinate.latitude))_\(String(format: "%.4f", item.placemark.coordinate.longitude))"
                if seen.contains(key) { return false }
                seen.insert(key); return true
            }
            if unique.isEmpty {
                searchError = "No banks or ATMs found within 50km. Try refreshing."
                return
            }
            atmLocations = unique.compactMap { item -> NearbyATM? in
                guard let name = item.name else { return nil }
                let bank = item.placemark.subThoroughfare
                    ?? item.placemark.thoroughfare
                    ?? item.placemark.locality ?? "Bank"
                return NearbyATM(name: name, bank: bank,
                                 coordinate: item.placemark.coordinate, mapItem: item)
            }
            .sorted {
                CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
                    .distance(from: userLoc)
                < CLLocation(latitude: $1.coordinate.latitude, longitude: $1.coordinate.longitude)
                    .distance(from: userLoc)
            }
        }
    }

    func fetchDirections(to atm: NearbyATM) {
        guard let userCoord = locationManager.userLocation?.coordinate else {
            searchError = "Your location is not available yet. Please wait."
            return
        }
        isLoadingRoute = true
        searchError = nil
        navigationATM = atm
        selectedATM = nil


        let source = MKMapItem(placemark: MKPlacemark(coordinate: userCoord))
        source.name = "My Location"


        let destPlacemark = MKPlacemark(coordinate: atm.coordinate)
        let destination = MKMapItem(placemark: destPlacemark)
        destination.name = atm.name

        tryRoute(source: source, destination: destination, transport: .automobile) { route in
            if let route = route {
                self.applyRoute(route)
            } else {
 
                self.tryRoute(source: source, destination: destination, transport: .walking) { walkRoute in
                    DispatchQueue.main.async {
                        self.isLoadingRoute = false
                        if let walkRoute = walkRoute {
                            self.applyRoute(walkRoute, modeLabel: "walk")
                        } else {
                            self.searchError = "Route unavailable for this location. Try another ATM."
                            self.navigationATM = nil
                        }
                    }
                }
            }
        }
    }

    private func tryRoute(
        source: MKMapItem,
        destination: MKMapItem,
        transport: MKDirectionsTransportType,
        completion: @escaping (MKRoute?) -> Void
    ) {
        let request = MKDirections.Request()
        request.source = source
        request.destination = destination
        request.transportType = transport
        request.requestsAlternateRoutes = false

        MKDirections(request: request).calculate { response, _ in
            completion(response?.routes.first)
        }
    }

    private func applyRoute(_ route: MKRoute, modeLabel: String = "drive") {
        DispatchQueue.main.async {
            isLoadingRoute = false
            activeRoute = route

            routeSteps = route.steps
                .map { $0.instructions }
                .filter { !$0.isEmpty }

            let km = route.distance / 1000
            routeDistance = km < 1 ? "\(Int(route.distance)) m" : String(format: "%.1f km", km)
            let mins = max(1, Int(route.expectedTravelTime / 60))
            routeTime = mins < 60 ? "\(mins) min" : "\(mins / 60)h \(mins % 60)m"

            withAnimation {
                let rect = route.polyline.boundingMapRect
                region = MKCoordinateRegion(
                    rect.insetBy(dx: -rect.width * 0.2, dy: -rect.height * 0.2)
                )
            }
        }
    }


    func endNavigation() {
        withAnimation(.spring(response: 0.4)) {
            activeRoute = nil
            routeSteps = []
            routeDistance = ""
            routeTime = ""
            navigationATM = nil
            showingSteps = false
        }
        // Re-zoom to user
        if let loc = locationManager.userLocation {
            withAnimation {
                region = MKCoordinateRegion(
                    center: loc.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        }
    }


    func distanceMetres(for atm: NearbyATM) -> Double {
        let origin = locationManager.userLocation?.coordinate ?? region.center
        return CLLocation(latitude: atm.coordinate.latitude, longitude: atm.coordinate.longitude)
            .distance(from: CLLocation(latitude: origin.latitude, longitude: origin.longitude))
    }

    func distanceString(for atm: NearbyATM) -> String {
        let m = distanceMetres(for: atm)
        return m < 1000 ? "\(Int(m)) m" : String(format: "%.1f km", m / 1000)
    }

    var filteredATMs: [NearbyATM] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return atmLocations }
        let q = searchText.lowercased()
        return atmLocations.filter {
            $0.name.lowercased().contains(q) || $0.bank.lowercased().contains(q)
        }
    }


    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Nearby ATMs")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.textPrimary)
                        Text(locationManager.userLocation != nil
                             ? "Based on your current location"
                             : "Waiting for location...")
                            .font(.system(size: 13))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                    Button {
                        if let loc = locationManager.userLocation {
                            searchNearbyATMs(near: loc.coordinate)
                        } else {
                            locationManager.requestLocation()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.accentGreen)
                            .cornerRadius(10)
                    }
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
                .padding(.bottom, 10)


                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").foregroundColor(.textSecondary)
                    TextField("Search ATM or bank name...", text: $searchText)
                        .font(.system(size: 14))
                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill").foregroundColor(.textSecondary)
                        }
                    }
                }
                .padding(10)
                .background(Color.bgCard)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                .padding(.horizontal, AppDesign.screenPadding)
                .padding(.bottom, 10)

  
                if locationManager.authStatus == .denied || locationManager.authStatus == .restricted {
                    HStack(spacing: 10) {
                        Image(systemName: "location.slash.fill").foregroundColor(.accentOrange)
                        Text("Location access denied. Enable in iOS Settings.")
                            .font(.system(size: 12)).foregroundColor(.textSecondary)
                        Spacer()
                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(.system(size: 12, weight: .semibold)).foregroundColor(.primaryBlue)
                    }
                    .padding(10)
                    .background(Color.accentOrange.opacity(0.08))
                    .cornerRadius(10)
                    .padding(.horizontal, AppDesign.screenPadding)
                    .padding(.bottom, 8)
                }

                if isSearching || isLoadingRoute {
                    HStack(spacing: 10) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .primaryBlue))
                        Text(isLoadingRoute ? "Calculating route..." : "Searching banks near you...")
                            .font(.system(size: 13)).foregroundColor(.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.bgCard)
                    .cornerRadius(12)
                    .padding(.horizontal, AppDesign.screenPadding)
                    .padding(.bottom, 8)
                }

                if let err = searchError {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.accentOrange)
                        Text(err).font(.system(size: 12)).foregroundColor(.textSecondary)
                        Spacer()
                        Button("Retry") {
                            if let loc = locationManager.userLocation {
                                searchNearbyATMs(near: loc.coordinate)
                            }
                        }
                        .font(.system(size: 12, weight: .semibold)).foregroundColor(.primaryBlue)
                    }
                    .padding(10)
                    .background(Color.accentOrange.opacity(0.08))
                    .cornerRadius(10)
                    .padding(.horizontal, AppDesign.screenPadding)
                    .padding(.bottom, 8)
                }

           
                if activeRoute == nil, searchText.isEmpty, !atmLocations.isEmpty,
                   let nearest = filteredATMs.first {
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
                                .lineLimit(1)
                            Text("\(distanceString(for: nearest)) away")
                                .font(.system(size: 12))
                                .foregroundColor(.textSecondary)
                        }
                        Spacer()
                        Button("Directions") { fetchDirections(to: nearest) }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color.accentGreen)
                            .cornerRadius(10)
                    }
                    .padding(12)
                    .background(Color.bgCard)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                    .padding(.horizontal, AppDesign.screenPadding)
                    .padding(.bottom, 10)
                }

                if showList || !searchText.isEmpty {
                    if filteredATMs.isEmpty && !isSearching {
                        VStack(spacing: 12) {
                            Image(systemName: searchText.isEmpty ? "location.magnifyingglass" : "magnifyingglass")
                                .font(.system(size: 36))
                                .foregroundColor(.textSecondary.opacity(0.4))
                            Text(searchText.isEmpty ? "Waiting for location..." : "No results for \"\(searchText)\"")
                                .font(.system(size: 14))
                                .foregroundColor(.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 40)
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 12) {
                                ForEach(filteredATMs) { atm in
                                    ATMListRow(
                                        atm: atm,
                                        distanceStr: distanceString(for: atm),
                                        isSelected: selectedATM?.id == atm.id
                                    ) { withAnimation { selectedATM = atm } }
                                    .padding(.horizontal, AppDesign.screenPadding)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.bottom, 20)
                        }
                    }
                } else {

                    ZStack(alignment: .bottom) {

                        RouteMapView(
                            region: region,
                            atms: atmLocations,
                            selectedATMId: selectedATM?.id,
                            route: activeRoute,
                            onSelectATM: { atm in
                                withAnimation { selectedATM = atm }
                            }
                        )
                        .cornerRadius(16)
                        .padding(.horizontal, AppDesign.screenPadding)

                        VStack(spacing: 10) {
                     
                            if let navATM = navigationATM, activeRoute != nil {
                                ActiveNavigationBar(
                                    atmName: navATM.name,
                                    distance: routeDistance,
                                    time: routeTime,
                                    showingSteps: $showingSteps,
                                    onEnd: { endNavigation() }
                                )
                                .padding(.horizontal, AppDesign.screenPadding)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }

              
                            if showingSteps, !routeSteps.isEmpty {
                                StepByStepPanel(steps: routeSteps)
                                    .padding(.horizontal, AppDesign.screenPadding)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                            if let selected = selectedATM, activeRoute == nil {
                                ATMDetailCard(
                                    atm: selected,
                                    distanceStr: distanceString(for: selected),
                                    onDirections: { fetchDirections(to: selected) },
                                    onDismiss: { withAnimation { selectedATM = nil } }
                                )
                                .padding(.horizontal, AppDesign.screenPadding)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .background(Color.bgPrimary.ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear { locationManager.requestLocation() }
            .onChange(of: locationManager.userLocation) { newLoc in
                guard let loc = newLoc else { return }
                if !hasZoomedToUser {
                    hasZoomedToUser = true
                    withAnimation {
                        region = MKCoordinateRegion(
                            center: loc.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                    }
                }
                searchNearbyATMs(near: loc.coordinate)
            }
        }
    }
}



struct ActiveNavigationBar: View {
    let atmName: String
    let distance: String
    let time: String
    @Binding var showingSteps: Bool
    let onEnd: () -> Void

    var body: some View {
        HStack(spacing: 12) {

            VStack(alignment: .leading, spacing: 2) {
                Text(atmName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Label(distance, systemImage: "arrow.left.and.right")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.85))
                    Label(time, systemImage: "clock")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.85))
                }
            }
            Spacer()

            Button {
                withAnimation(.spring(response: 0.35)) { showingSteps.toggle() }
            } label: {
                Image(systemName: showingSteps ? "chevron.down" : "list.number")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
            }
        
            Button(action: onEnd) {
                Text("End")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "#FF3B30"))
                    .frame(width: 50, height: 34)
                    .background(Color.white)
                    .cornerRadius(8)
            }
        }
        .padding(12)
        .background(
            LinearGradient(colors: [Color.primaryBlue, Color.darkBlue],
                           startPoint: .leading, endPoint: .trailing)
        )
        .cornerRadius(14)
        .shadow(color: Color.primaryBlue.opacity(0.4), radius: 10, x: 0, y: 4)
    }
}



struct StepByStepPanel: View {
    let steps: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                    .foregroundColor(.primaryBlue)
                Text("Turn-by-Turn Directions")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.textPrimary)
                Spacer()
                Text("\(steps.count) steps")
                    .font(.system(size: 11))
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(index == 0 ? Color.primaryBlue : Color.primaryBlue.opacity(0.12))
                                    .frame(width: 26, height: 26)
                                Text("\(index + 1)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(index == 0 ? .white : .primaryBlue)
                            }
                            Text(step)
                                .font(.system(size: 13))
                                .foregroundColor(.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)

                        if index < steps.count - 1 {
                            Divider().padding(.leading, 52)
                        }
                    }
                }
            }
            .frame(maxHeight: 220)
        }
        .background(Color.bgCard)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
    }
}

// MARK: - ATM Map Pin (kept for list compatibility)

struct ATMMapPin: View {
    let atm: NearbyATM
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.primaryBlue : Color.white)
                        .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
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
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.closeSubpath()
        return p
    }
}



struct ATMListRow: View {
    let atm: NearbyATM
    let distanceStr: String
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
                        .lineLimit(1)
                    Text(atm.bank)
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(distanceStr)
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
            .background(Color.bgCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.primaryBlue : .clear, lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}



struct ATMDetailCard: View {
    let atm: NearbyATM
    let distanceStr: String
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
                        Text("\(distanceStr) away")
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
                    Text("Get Directions")
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
        .background(Color.bgCard)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
    }
}
