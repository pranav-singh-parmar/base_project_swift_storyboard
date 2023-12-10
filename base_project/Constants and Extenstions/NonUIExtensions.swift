//
//  NonUIExtensions.swift
//  base_project
//
//  Created by Pranav Singh on 10/12/23.
//

import Foundation

//MARK: - Bundle
extension Bundle {
    var getBundleIdentifier: String? {
        return Bundle.main.bundleIdentifier
        //return Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
    }
    
    var appCurrentVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var appName: String? {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
    }
}

//MARK: - Data
extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
    
    func toStruct<T: Decodable>(_ decodingStruct: T.Type) -> T? {
        do {
            return try Singleton.sharedInstance.jsonDecoder.decode(decodingStruct.self, from: self)
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("CodingPath:", context.codingPath)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("CodingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("CodingPath:", context.codingPath)
        } catch let DecodingError.dataCorrupted(context) {
            print("Data Corrupted:", context.debugDescription)
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}

//MARK: - JSONKeyPair
typealias JSONKeyPair = [String: Any]

extension JSONKeyPair {
    func toStruct<T: Decodable>(_ decodingStruct: T.Type) -> T? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            let model = jsonData.toStruct(decodingStruct)
            return model
        } catch {
            print("decoding error", error.localizedDescription)
        }
        return nil
    }
}

//MARK: - Encodable
extension Encodable {
    func toData() -> Data? {
        do {
            let jsonData = try Singleton.sharedInstance.jsonEncoder.encode(self)
            return jsonData
        } catch { print(error.localizedDescription) }
        return nil
    }
    
    func toJsonObject() -> Any? {
        if let jsonData = self.toData() {
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
                return json
            } catch { print(error.localizedDescription) }
        }
        return nil
    }
    
    func toJsonKeyPair() -> JSONKeyPair? {
        if let jsonObject = self.toJsonObject(),
           let parameter = jsonObject as? JSONKeyPair {
            return parameter
        }
        return nil
    }
}
