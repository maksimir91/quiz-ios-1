//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Stanislav Shut on 27.09.2023.
//

import Foundation



protocol QuestionFactoryProtocol {
    var delegate: QuestionFactoryDelegate? { get set }
    func requestNextQuestion()
    func loadData()
}
