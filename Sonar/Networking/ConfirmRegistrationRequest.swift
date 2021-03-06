//
//  ConfirmRegistrationRequest.swift
//  Sonar
//
//  Created by NHSX on 26.03.20.
//  Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

class ConfirmRegistrationRequest: Request {
    
    typealias ResponseType = ConfirmRegistrationResponse
        
    let method: HTTPMethod
    
    let urlable: Urlable
    
    let headers: [String : String]
    
    init(activationCode: String, pushToken: String, deviceModel: String, deviceOSVersion: String, postalCode: String) {
        urlable = .path("/api/devices")
        headers = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        struct Body: Codable {
            let activationCode: String
            let pushToken: String
            let deviceModel: String
            let deviceOSVersion: String
            let postalCode: String
        }
        let body = Body(activationCode: activationCode,
                        pushToken: pushToken,
                        deviceModel: deviceModel, deviceOSVersion: deviceOSVersion,
                        postalCode: postalCode)

        let data = try! JSONEncoder().encode(body)
        method = HTTPMethod.post(data: data)
    }
    
    func parse(_ data: Data) throws -> ConfirmRegistrationResponse {
        let decoder = JSONDecoder()
        return try decoder.decode(ConfirmRegistrationResponse.self, from: data)
    }
}

struct ConfirmRegistrationResponse: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case id, secretKey, publicKey
    }
    
    let id: UUID
    let secretKey: Data
    let serverPublicKey: Data

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let id = try values.decode(UUID.self, forKey: .id)

        let base64SymmetricKey = try values.decode(String.self, forKey: .secretKey)
        guard let secretKey = Data(base64Encoded: base64SymmetricKey) else {
            throw DecodingError.dataCorruptedError(forKey: .secretKey, in: values, debugDescription: "Invalid base64 value")
        }

        let base64ServerPublicKey = try values.decode(String.self, forKey: .publicKey)
        guard let serverPublicKey = Data(base64Encoded: base64ServerPublicKey) else {
            throw DecodingError.dataCorruptedError(forKey: .publicKey, in: values, debugDescription: "Invalid base64 value")
        }
        
        self.init(id: id, secretKey: secretKey, serverPublicKey: serverPublicKey)
    }
    
    init(id: UUID, secretKey: Data, serverPublicKey: Data) {
        self.id = id
        self.secretKey = secretKey
        self.serverPublicKey = serverPublicKey
    }

}
