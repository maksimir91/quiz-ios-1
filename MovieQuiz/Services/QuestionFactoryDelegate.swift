//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Stanislav Shut on 27.09.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
