
import UIKit
import SDWebImage


class ResultViewController: UIViewController {

    private var giphyService: GiphyService
    private var searchRequest: String
    private var result: [GifModel] = []
    private var filteredGifs: [GifModel] = []
    private let getNextGifsFromServerBottomOffset: CGFloat = 0.0
    private var isLoading = true
    private var gifRatings = ["y", "g", "pg"]
    var resultView = ResultView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))

    init(giphyService: GiphyService, searchRequest: String) {
        self.searchRequest = searchRequest
        self.giphyService = giphyService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = resultView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        resultView.tableViewDelegate = self
        resultView.dataSource = self
        resultView.setSegmentedControlWith(array: gifRatings)
        resultView.segmentedControl.addTarget(self, action: #selector(filterGifs), for: .valueChanged)
        let refreshTitle = NSLocalizedString("loading", comment: "")
        resultView.refreshControl.attributedTitle = NSAttributedString(string: refreshTitle)
        resultView.refreshControl.addTarget(self, action: #selector(refreshGifs), for: .valueChanged)
        title = searchRequest
        giphyService.searchGifsByName(searchRequest, offset: result.count, completion: gifsDidLoad)
    }

    @objc func filterGifs() {
        filteredGifs.removeAll()
        let segmentedControl = resultView.segmentedControl
        let selectedRating = segmentedControl.selectedSegmentIndex
        guard let rating = segmentedControl.titleForSegment(at: selectedRating) else {
            return
        }
        for gif in result {
            guard gif.rating.contains(rating) else {
                continue
            }
            filteredGifs.append(gif)
        }
        resultView.reloadData()
        isLoading = false
    }

    private func gifsDidLoad(result: [GifModel]?) {
        if let data = result {
            self.result += data
            filterGifs()
        }else {
            createAlert(title: NSLocalizedString("warningTitle", comment: ""),
                             message: NSLocalizedString("warningMessage", comment: ""))
        }
    }

    func loadNextGifsFromServer() {
         giphyService.searchGifsByName(searchRequest, offset: result.count, completion: gifsDidLoad)
    }

    @objc func refreshGifs() {
        isLoading = true
        result.removeAll()
        DispatchQueue.global().async {
            self.giphyService.searchGifsByName(self.searchRequest, offset: self.result.count, completion: self.gifsDidLoad)
        }
    }

    private func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)

        let action = UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .cancel)
        alert.addAction(action)
        present(alert,animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension ResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredGifs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GifTableViewCell.identifier,
                                                 for: indexPath) as! GifTableViewCell

        cell.gifView.sd_setImage(with: URL(string: filteredGifs[indexPath.row].url),
                                 placeholderImage: UIImage(named: "ImagePlaceHolder"))

        if filteredGifs[indexPath.row].isTrended {
            cell.setTrendedMark()
        }
        return cell
    }
}

// MARK: - UITableViewDataDelegate
extension ResultViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset

        guard deltaOffset <= getNextGifsFromServerBottomOffset else {
            return
        }
        guard !isLoading else {
            return
        }
        isLoading = true
        loadNextGifsFromServer()
    }
}
