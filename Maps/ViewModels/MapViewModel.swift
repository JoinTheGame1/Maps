//
//  MapViewModel.swift
//  Maps
//
//  Created by Никитка on 10.07.2022.
//

import GoogleMaps

class MapViewModel {
    
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    var lastRoute: [CLLocationCoordinate2D] = []
    var realmService: RealmService = RealmService.shared
    var isTracking: Bool = false
    var isShowingLastRoute: Bool = false
    
    var addRouteToMap: ((GMSPolyline?) -> Void)?
    var showError: ((String) -> Void)?
    var startUpdatingLocation: (() -> Void)?
    var stopUpdatingLocation: (() -> Void)?
    var showCurrentLocation: (() -> Void)?
    var trackButtonAnimate: ((_ model: MapViewModel) -> Void)?
    var showLastRouteButtonAnimate: ((_ model: MapViewModel) -> Void)?
    var showTrackAlert: (() -> Void)?
    var moveCameraToRoute: ((_ firstPoint: CLLocationCoordinate2D, _ lastPoint: CLLocationCoordinate2D) -> Void)?
    
    private func saveRoute() {
        route?.map = nil
        startUpdatingLocation?()
        guard let path = route?.path else { return }

        var coordinates: [Location] = []
        for i in 0..<path.count() {
            let coordinate = path.coordinate(at: i)
            let location = Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
            coordinates.append(location)
        }
        realmService.saveRoute(route: coordinates)
    }
    
    func loadRoute() {
        guard let route = realmService.loadRoute() else { return }
        
        let lastRouteLocation = Array(route)
        self.lastRoute = lastRouteLocation
            .compactMap({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) })
        
        guard !self.lastRoute.isEmpty,
              let firstPoint = self.lastRoute.first,
              let lastPoint = self.lastRoute.last
        else {
            showError?("Previous route not found ;(")
            return
        }
        
        setupRoutePath()
        self.lastRoute.forEach { point in
            self.routePath?.add(point)
            self.route?.path = self.routePath
        }
        moveCameraToRoute?(firstPoint, lastPoint)
    }
    
    func setupRoutePath() {
        route?.map = nil
        routePath = nil
        routePath = GMSMutablePath()
        route = GMSPolyline(path: routePath)
        route?.strokeWidth = 5
        addRouteToMap?(route)
    }
    
    private func startTrack() {
        if isShowingLastRoute {
            stopShowingLastRoute()
        }
        startUpdatingLocation?()
        isTracking.toggle()
        trackButtonAnimate?(self)
    }
    
    private func stopTrack() {
        saveRoute()
        stopUpdatingLocation?()
        isTracking.toggle()
        trackButtonAnimate?(self)
    }
    
    private func startShowingLastRoute() {
        isTracking ? showTrackAlert?() : loadRoute()
        isShowingLastRoute.toggle()
        showLastRouteButtonAnimate?(self)
    }
    
    private func stopShowingLastRoute() {
        setupRoutePath()
        showCurrentLocation?()
        isShowingLastRoute.toggle()
        showLastRouteButtonAnimate?(self)
    }
    
    func trackButtonTapped() {
        isTracking ? stopTrack() : startTrack()
    }
    
    func showLastRouteButtonTapped() {
        isShowingLastRoute ? stopShowingLastRoute() : startShowingLastRoute()
    }
    
    func updateLocations(coordinate: CLLocationCoordinate2D) {
        if isTracking {
            self.routePath?.add(coordinate)
            self.route?.path = routePath
        }
    }
}
