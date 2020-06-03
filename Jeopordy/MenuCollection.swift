//
//  MenuCollection.swift
//  Jeopordy
//
//  Created by Rave BizzDev on 6/1/20.
//  Copyright © 2020 Rave BizzDev. All rights reserved.
//

import UIKit

private let reuseIdentifier = "answerCell"

class MenuCollection: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var answers = [[Answer]]()
    var currentSelection: Answer!
    var showFavorites = false
    var favoriteCategories: [[Answer]] {
        get {
            answers.filter { self.favorites($0).count > 0 }
        }
    }
    
    @IBOutlet weak var favoritesButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = false
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.sectionHeadersPinToVisibleBounds = true
        layout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 50)
        self.collectionView.collectionViewLayout = layout
        
        let url = URL(string: "http://jservice.io/api/clues")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error == nil {
                guard let data = data  else { return }
                let rawAnswers = try! JSONDecoder().decode([Answer].self, from: data)
                
                var answerDict = Dictionary<Int, [Answer]>()
                
                rawAnswers.forEach { answer in
                    if answerDict[answer.category_id] != nil {
                        answerDict[answer.category_id]?.append(answer)
                    } else {
                        answerDict[answer.category_id] = [answer]
                    }
                }
                
                answerDict.forEach {key, value in
                    self.answers.append(value)
                }
                
                self.answers = self.answers.map { category in
                    category.sorted(by: {
                        return ($0.value ?? 100) < ($1.value ?? 100)
                    })
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailView = segue.destination as! DetailView
        detailView.answer = currentSelection
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if showFavorites {
            return answers.filter { self.favorites($0).count > 0 } .count
        }
        return answers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let cellsPerRow = Int(view.frame.size.width >= 360 ? view.frame.size.width / 120.0 : 3.0)
    
        let category = showFavorites ? favorites(favoriteCategories[section]) : answers[section]
        let paddingCellCount = cellsPerRow == category.count ? 0 : cellsPerRow - category.count % cellsPerRow
        return category.count + paddingCellCount
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AnswerCell
        
        let category = showFavorites ? favorites(favoriteCategories[indexPath.section]) : answers[indexPath.section]
        
        if indexPath.row >= category.count {
            cell.value.text = ""
            cell.back.isHidden = true
            cell.front.isHidden = false
            cell.answer.text = ""
            return cell
        }
        
        let answer = category[indexPath.row]
        
//        cell.category.text = answer.category_title.capitalized
        let value = answer.value ?? 100
        cell.value.text = "$\(value)"
        cell.answer.text = answer.question
        
        if answer.flipped != nil {
            cell.back.isHidden = false
            cell.front.isHidden = true
        } else {
            cell.back.isHidden = true
            cell.front.isHidden = false
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellsPerRow = view.frame.size.width >= 360 ? view.frame.size.width / 120.0 : 3.0
        
        let width = view.frame.size.width / floor(cellsPerRow) - (cellsPerRow - 1 ) / cellsPerRow
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let category = showFavorites ? favorites(favoriteCategories[indexPath.section]) : answers[indexPath.section]
        
        if indexPath.row >= category.count {
            return
        }
        
        if category[indexPath.row].flipped != nil {
            currentSelection = category[indexPath.row]
            performSegue(withIdentifier: "presentDetailView", sender: self)
        } else {
            let cell = self.collectionView.cellForItem(at: indexPath) as! AnswerCell
            UIView.transition(with: cell, duration: 0.5, options: .transitionFlipFromLeft, animations: { () -> Void in
                cell.front.isHidden = true
                cell.back.isHidden = false
            })
            
            category[indexPath.row].flipped = true
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionView.elementKindSectionHeader) {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "categoryHeader", for: indexPath) as! CategoryHeader
            let categories = showFavorites ? favoriteCategories : answers
            headerView.label.text = categories[indexPath.section][0].category_title.capitalized
            return headerView
        }
        fatalError()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1.0, left: 0, bottom: 5.0, right: 0)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.collectionView.reloadData()
    }
    
    func favorites(_ answers: [Answer]) -> [Answer] {
        return answers.filter { $0.favorite ?? false }
    }
    
    @IBAction func toggleFavorites(_ sender: Any) {
        showFavorites = !showFavorites
        collectionView.reloadData()
        
        favoritesButton.title = showFavorites ? "Show All" : "Favorites"
        
        title = showFavorites ? "Favorites" : "Jeopardy"
    }
    
}
