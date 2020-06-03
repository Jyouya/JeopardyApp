//
//  DetailView.swift
//  Jeopordy
//
//  Created by Rave BizzDev on 6/1/20.
//  Copyright © 2020 Rave BizzDev. All rights reserved.
//

import UIKit

class DetailView: UIViewController {
    var answer: Answer!
    
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    @IBAction func questionTapped(_ sender: Any) {
        UIView.transition(with: questionLabel, duration: 1.0, options: .transitionCrossDissolve, animations: { () -> Void in
            self.questionLabel.text = self.answer.answer
        })
        
    }
    
    @IBAction func toggleFavorite(_ sender: Any) {
        answer.favorite = !(answer.favorite ?? false)
        favoriteButton.image = (answer.favorite ?? false) ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        answerLabel.text = answer.question
        favoriteButton.image = (answer.favorite ?? false) ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
    }
}
