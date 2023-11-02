//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Stanislav Shut on 01.11.2023.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    var alertPresenter: AlertPresenter? { get set }
}

final class MovieQuizPresenter: QuestionFactoryDelegate {
    let questionAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var isButtonEnabled = true
    
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService?
    var alertPresenter: AlertPresenter?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticServiceImpl()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
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
    
    //    func didReceiveNextQuestion(question: QuizQuestion?) {
    //        guard let question = question else {
    //            return }
    //        currentQuestion = question
    //        let viewModel = convert(model: question)
    //        DispatchQueue.main.async { [weak self] in
    //            self?.viewController?.show(quiz: viewModel)
    //        }
    //    }
    
    private func showNextQuestionOrResults () {
        if self.isLastQuestion() {
            showFinalResults()
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func showFinalResults() {
        statisticService?.store(correct: correctAnswers, total: questionAmount)
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: makeResultMessage(),
            buttonText: "Сыграть ещё раз!",
            buttonAction: {
                self.restartGame() //currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
        )
        viewController?.alertPresenter?.show(alertModel: alertModel)
    }
    
    
    func makeResultMessage() -> String {
        
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
            assertionFailure("error message")
            return ""
        }
        let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)" + "(\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(accuracy)%"
        
        let resultMessage = [currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
        return resultMessage
    }
    
    
    func showAnswerResult(isCorrect: Bool) {
        //         if isCorrect{
        //             presenter.correctAnswers += 1
        //         }
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            showNextQuestionOrResults()
        }
    }
        // MARK: - QuestionFactoryDelegate
        func didReceiveNextQuestion(question: QuizQuestion?) {
            guard let question = question else {
                return
            }
            
            currentQuestion = question
            let viewModel = convert(model: question)
            DispatchQueue.main.async { [weak self] in
                self?.viewController?.show(quiz: viewModel)
            }
            //presenter.didReceiveNextQuestion(question: question)
            //        guard let question = question else {
            //            return }
            //        currentQuestion = question
            //        let viewModel = presenter.convert(model: question)
            //        DispatchQueue.main.async { [weak self] in
            //            self?.show(quiz: viewModel)
            //        }
        }
        
        func didLoadDataFromServer() {
            viewController?.hideLoadingIndicator()
            //activityIndicator.isHidden = true
            questionFactory?.requestNextQuestion()
        }
        
        func didFailToLoadData(with error: Error) {
            let message = error.localizedDescription
            viewController?.showNetworkError(message: message)
            //  showNetworkError(message: error.localizedDescription)
        }
        
        // MARK: - IBAction
        
        func yesButtonClicked() {
            didAnswer(isYes: true)
        }
        
        func noButtonClicked() {
            didAnswer(isYes: false)
        }
        
        func didAnswer(isYes: Bool) {
            if isButtonEnabled {
                guard let currentQuestion = currentQuestion else {
                    return
                }
                let givenAnswer = isYes
                isButtonEnabled = false
                showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self = self else { return }
                    self.isButtonEnabled = true
                }
            }
        }
        
        func didAnswer(isCorrectAnswer: Bool) {
            if isCorrectAnswer {
                correctAnswers += 1
            }
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


