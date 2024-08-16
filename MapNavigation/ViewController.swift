//
//  ViewController.swift
//  MapNavigation
//
//  Created by Ahmed El-elaimy on 16/08/2024.
//

import UIKit
import GoogleMaps
import GooglePlaces

// MARK: - ViewController

class ViewController: UIViewController {
    
    // MARK: - UI Components
    private let mapView = GMSMapView()
    private let startAddressTextField = UITextField()
    private let destinationAddressTextField = UITextField()
    private let routeButton = UIButton(type: .system)
        
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        overrideUserInterfaceStyle = .light
        configureMapView()
        configureTextFields()
        configureRouteButton()
        setupConstraints()
    }
    
    private func configureMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
    }
    
    private func configureTextFields() {
        startAddressTextField.placeholder = "Enter starting address"
        startAddressTextField.borderStyle = .roundedRect
        startAddressTextField.translatesAutoresizingMaskIntoConstraints = false
        
        destinationAddressTextField.placeholder = "Enter destination address"
        destinationAddressTextField.borderStyle = .roundedRect
        destinationAddressTextField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(startAddressTextField)
        view.addSubview(destinationAddressTextField)
    }
    
    private func configureRouteButton() {
        routeButton.setTitle("Show Route", for: .normal)
        routeButton.addTarget(self, action: #selector(showRoute), for: .touchUpInside)
        routeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(routeButton)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200),
            
            startAddressTextField.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 10),
            startAddressTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            startAddressTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            startAddressTextField.heightAnchor.constraint(equalToConstant: 40),
            
            destinationAddressTextField.topAnchor.constraint(equalTo: startAddressTextField.bottomAnchor, constant: 10),
            destinationAddressTextField.leadingAnchor.constraint(equalTo: startAddressTextField.leadingAnchor),
            destinationAddressTextField.trailingAnchor.constraint(equalTo: startAddressTextField.trailingAnchor),
            destinationAddressTextField.heightAnchor.constraint(equalToConstant: 40),
            
            routeButton.topAnchor.constraint(equalTo: destinationAddressTextField.bottomAnchor, constant: 20),
            routeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Route Actions
    @objc private func showRoute() {
        guard let startAddress = startAddressTextField.text, !startAddress.isEmpty,
              let destinationAddress = destinationAddressTextField.text, !destinationAddress.isEmpty else {
            showAlert(title: "Error", message: "Please enter both addresses.")
            return
        }
        
        let group = DispatchGroup()
        
        var startCoordinate: CLLocationCoordinate2D?
        var destinationCoordinate: CLLocationCoordinate2D?
        var fetchError: Error?
        
        group.enter()
        fetchCoordinates(for: startAddress) { result in
            switch result {
            case .success(let coordinate):
                startCoordinate = coordinate
            case .failure(let error):
                fetchError = error
            }
            group.leave()
        }
        
        group.enter()
        fetchCoordinates(for: destinationAddress) { result in
            switch result {
            case .success(let coordinate):
                destinationCoordinate = coordinate
            case .failure(let error):
                fetchError = error
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            if let error = fetchError {
                self?.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            if let start = startCoordinate, let destination = destinationCoordinate {
                self?.drawRoute(from: start, to: destination)
                self?.addMarkers(start: start, destination: destination)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func fetchCoordinates(for address: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        GoogleMapsService.shared.getCoordinates(for: address, apiKey: apiKey) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let coordinate):
                    completion(.success(coordinate))
                case .failure(let error):
                    completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Address '\(address)' couldn't be found."])))
                }
            }
        }
    }
    
    private func drawRoute(from start: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        GoogleMapsService.shared.getRoute(from: start, to: destination, apiKey: apiKey) { result in
            switch result {
            case .success(let path):
                self.addPolyline(with: path)
            case .failure(let error):
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    private func addPolyline(with path: GMSPath) {
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = .blue
        polyline.strokeWidth = 5.0
        polyline.map = mapView
        moveCameraToRoute(path: path)
    }
    
    private func moveCameraToRoute(path: GMSPath) {
        let bounds = GMSCoordinateBounds(path: path)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
        mapView.moveCamera(update)
    }
    
    private func addMarkers(start: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        GoogleMapsService.shared.addMarker(on: mapView, at: start, title: "Start", color: .green)
        GoogleMapsService.shared.addMarker(on: mapView, at: destination, title: "Destination", color: .red)
    }
}

// MARK: - GoogleMapsService

class GoogleMapsService {
    
    static let shared = GoogleMapsService()
    
    private init() {}
    
    func getCoordinates(for address: String, apiKey: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        let geocoderURL = "https://maps.googleapis.com/maps/api/geocode/json?address=\(address)&key=\(apiKey)"
        
        guard let url = URL(string: geocoderURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let geometry = results.first?["geometry"] as? [String: Any],
                   let location = geometry["location"] as? [String: Any],
                   let lat = location["lat"] as? CLLocationDegrees,
                   let lng = location["lng"] as? CLLocationDegrees {
                    
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    completion(.success(coordinate))
                } else {
                    completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON structure"])))
                }
            } catch let error {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func getRoute(from start: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, apiKey: String, completion: @escaping (Result<GMSPath, Error>) -> Void) {
        let origin = "\(start.latitude),\(start.longitude)"
        let destination = "\(destination.latitude),\(destination.longitude)"
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=walking&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let routes = json["routes"] as? [[String: Any]],
                   let route = routes.first,
                   let overviewPolyline = route["overview_polyline"] as? [String: Any],
                   let points = overviewPolyline["points"] as? String,
                   let path = GMSPath(fromEncodedPath: points) {
                    
                    completion(.success(path))
                } else {
                    completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON structure"])))
                }
            } catch let error {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func addMarker(on mapView: GMSMapView, at coordinate: CLLocationCoordinate2D, title: String, color: UIColor) {
        let marker = GMSMarker()
        marker.position = coordinate
        marker.title = title
        marker.icon = GMSMarker.markerImage(with: color)
        marker.map = mapView
    }
}
