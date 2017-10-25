
import UIKit
import SDWebImage


class ResultViewController: UIViewController {

    var giphyService: GiphyService!
    var searchRequest: String!
    private var result: [GifModel] = []
    private var filteredGifs: [GifModel] = []
    private var yFamilyIsNeeded: Bool = true
    private var gFamilyIsNeeded: Bool = true
    private var pgFamilyIsNeeded: Bool = true
    private let getNextGifsFromServerBottomOffset: CGFloat = 0.0
    private var loadStatus = false
    @IBOutlet weak var loadingStateView: UIView!
    @IBOutlet weak var tableView: UITableView!

    @IBAction func pgCheckBoxStatusIsChanged(_ sender: Any) {
        pgFamilyIsNeeded = !pgFamilyIsNeeded
        filterGifs()
    }

    @IBAction func yCheckBoxStatusIsChanged(_ sender: Any) {
        yFamilyIsNeeded = !yFamilyIsNeeded
        filterGifs()
    }

    @IBAction func gCheckBoxStatusIsChanged(_ sender: Any) {
        gFamilyIsNeeded = !gFamilyIsNeeded
        filterGifs()
    }

    private func filterGifs() {
        filteredGifs.removeAll()
        for gif in result {
            if gFamilyIsNeeded, gif.rating.contains("g") {
                filteredGifs.append(gif)
            }
            if yFamilyIsNeeded, gif.rating.contains("y") {
                filteredGifs.append(gif)
            }
            if pgFamilyIsNeeded, gif.rating.contains("pg") {
                filteredGifs.append(gif)
            }
        }
        tableView.reloadData()
        self.loadStatus = false
    }

    private func gifsDidLoad(result: [GifModel]?) {
        if let data = result {
            self.result += data
            self.loadingStateView.isHidden = true
            self.filterGifs()
        }else {
            self.createAlert(title: NSLocalizedString("warningTitle", comment: ""),
                             message: NSLocalizedString("warningMessage", comment: ""))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let searchRequest = self.searchRequest {
            title = searchRequest
            giphyService.searchGifsByName(searchRequest, offset: result.count, completion: gifsDidLoad)
        }
        filteredGifs = result

        let width = UIScreen.main.bounds.width
        tableView.rowHeight = width * 0.7
    }

    func loadNextGifsFromServer() {
         giphyService.searchGifsByName(searchRequest, offset: result.count, completion: gifsDidLoad)
    }

    private func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("close", comment: ""),
                                      style: UIAlertActionStyle.default,
                                      handler: {(action) in
                                        alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert,animated: true, completion: nil)
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

// MARK: - UITableViewDataSource
extension ResultViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset

        guard deltaOffset <= getNextGifsFromServerBottomOffset else {
            return
        }
        guard !loadStatus else {
            return
        }
        loadStatus = true
        loadingStateView.isHidden = false
        loadNextGifsFromServer()
    }
}
