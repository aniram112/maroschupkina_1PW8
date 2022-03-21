//
//  PagingViewController.swift
//  maroschupkina_1PW8
//
//  Created by Marina Roshchupkina on 21.03.2022.
//

import UIKit

class PagingViewController: UIViewController {
    internal let tableView = UITableView()
    internal var segmentedControl = UISegmentedControl()
    internal let apiKey = "52846410a29857ff5ee4a418ab6ab056"
    internal var movies:[Movie] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureSegmentedControl()
        loadMovies()
        tableView.rowHeight = UIScreen.main.bounds.width/0.67 + 40
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.title = "Paging"
        tabBarController?.navigationItem.searchController = nil
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
        var index = segmentedControl.selectedSegmentIndex
        if index<0 {index = 1}
        let page = segmentedControl.titleForSegment(at: index) ?? "1"
        
        guard let url = URL(string:"https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&language=ru-RU&page=\(page)") else {return assertionFailure("something wrong")}
        let session = URLSession.shared.dataTask(with: URLRequest(url: url), completionHandler: {data, _, _ in
            guard
                let data = data,
                let dict = try? JSONSerialization.jsonObject (with: data, options: .allowFragments) as? [String: Any],
                let results = dict["results"] as? [[String: Any]]
            else { return }
            
            let movies: [Movie] = results.map { params -> Movie in
                let title = params["title"] as! String
                let imagePath = params["poster_path"] as? String
                let id = params["id"] as? Int
                let path = self.getPath(id: id!)
                return Movie(
                    title: title,
                    posterPath: imagePath,
                    path: path
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
    
    internal func getPath(id: Int) -> String {
             return "https://www.themoviedb.org/movie/\(id)"
    }
    
    internal func loadImagesForMovies(_ movies: [Movie], completion: @escaping ([Movie]) -> Void) {
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
    
    
    func configureSegmentedControl() {
        segmentedControl = UISegmentedControl(items: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"])
        segmentedControl.backgroundColor = .white
        segmentedControl.selectedSegmentTintColor = .systemBlue
        segmentedControl.tintColor = .lightGray
        
        view.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.heightAnchor.constraint(equalToConstant: 50),
            segmentedControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        self.loadMovies()
    }
    
}

extension PagingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: movies[indexPath.row].path!) {
            let controller = MovieWebViewController()
            controller.url = url
            navigationController?.modalPresentationStyle = .fullScreen
            navigationController!.pushViewController(controller, animated: true)
        }
    }
 }

extension PagingViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count;
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieView.identifier, for: indexPath) as! MovieView
        cell.configure(movie: movies[indexPath.row])
        return cell
    }
    
}
