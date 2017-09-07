//
//  ViewController.swift
//  DuckDuckGoScraper
//
//  Created by Alejandro Silva Fernandez on 05/09/2017.
//  Copyright © 2017 Alex Silva. All rights reserved.
//

import UIKit
import ReachabilitySwift
import SDWebImage

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    var backImageView: UIImageView!
    var backLabel: UILabel!

    let reachability = Reachability()!
    var searchResults = [Result]()

    // MARK: - Life-cycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        initialUI()
        connectionUIChanges()
    }

    deinit {
        reachability.stopNotifier()
    }

    // MARK: - Custom methods

    func initialUI() {
        // SearchBar configuration
        searchField.barTintColor = .white
        let cancelButtonAttributes = [NSForegroundColorAttributeName: UIColor.darkGray]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes, for: .normal)

        // TableView configuration
        resultsTableView.isHidden = true
        resultsTableView.tableFooterView = UIView()

        // Create background image with constraints
        backImageView = UIImageView(image: UIImage(named: "duckduckgo"))
        backImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backImageView)

        view.addConstraints([
            NSLayoutConstraint(item: backImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 150),
            NSLayoutConstraint(item: backImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 150),
            NSLayoutConstraint(item: backImageView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: backImageView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)
            ])

        // Create background label with constraints
        backLabel = UILabel()
        backLabel.textAlignment = .center
        backLabel.text =  "Search what you need above!"
        backLabel.font = UIFont.systemFont(ofSize: 25.0)
        backLabel.numberOfLines = 0
        backLabel.sizeToFit()
        backLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backLabel)

        view.addConstraints([
            NSLayoutConstraint(item: backLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: UIScreen.main.bounds.width - 40.0),
            NSLayoutConstraint(item: backLabel, attribute: .top, relatedBy: .equal, toItem: backImageView, attribute: .bottom, multiplier: 1.0, constant: 30),
            NSLayoutConstraint(item: backLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
            ])

        // Add gesture recognizer
        let backTapGesture = UITapGestureRecognizer(target: self, action: #selector(resignKeyboard))
        backTapGesture.delegate = self
        self.view.addGestureRecognizer(backTapGesture)
    }

    func configureSearchUI() {
        let resultsExist = searchResults.count > 0

        backImageView.isHidden = resultsExist
        backLabel.isHidden = resultsExist
        resultsTableView.isHidden = !resultsExist
        if resultsExist {
            resultsTableView.reloadData()
        }
        if let text = searchField.text, !text.isEmpty, !resultsExist {
            backLabel.text = "No results available for '\(text)'"
        } else if let text = searchField.text, text.isEmpty, !resultsExist {
            backLabel.text = "Search what you need above!"
        }
    }

    func showNoInternetConnection() {
        if self.searchResults.count == 0 {
            self.backImageView.isHidden = false
            self.backLabel.isHidden = false
            self.backLabel.text = "No internet connection! :("
        }
    }

    func connectionUIChanges() {
        reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                if self.searchResults.count == 0 {
                    self.configureSearchUI()
                }
            }
        }

        reachability.whenUnreachable = { reachability in
            DispatchQueue.main.async {
                self.showNoInternetConnection()
            }
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("ERROR >> Reachability is not available")
        }
    }

    func resignKeyboard() {
        searchField.endEditing(false)
    }

    // MARK: - UIGestureRecognizer delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view.isDescendant(of: resultsTableView) {
            return false
        }

        return true
    }

    // MARK: - UISearchBar delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else {
            return
        }

        if reachability.currentReachabilityStatus == .notReachable {
            self.showNoInternetConnection()
        } else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true

            let trimmedSearchTerm = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
            searchBar.text = trimmedSearchTerm

            if trimmedSearchTerm.characters.count > 0 {
                WSClient.sharedInstance.searchByTerm(trimmedSearchTerm, completion: { (results: [Result]?, error: Error?) in
                    if let results = results {
                        self.searchResults = results

                        DispatchQueue.main.async {
                            self.configureSearchUI()
                        }
                    }

                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                })
            }
        }

        resignKeyboard()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchBar.text, text.isEmpty, searchResults.count == 0 {
            configureSearchUI()
        }
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchField.text = ""
        resignKeyboard()
    }

    // MARK: - UITableView delegate and datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier = "ResultCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as! ResultTableViewCell

        if let icon = searchResults[indexPath.row].icon {
            cell.miniImageView?.sd_setImage(with: icon)
        } else {
            cell.miniImageView?.image = UIImage(named: "noimage")
        }

        cell.urlLabel.text = searchResults[indexPath.row].url?.absoluteString ?? "No url"
        cell.descLabel.text = searchResults[indexPath.row].description ?? "No description available"

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = searchResults[indexPath.row].url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        searchField.endEditing(false)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
