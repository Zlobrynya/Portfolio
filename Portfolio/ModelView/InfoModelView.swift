//
//  InfoModelView.swift
//  Portfolio
//
//  Created by Nikitin Nikita on 20/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import Foundation
import RxSwift

class InfoModelView {
    var generalModelPS = PublishSubject<GeneralModel>()
    var skillsModelPS = PublishSubject<SkillsModel>()
    
    private var generalModel: GeneralModel?
    private var skillsModel: SkillsModel?
    
    init() {
        getGeneralData()
        getSkillsData()
    }
    
    private func getGeneralData(){
        let ob = Firebase.getGeneralInfo()
        _ = ob.subscribe{ on in
            switch on{
            case .next(let model):
                self.generalModel = model
                self.generalModelPS.onNext(model)
                break
            case .error(let error):
                print(error)
            case .completed:
                break
            }
        }
    }
    
    private func getSkillsData(){
        let ob = Firebase.getSkillsInfo()
        _ = ob.subscribe{ on in
            switch on{
            case .next(let model):
                self.skillsModel = model
                self.skillsModelPS.onNext(model)
                break
            case .error(let error):
                print(error)
            case .completed:
                break
            }
        }
    }
}
