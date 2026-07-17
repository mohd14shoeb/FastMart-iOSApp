//
//  DeviceSecurityService.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 17/07/26.
//

final class DeviceSecurityService {

    static let shared = DeviceSecurityService()

    private init() {}

    var isDeviceAllowed: Bool {
        JailbreakDetector.evaluate() == .secure
    }

    func validate() throws {
        guard isDeviceAllowed else {
            throw DeviceSecurityError.compromisedDevice
        }
    }
}

enum DeviceSecurityError: Error {
    case compromisedDevice
    var errorDescription: String? {
        switch self {
        case .compromisedDevice:
            "The device does not meet the required security conditions."
        }
    }
}


