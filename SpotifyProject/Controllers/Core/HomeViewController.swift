//
//  ViewController.swift
//  SpotifyProject
//
//  Created by gvladislav-52 on 17.07.2024.
//

import UIKit

enum BrowseSectionType {
    case newReleases
    case featuredPlaylists
    case recommendedTracks
}

class   HomeViewController: UIViewController {
    
    private var collectionView: UICollectionView = UICollectionView(
            frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
                return HomeViewController.createSectionLayout(section: sectionIndex)
                //PART 8 TIME: 9.45
            })
    
    private let spinner: UIActivityIndicatorView = {
       let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Browse"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSetting))
        configureCollectionView()
        view.addSubview(spinner)
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        switch section {
        case 0:  // Item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            // Group
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(390)),
                subitem: item,
                count: 3
            )
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .absolute(390)),
                subitem: verticalGroup,
                count: 1
            )
            
            // Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            return section
    case 1:  // Item
        
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(200),
                heightDimension: .absolute(200)
            )
        )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let vecticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(400)),
                subitem: item,
                count: 2
            )
        
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(200),
                heightDimension: .absolute(400)),
            subitem: vecticalGroup,
            count: 1
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: horizontalGroup)
        section.orthogonalScrollingBehavior = .continuous
        return section
        
    case 2:  // Item
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(80)),
            subitem: item,
            count: 1
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        return section
            
        default:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            // Group
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(390)),
                subitem: item,
                count: 3
            )
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .absolute(390)),
                subitem: verticalGroup,
                count: 1
            )
            
            // Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            return section
        }
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
    }
    
    private func fetchData() {
        APICaller.shared.getRecommendedGenris { result in
            switch result {
            case .success(let model):
                let genres = model.genres
                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let random = genres.randomElement() {
                        seeds.insert(random)
                    }
                }
                
                APICaller.shared.getRecommendations(genres: seeds) { _ in
                    
                }
            case .failure(_):
                break
            }
        }
    }
    
    @objc func didTapSetting() {
        let vc = SettingsViewController()
        vc.title = "Settings"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if indexPath.section == 0 {
            cell.backgroundColor = .systemGreen
        } else if indexPath.section == 1 {
            cell.backgroundColor = .systemPink
        } else if indexPath.section == 2 {
            cell.backgroundColor = .systemBlue
        }
        return cell
    }
    
    
}
