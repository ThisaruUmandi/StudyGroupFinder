//
//  LocationPickerView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-29.
//

import SwiftUI
import MapKit
import CoreLocation

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @Binding var locationName: String

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var pin: CLLocationCoordinate2D?
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Map(coordinateRegion: $region,
                    annotationItems: pinItems) { item in
                    MapMarker(coordinate: item.coordinate,
                              tint: Color(hex: "#0300BF"))
                }
                .ignoresSafeArea(edges: .bottom)
                .onTapGesture {
                    pin = region.center
                    reverseGeocode(region.center)
                }

                VStack(spacing: 4) {
                    // Search bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search location...", text: $searchText)
                            .onSubmit { search() }
                        if isSearching {
                            ProgressView().scaleEffect(0.8)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    // Search results
                    if !searchResults.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(searchResults, id: \.self) { item in
                                Button {
                                    selectItem(item)
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: "mappin")
                                            .foregroundColor(Color(hex: "#0300BF"))
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.name ?? "")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.primary)
                                            if let address = item.placemark.title {
                                                Text(address)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(1)
                                            }
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                }
                                Divider().padding(.leading, 14)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                    }
                }
            }
            .navigationTitle("Pick Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        selectedCoordinate = pin
                        dismiss()
                    }
                    .disabled(pin == nil)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private var pinItems: [PinItem] {
        guard let pin else { return [] }
        return [PinItem(coordinate: pin)]
    }

    private func search() {
        guard !searchText.isEmpty else { return }
        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = region
        MKLocalSearch(request: request).start { response, _ in
            isSearching = false
            searchResults = response?.mapItems ?? []
        }
    }

    private func selectItem(_ item: MKMapItem) {
        let coord = item.placemark.coordinate
        region.center = coord
        pin = coord
        locationName = item.name ?? item.placemark.title ?? ""
        searchResults = []
        searchText = ""
    }

    private func reverseGeocode(_ coord: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let loc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        geocoder.reverseGeocodeLocation(loc) { placemarks, _ in
            if let place = placemarks?.first {
                locationName = [place.name, place.locality]
                    .compactMap { $0 }
                    .joined(separator: ", ")
            }
        }
    }
}

private struct PinItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

#Preview {
    LocationPickerPreviewWrapper()
}

struct LocationPickerPreviewWrapper: View {
    @State private var coordinate: CLLocationCoordinate2D? = nil
    @State private var locationName: String = ""

    var body: some View {
        LocationPickerView(
            selectedCoordinate: $coordinate,
            locationName: $locationName
        )
    }
}
