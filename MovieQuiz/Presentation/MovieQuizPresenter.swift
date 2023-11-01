//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Stanislav Shut on 01.11.2023.
//

import UIKit

final class MovieQuizPresenter {
    let questionAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService?
    private var alertPresenter: AlertPresenter?
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
        return questionStep
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    private func showNextQuestionOrResults () {
        if self.isLastQuestion() {
            showFinalResults()
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showFinalResults() {
        statisticService?.store(correct: correctAnswers, total: questionAmount)
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: (viewController?.makeResultMessage())!,
            buttonText: "Сыграть ещё раз!",
            buttonAction: {
                self.resetQuestionIndex() //currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
        )
        alertPresenter?.show(alertModel: alertModel)
    }
    
    // MARK: - IBAction
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
//   func noButtonClicked(_ sender: UIButton) {
//        guard let currentQuestion = currentQuestion else {
//            return
//        }
//        let givenAnswer = false
//
//       viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
//    }
//
//    func yesButtonClicked(_ sender: UIButton) {
//        guard let currentQuestion = currentQuestion else {
//            return
//        }
//        let givenAnswer = true
//
//        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
//    }
    
}
