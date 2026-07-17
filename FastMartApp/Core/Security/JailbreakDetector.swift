//
//  JailbreakDetector.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 17/07/26.
//

import Foundation
import MachO

enum DeviceSecurityStatus {
    case secure
    case compromised
}

struct JailbreakDetector {

    static func evaluate() -> DeviceSecurityStatus {
#if targetEnvironment(simulator)
        // The simulator naturally has filesystem access that can
        // look similar to jailbreak indicators.
        return .secure
#else
        if containsSuspiciousFiles() {
            return .compromised
        }

        if canWriteOutsideSandbox() {
            return .compromised
        }

        if containsSuspiciousLoadedLibraries() {
            return .compromised
        }

        if containsSuspiciousSymbolicLinks() {
            return .compromised
        }

        return .secure
#endif
    }
}

// MARK: - Suspicious filesystem paths

private extension JailbreakDetector {

    static func containsSuspiciousFiles() -> Bool {
        let suspiciousPaths = [
            "/Applications/Cydia.app",
            "/Applications/Sileo.app",
            "/Applications/Zebra.app",
            "/Applications/Filza.app",

            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/Library/MobileSubstrate/DynamicLibraries",

            "/usr/sbin/sshd",
            "/usr/bin/ssh",
            "/usr/libexec/ssh-keysign",

            "/bin/bash",
            "/bin/sh",

            "/etc/apt",
            "/private/etc/apt",

            "/private/var/lib/apt",
            "/private/var/lib/cydia",
            "/private/var/stash",

            "/var/jb",
            "/private/preboot"
        ]

        return suspiciousPaths.contains {
            FileManager.default.fileExists(
                atPath: $0
            )
        }
    }
}

// MARK: - Sandbox write test

private extension JailbreakDetector {

    static func canWriteOutsideSandbox() -> Bool {
        let path =
            "/private/\(UUID().uuidString).txt"

        do {
            try "Security test".write(
                toFile: path,
                atomically: true,
                encoding: .utf8
            )

            try? FileManager.default.removeItem(
                atPath: path
            )

            return true
        } catch {
            return false
        }
    }
}

// MARK: - Loaded dynamic libraries

private extension JailbreakDetector {

    static func containsSuspiciousLoadedLibraries() -> Bool {
        let suspiciousLibraryNames = [
            "MobileSubstrate",
            "SubstrateLoader",
            "Substitute",
            "TweakInject",
            "libhooker",
            "ElleKit",
            "FridaGadget",
            "frida",
            "cycript",
            "SSLKillSwitch",
            "Shadow",
            "Choicy"
        ]

        let imageCount = _dyld_image_count()

        for index in 0..<imageCount {
            guard let imageName =
                _dyld_get_image_name(index)
            else {
                continue
            }

            let libraryPath = String(
                cString: imageName
            )

            if suspiciousLibraryNames.contains(
                where: {
                    libraryPath.localizedCaseInsensitiveContains(
                        $0
                    )
                }
            ) {
                return true
            }
        }

        return false
    }
}

// MARK: - Symbolic links

private extension JailbreakDetector {

    static func containsSuspiciousSymbolicLinks() -> Bool {
        let suspiciousPaths = [
            "/Applications",
            "/Library/Ringtones",
            "/Library/Wallpaper",
            "/usr/arm-apple-darwin9",
            "/var/lib/apt",
            "/var/stash"
        ]

        for path in suspiciousPaths {
            guard let attributes =
                try? FileManager.default
                    .attributesOfItem(atPath: path)
            else {
                continue
            }

            if attributes[.type] as? FileAttributeType
                == .typeSymbolicLink {
                return true
            }
        }

        return false
    }
}
