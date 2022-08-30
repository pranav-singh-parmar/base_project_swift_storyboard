//
//  CharacterApiClass.swift
//  base_project
//
//  Created by Pranav Singh on 30/08/22.
//

import Foundation

class CharactersApiClass {
    
    private(set) var characters: [Character] = []
    
    private var total = 0
    private var currentLength = 0
    private(set) var getCharactersAS: ApiStatus = .NotHitOnce

    var fetchedAllData: Bool {
        return total <= currentLength
    }
    
    func paginateWithIndex(_ index: Int) {
        if getCharactersAS != .IsBeingHit && index == currentLength - 1 && !fetchedAllData {
            getCharacters(clearList: false)
        }
    }
    
    func getCharacters(clearList: Bool = true){
        getCharactersAS = .IsBeingHit
        
        if clearList {
            currentLength = 0
            characters.removeAll()
        }
        
        let params = ["limit": 10, "offset": currentLength] as [String: Any]
        
        Singleton.sharedInstance.apiServices.hitApi(httpMethod: .GET, urlString: AppConstants.ApiEndPoints.characters, isAuthApi: false, parameterEncoding: .QueryParameters, params: params, decodingStruct: Characters.self) { [weak self] receivedData, jsonData in
            self?.getCharactersAS = .ApiHit
            self?.getCharactersAS = .ApiHitWithError
        } outputBlockForInternetNotConnected: { [weak self] in
            self?.getCharacters(clearList: clearList)
        }
    }
}
