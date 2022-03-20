//
//  ViewController.swift
//  maroschupkina_1PW8
//
//  Created by Marina Roshchupkina on 18.03.2022.
//

import UIKit

class MoviesViewController: UIViewController {
    private let tableView = UITableView()
    private let apiKey = "52846410a29857ff5ee4a418ab6ab056"
    private var movies = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.loadMovies()
        }
        
        tableView.rowHeight = UIScreen.main.bounds.width/0.67 + 40
    }
    
    private func configureUI() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.register(MovieView.self, forCellReuseIdentifier: MovieView.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        tableView.reloadData()
    }
    
        private func loadMovies() {
        guard let url = URL(string:"https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&language=ru-RU") else {return assertionFailure("something wrong")}
        let session = URLSession.shared.dataTask(with: URLRequest(url: url), completionHandler: {data, _, _ in
            guard
                let data = data,
                let dict = try? JSONSerialization.jsonObject (with: data, options: .allowFragments) as? [String: Any],
                let results = dict["results"] as? [[String: Any]]
            else { return }
            
            let movies: [Movie] = results.map { params -> Movie in
                let title = params["title"] as! String
                let imagePath = params["poster_path"] as? String
                return Movie(
                    title: title,
                    posterPath: imagePath
                )
            }
            
            self.loadImagesForMovies(movies) { movies in
                self.movies = movies
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
        session.resume()
    }
    
    private func loadImagesForMovies(_ movies: [Movie], completion: @escaping ([Movie]) -> Void) {
        let group = DispatchGroup()
        for movie in movies {
            group.enter()
            DispatchQueue.global(qos: .background).async {
                movie.loadPoster { _ in
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            completion(movies)
        }
        
    }
    
}

extension MoviesViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count;
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieView.identifier, for: indexPath) as! MovieView
        cell.configure(movie: movies[indexPath.row])
        return cell
    }
    
}
