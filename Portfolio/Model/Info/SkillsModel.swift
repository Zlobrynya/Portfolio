//
//  SkillsModel.swift
//  Portfolio
//
//  Created by MacBook Pro on 09.02.2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import Foundation

struct SkillsModel{
    var sever = ""
    var infoReg = [String]()
    var code = ""
    var design = ""
    var languages = [String]()
    var library = [String]()
    var own = [String]()
    var pattern = ""
    var work = ""
    
    mutating func setData(data: [String : Any]){
        sever = data[Constants.firebaseFirestore.skillsInfo.nameFSever] as? String ?? ""
        infoReg = data[Constants.firebaseFirestore.skillsInfo.nameFAuthentication] as? [String] ?? [String]()
        code = data[Constants.firebaseFirestore.skillsInfo.nameFCode] as? String ?? ""
        design = data[Constants.firebaseFirestore.skillsInfo.nameFDesign] as? String ?? ""
        languages = data[Constants.firebaseFirestore.skillsInfo.nameFLanguage] as? [String] ?? [String]()
        library = data[Constants.firebaseFirestore.skillsInfo.nameFLibrary] as? [String] ?? [String]()
        own = data[Constants.firebaseFirestore.skillsInfo.nameFOwn] as? [String] ?? [String]()
        pattern = data[Constants.firebaseFirestore.skillsInfo.nameFPattern] as? String ?? ""
        work = data[Constants.firebaseFirestore.skillsInfo.nameFWork] as? String ?? ""
    }
    
}
