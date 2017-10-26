import UIKit
import Alamofire
import SDWebImage

class TrendedGifsViewController: UIViewController {

    private let segueToResultView = "segueToResultView"
    private let giphyService = GiphyService()
    private let gifPlaceholder = UIImage(named: "ImagePlaceHolder")
    private var isLoading = true
    private let loadingTriggerOffset: CGFloat = 0.0
    private var gifs = [GifModel]()
    var gifsView = GifsView()
    private var filteredGifs = [GifModel]()
    private var gifRatings = ["g", "pg", "y"]

    private var searchTerm = "" {
        didSet {
            gifs.removeAll()
            loadGifsFromServer()
        }
    }

    private var selectedIndex = -1 {
        didSet {
            filterGifs()
        }
    }



    override func loadView() {
        view = gifsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("gifSearcher", comment: "")

        gifsView.tableViewDelegate = self
        gifsView.searchBarDelegate = self
        gifsView.dataSource = self

        gifsView.setRefreshControlWith(action: refreshTrendedGifs)
        gifsView.setSegmentedControlWith(titles: gifRatings)
        gifsView.setSegmentedControlWith(action: ratingDidChange)
        gifsView.setSwitcherWith(action: resetFilter)

        loadGifsFromServer()
    }

    func ratingDidChange(newValue: Int) {
        selectedIndex = newValue
    }

    func disableFilter(isDisabled: Bool) {
        if isDisabled {
            selectedIndex = -1
        }
    }

    func filterGifs() {
        filteredGifs.removeAll()
        if selectedIndex == -1 {
            filteredGifs.append(contentsOf: gifs)
        } else {
            for gif in gifs {
                if gif.rating.contains(gifRatings[selectedIndex]) {
                    filteredGifs.append(gif)
                }
            }
        }
        gifsView.reloadData()
    }

    private func gifsDidLoad(result: [GifModel]?) {
        guard let data = result else {
            createAlert(title: NSLocalizedString("warningTitle", comment: ""),
                             message: NSLocalizedString("serverError", comment: ""))
            return
        }
        gifs += data
        filterGifs()
        gifsView.showLoadingView(false)
        isLoading = false
    }

    private func refreshTrendedGifs() {
        gifs.removeAll()
        loadGifsFromServer()
    }

    private func loadGifsFromServer() {
        gifsView.showLoadingView(true)
        if searchTerm.isEmpty {
            giphyService.loadTrendingGifs(offset: gifs.count, completion: gifsDidLoad)
        } else {
            giphyService.searchGifsByName(searchTerm, offset: gifs.count, completion: gifsDidLoad)
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredGifs.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(filteredGifs[indexPath.row].height)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GifTableViewCell.identifier,
                                                 for: indexPath) as! GifTableViewCell

        cell.gifView.sd_setImage(with: URL(string: filteredGifs[indexPath.row].url), placeholderImage: gifPlaceholder)
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
