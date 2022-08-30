//
//  CharactersModel.swift
//  base_project
//
//  Created by Pranav Singh on 30/08/22.
//

import Foundation

// MARK: - Character
struct Character: Codable, Hashable {
    let charID: Int?
    let name, birthday: String?
    let occupation: [String]?
    let img: String?
    let status: String?
    let nickname: String?
    let appearance: [Int]?
    let portrayed: String?
    let category: String?
    let betterCallSaulAppearance: [Int]?

    enum CodingKeys: String, CodingKey {
        case charID = "char_id"
        case name, birthday, occupation, img, status, nickname, appearance, portrayed, category
        case betterCallSaulAppearance = "better_call_saul_appearance"
    }
}

typealias Characters = [Character]
