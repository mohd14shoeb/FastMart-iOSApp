//
//  FastAPIErrorDetail.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 15/07/26.
//
import Foundation
// MARK: - Private: Backend error detail parser

struct ServerAPIError: Decodable {
    let detail: ServerAPIDetail
}

 enum ServerAPIDetail: Decodable {
    case string(String)
    case fields([FieldError])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            self = .string(str)
        } else if let arr = try? container.decode([FieldError].self) {
            self = .fields(arr)
        } else {
            self = .string("Unknown error")
        }
    }

    var message: String {
        switch self {
        case .string(let msg):     return msg
        case .fields(let errors):  return errors.map { "\($0.loc.joined(separator: ".")): \($0.msg)" }.joined(separator: "\n")
        }
    }
}

struct FieldError: Decodable {
    let loc: [String]
    let msg: String
}
