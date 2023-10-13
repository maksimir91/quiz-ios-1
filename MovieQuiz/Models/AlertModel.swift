//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Stanislav Shut on 27.09.2023.
//

import Foundation

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var buttonAction: () -> Void
}
