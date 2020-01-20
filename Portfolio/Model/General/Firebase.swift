//
//  Firebase.swift
//  Portfolio
//
//  Created by Nikitin Nikita on 20/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import Foundation
import FirebaseFirestore
import RxSwift

class Firebase{
    static let firestoreBD = Firestore.firestore()
    
    class func getGeneralInfo() -> Observable<GeneralModel> {
        return Observable.create{ observer in
            Firebase.firestoreBD.collection(Constants.firebaseFirestore.nameCollection)
                .document(Constants.firebaseFirestore.generalInfo.nameDB)
                .getDocument(){ snapshot, error  in
                    let model = GeneralModel()
                    if let data = snapshot?.data(){
                        model.setData(data: data)
                    }
                    observer.onNext(model)
                    observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}
