//
//  Constants.swift
//  Portfolio
//
//  Created by Nikitin Nikita on 20/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import Foundation

class Constants {    
    static let firebaseFirestore = FirebaseFirestore()
    
    
    struct FirebaseFirestore {
        let nameCollection = "info"
        let generalInfo = GeneralInfo()
        let skillsInfo = Skills()
        
        struct GeneralInfo {
            let nameDB = "general_info"
            let nameFFIO = "FIO"
            let nameFURLGitHub = "github"
            let nameFBirthday = "birthday"
            let nameFEmail = "email"
            let nameFLanguage_eng = "language_eng"
            let nameFNumberPhone = "number_phone"
        }
        
        struct Skills {
            let nameDB = "skills"
            let nameFGeneral = "general"
            let nameFAuthentication = "authentication"
            let nameFLanguages = "languages"
            let nameFLibrary = "library"
        }
    }
}
