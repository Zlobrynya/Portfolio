//
//  InfoModel.swift
//  Portfolio
//
//  Created by Nikitin Nikita on 20/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import Foundation


struct GeneralModel {
    var FIO = ""
    var URLGitHub = ""
    var email = ""
    var languageEng = ""
    var hhURL = ""
    var numberPhone = ""
    
    mutating func setData(data: [String : Any]){
        FIO = data[Constants.firebaseFirestore.generalInfo.nameFFIO] as? String ?? ""
        URLGitHub = data[Constants.firebaseFirestore.generalInfo.nameFURLGitHub] as? String ?? ""
        email = data[Constants.firebaseFirestore.generalInfo.nameFEmail] as? String ?? ""
        hhURL = data[Constants.firebaseFirestore.generalInfo.nameFhhURL] as? String ?? ""
        languageEng = data[Constants.firebaseFirestore.generalInfo.nameFLanguage_eng] as? String ?? ""
        numberPhone = data[Constants.firebaseFirestore.generalInfo.nameFNumberPhone] as? String ?? ""
    }
}
