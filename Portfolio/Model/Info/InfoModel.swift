//
//  InfoModel.swift
//  Portfolio
//
//  Created by Nikitin Nikita on 20/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import Foundation


class GeneralModel {
    var FIO = ""
    var URLGitHub = ""
    var birthday = 0
    var email = ""
    var languageEng = ""
    var numberPhone = ""
    
    func setData(data: [String : Any]){
        FIO = data[Constants.firebaseFirestore.generalInfo.nameFFIO] as? String ?? ""
        URLGitHub = data[Constants.firebaseFirestore.generalInfo.nameFURLGitHub] as? String ?? ""
        birthday = data[Constants.firebaseFirestore.generalInfo.nameFBirthday] as? Int ?? 0
        email = data[Constants.firebaseFirestore.generalInfo.nameFEmail] as? String ?? ""
        languageEng = data[Constants.firebaseFirestore.generalInfo.nameFLanguage_eng] as? String ?? ""
        numberPhone = data[Constants.firebaseFirestore.generalInfo.nameFNumberPhone] as? String ?? ""
    }
}
