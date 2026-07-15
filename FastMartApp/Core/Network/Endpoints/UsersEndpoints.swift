//
//  UsersEndpoints.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 15/07/26.
//

import Foundation

// MARK: - Product Endpoints

enum UsersEndpoints {
    case getUserProfileDetails(userID: String)
}

extension UsersEndpoints: APIEndpoint {

    var path: String {
        switch self {
        case .getUserProfileDetails(let userid):        return "/users/\(userid)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getUserProfileDetails:
            return .get
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
//        case .getUserProfileDetails(let userID):
//            return [
//                URLQueryItem(name: "user_id", value: userID),
//            ]
        default:
            return nil
        }
    }
}

// MARK: - Product Response DTOs

struct User: Codable {
    let id : Int?
    let name : String?
    let age : Int?
    let email : String?
    let role : String?
    let addresses : [Addresses]?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case name = "name"
        case age = "age"
        case email = "email"
        case role = "role"
        case addresses = "addresses"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        age = try values.decodeIfPresent(Int.self, forKey: .age)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        role = try values.decodeIfPresent(String.self, forKey: .role)
        addresses = try values.decodeIfPresent([Addresses].self, forKey: .addresses)
    }
}

struct Addresses : Codable {
    let id : Int?
    let street : String?
    let city : String?
    let state : String?
    let zip_code : String?
    let user_id : Int?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case street = "street"
        case city = "city"
        case state = "state"
        case zip_code = "zip_code"
        case user_id = "user_id"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        street = try values.decodeIfPresent(String.self, forKey: .street)
        city = try values.decodeIfPresent(String.self, forKey: .city)
        state = try values.decodeIfPresent(String.self, forKey: .state)
        zip_code = try values.decodeIfPresent(String.self, forKey: .zip_code)
        user_id = try values.decodeIfPresent(Int.self, forKey: .user_id)
    }

}
