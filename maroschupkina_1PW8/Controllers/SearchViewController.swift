//
//  SearchViewController.swift
//  maroschupkina_1PW8
//
//  Created by Marina Roshchupkina on 20.03.2022.
//

import UIKit

class SearchViewController: MoviesViewController {
    
    let search = UISearchController()
    var session: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        search.searchResultsUpdater = self
        search.searchBar.placeholder = "Enter movie title"
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.title = "Search"
        tabBarController?.navigationItem.searchController = search
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.search.searchBar.endEditing(true)
    }
    
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = search.searchBar.text, !text.isEmpty else {
            return
        }
        self.loadMovies(query: text)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.loadMovies(query: searchText)
        }
    }
    
    internal func loadMovies(query: String) {
        guard let url = URL(string:"https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&language=ru-RU&query=\(query)&page=1".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        else {return assertionFailure()}
        session?.cancel()
        session = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, _ in
            guard let data = data,
                  let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                  let results = dict["results"] as? [[String: Any]]
            else {
                return
            }
            let movies: [Movie] = results.map { params -> Movie in
                let title = params["title"] as? String
                let imagePath = params["poster_path"] as? String
                return Movie(title: title ?? "", posterPath: imagePath)
            }
            self.movies = movies
            self.loadImagesForMovies(movies) { movies in
                self.movies = movies
            }
        }
        
        session?.resume()
    }
    
}

