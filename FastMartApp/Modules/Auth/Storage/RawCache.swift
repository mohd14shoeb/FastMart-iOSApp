//
//  RawCache.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 15/07/26.
//

import Foundation

// MARK: - Raw Cache

/// Dumps raw JSON to disk. No queries, no schema. Just save and restore.
/// Perfect for API response caching when you don't need to query inside the data.
final class RawCache {

    static let shared = RawCache()

    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "com.fastmart.rawcache", qos: .utility)

    private var cacheDir: URL {
        let base = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("RawCache")
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private init() {}

    // MARK: - Public API

    /// Save any Codable object as raw JSON to disk.
    func save<T: Encodable>(_ object: T, forKey key: String) {
        queue.async { [weak self] in
            guard let self,
                  let data = try? self.encoder.encode(object) else { return }
            let url = self.cacheDir.appendingPathComponent("\(key).json")
            try? data.write(to: url, options: .atomic)
        }
    }

    /// Load any Decodable object from raw JSON on disk.
    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        queue.sync { [weak self] in
            guard let self else { return nil }
            let url = self.cacheDir.appendingPathComponent("\(key).json")
            guard let data = try? Data(contentsOf: url) else { return nil }
            return try? self.decoder.decode(T.self, from: data)
        }
    }

    /// Check if cached data exists for a key.
    func exists(forKey key: String) -> Bool {
        queue.sync { [weak self] in
            guard let self else { return false }
            let url = self.cacheDir.appendingPathComponent("\(key).json")
            return self.fileManager.fileExists(atPath: url.path)
        }
    }

    /// Remove cached data for a key.
    func remove(forKey key: String) {
        queue.async { [weak self] in
            guard let self else { return }
            let url = self.cacheDir.appendingPathComponent("\(key).json")
            try? self.fileManager.removeItem(at: url)
        }
    }

    /// Remove all cached data.
    func clearAll() {
        queue.async { [weak self] in
            guard let self else { return }
            let files = (try? self.fileManager.contentsOfDirectory(
                at: self.cacheDir, includingPropertiesForKeys: nil
            )) ?? []
            for file in files {
                try? self.fileManager.removeItem(at: file)
            }
        }
    }

    /// Print all cached keys for debugging.
    func dumpKeys() -> [String] {
        queue.sync { [weak self] in
            guard let self else { return [] }
            let files = (try? self.fileManager.contentsOfDirectory(
                at: self.cacheDir, includingPropertiesForKeys: nil
            )) ?? []
            return files.map { $0.deletingPathExtension().lastPathComponent }
        }
    }
}
