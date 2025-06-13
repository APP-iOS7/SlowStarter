import CoreLocation

// MARK: - Error
public enum LocationError: Error, LocalizedError {
    case authorizationDenied
    case authorizationRestricted
    case locationUnknown
    case failedToGetLocation(Error)
    case failedToGeocodeAddress(Error)
    case failedToReverseGeocode(Error)
    case dongNotFound
    case coordinateNotFound
    case duplicateLocationRequest
    
    public var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "위치 권한이 거부되었습니다."
        case .authorizationRestricted:
            return "위치 권한이 제한되어 있습니다."
        case .locationUnknown:
            return "현재 위치를 알 수 없습니다."
        case .failedToGetLocation(let error):
            return "현재 위치를 가져오지 못했습니다: \(error.localizedDescription)"
        case .failedToGeocodeAddress(let error):
            return "주소를 좌표로 변환하지 못했습니다: \(error.localizedDescription)"
        case .failedToReverseGeocode(let error):
            return "좌표를 주소로 변환하지 못했습니다: \(error.localizedDescription)"
        case .dongNotFound:
            return "동 정보를 찾을 수 없습니다."
        case .coordinateNotFound:
            return "주소에 대한 좌표를 찾을 수 없습니다."
        case .duplicateLocationRequest:
            return "이미 위치 요청이 진행 중입니다."
        }
    }
}

// MARK: - LocationManager
public final class LocationManager: NSObject {
    public static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var currentLocationCompletion: ((Result<CLLocation, LocationError>) -> Void)?
    
    override private init() {
        super.init()
        locationManager.delegate = self
    }
    
    /// 사용자에게 위치 권한을 요청
    public func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// 현재 위치 권한 상태
    public var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }
    
    /// 위치 권한을 확인 및 에러 처리
    private func checkAuthorizationStatus() throws {
        let status = authorizationStatus
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            switch status {
            case .denied:
                throw LocationError.authorizationDenied
            case .restricted:
                throw LocationError.authorizationRestricted
            default:
                throw LocationError.locationUnknown
            }
        }
    }
    
    /// 현재 위치의 위도와 경도를 가져오는 함수
    ///
    /// - Returns: (위도, 경도) 튜플
    /// - Throws: 위치 권한 또는 요청 중복 등 `LocationError`
    public func getLocation() async throws -> (Double, Double) {
        try checkAuthorizationStatus()
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else { return }
            
            // 중복 요청 방지
            guard currentLocationCompletion == nil else {
                continuation.resume(throwing: LocationError.duplicateLocationRequest)
                return
            }
            
            currentLocationCompletion = { result in
                switch result {
                case .success(let location):
                    continuation.resume(returning: (location.coordinate.latitude, location.coordinate.longitude))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
                self.currentLocationCompletion = nil
            }
            
            locationManager.requestLocation()
        }
    }
    
    /// 현재 위치에서 동(subLocality) 정보를 가져오는 함수
    ///
    /// - Returns: 동 이름 문자열
    /// - Throws: 위치 또는 주소 변환 실패 시 `LocationError`
    public func getDong() async throws -> String {
        try checkAuthorizationStatus()
        let (latitude, longitude) = try await getLocation()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        guard let dong = placemarks.first?.subLocality else {
            throw LocationError.dongNotFound
        }
        return dong
    }
    
    /// 주어진 주소 문자열에 대한 좌표(위도, 경도)를 가져오는 함수
    ///
    /// - Parameter address: 주소 문자열
    /// - Returns: (위도, 경도) 튜플
    /// - Throws: 지오코딩 실패 시 `LocationError`
    public func getAddressLocation(for address: String) async throws -> (Double, Double) {
        try checkAuthorizationStatus()
        
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.geocodeAddressString(address) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: LocationError.failedToGeocodeAddress(error))
                    return
                }
                
                guard let coordinate = placemarks?.first?.location?.coordinate else {
                    continuation.resume(throwing: LocationError.coordinateNotFound)
                    return
                }
                
                continuation.resume(returning: (coordinate.latitude, coordinate.longitude))
            }
        }
    }
    
    /// 주소 문자열을 기반으로 전체 주소 문자열을 반환하는 함수
    ///
    /// - Parameter address: 주소 문자열
    /// - Returns: 전체 주소 문자열
    /// - Throws: 지오코딩 실패 시 `LocationError`
    public func getFullAddress(for address: String) async throws -> String {
        try checkAuthorizationStatus()
        
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.geocodeAddressString(address) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: LocationError.failedToGeocodeAddress(error))
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    continuation.resume(throwing: LocationError.coordinateNotFound)
                    return
                }
                
                let components = [
                    placemark.administrativeArea,
                    placemark.locality,
                    placemark.subLocality,
                    placemark.thoroughfare,
                    placemark.subThoroughfare,
                    placemark.name
                ]
                    .compactMap { $0 }
                
                continuation.resume(returning: components.joined(separator: " "))
            }
        }
    }
    
    /// 주어진 위도와 경도로부터 지번 주소를 반환하는 함수
    /// - Parameters:
    ///   - latitude: 위도
    ///   - longitude: 경도
    /// - Returns: 지번 주소 문자열
    /// - Throws: 주소 변환 실패 시 LocationError
    public func getJibunAddress(latitude: Double, longitude: Double) async throws -> String {
        try checkAuthorizationStatus()
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: LocationError.failedToReverseGeocode(error))
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    continuation.resume(throwing: LocationError.dongNotFound)
                    return
                }
                
                let components = [
                    placemark.administrativeArea,
                    placemark.locality,
                    placemark.subLocality,
                    placemark.name
                ].compactMap { $0 }
                
                continuation.resume(returning: components.joined(separator: " "))
            }
        }
    }
    
    
}

// MARK: - Delegate

extension LocationManager: CLLocationManagerDelegate {
    // 위치 갱신할 때 작동되는 델리게이트
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocationCompletion?(.success(location))
        } else {
            currentLocationCompletion?(.failure(.locationUnknown))
        }
        currentLocationCompletion = nil
    }
    
    // 위치정보 가져오지 못했을 때 에러처리 델리게이트
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        currentLocationCompletion?(.failure(.failedToGetLocation(error)))
        currentLocationCompletion = nil
    }
}
