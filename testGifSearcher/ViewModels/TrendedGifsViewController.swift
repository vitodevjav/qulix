import UIKit
import Alamofire
import SDWebImage
import CoreData

class TrendedGifsViewController: UIViewController {

    private let giphyService = GiphyService()
    private let gifPlaceholder = UIImage(named: "ImagePlaceHolder")
    private var isLoading = true
    private let loadingTriggerOffset: CGFloat = 0.0
    private var gifs = [GifModelMO]() {
        didSet {
            gifsView.reloadData()
        }
    }
    var gifsView = GifsView()
    private var isRemovingNeeded = false
    private var gifRatings = ["g", "pg", "y"]

    private var searchTerm = "" {
        didSet {
            isRemovingNeeded = true
            loadGifsFromServer()
        }
    }

    private var selectedRating = "" {
        didSet {
            if oldValue != selectedRating {
                isRemovingNeeded = true
                loadGifsFromServer()
            }
        }
    }

    //MARK: - ViewController lyfecycle
    override func loadView() {
        super.loadView()
    }

    func createConstraints() {
        gifsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([gifsView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
                                     gifsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     gifsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     gifsView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(gifsView)
        createConstraints()
        title = NSLocalizedString("gifSearcher", comment: "")

        gifsView.tableViewDelegate = self
        gifsView.searchBarDelegate = self
        gifsView.tableViewDataSource = self

        gifsView.setRefreshControlWith(action: refreshGifs)
        gifsView.setSelectOptions(options: gifRatings)
        gifsView.setSegmentedControlWith(action: ratingDidChange)
        guard let cachedGifs = CoreDataStack.instance.fetch() else {
            loadGifsFromServer()
            return
        }
        gifs = cachedGifs
        isLoading = false
    }

    override func viewWillAppear(_ animated: Bool) {
        gifsView.reloadData()
    }

    //MARK: - Actions
    func ratingDidChange(newValue: String) {
        selectedRating = newValue
    }

    private func gifsDidLoad(result: [GifModelMO]?) {
        guard let data = result else {
            createAlert(title: NSLocalizedString("warningTitle", comment: ""),
                             message: NSLocalizedString("serverError", comment: ""))
            return
        }
        if isRemovingNeeded {
            gifs = data
            isRemovingNeeded = false
        } else {
            gifs += data
        }
        CoreDataStack.instance.save(data: gifs)
        gifsView.showLoadingView(false)
        isLoading = false
    }

    private func refreshGifs() {
        isRemovingNeeded = true
        loadGifsFromServer()
    }

    private func loadGifsFromServer() {
        gifsView.showLoadingView(true)
        if searchTerm.isEmpty {
            giphyService.loadTrendingGifs(offset: gifs.count, rating: selectedRating, completion: gifsDidLoad)
        } else {
            giphyService.searchGifsByName(searchTerm, offset: gifs.count, rating: selectedRating, completion: gifsDidLoad)
        }
    }

    private func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)

        let action = UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .cancel)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UISearchBarDelegate
extension TrendedGifsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchRequest = searchBar.text else {
            createAlert(title: "warningTitle", message: "badRequest")
            return
        }
        if searchRequest.isEmpty {
            searchTerm = ""
        } else {
            searchTerm = searchRequest
        }
    }
}

// MARK: - UITableViewDataSource
extension TrendedGifsViewController: UITableViewDataSource {


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(GifViewController(gif: gifs[indexPath.row]), animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gifs.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(gifs[indexPath.row].height)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GifTableViewCell.identifier,
                                                 for: indexPath) as! GifTableViewCell

        cell.gifView.sd_setImage(with: URL(string: gifs[indexPath.row].originalURL!), placeholderImage: gifPlaceholder)
        cell.setTrendedMark()
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TrendedGifsViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset

        guard deltaOffset <= loadingTriggerOffset, !isLoading else {
            return
        }
        isLoading = true
        loadGifsFromServer()
    }
}
