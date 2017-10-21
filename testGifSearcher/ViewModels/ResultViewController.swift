
import UIKit
import SDWebImage

class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    private var gifsOnScreenCount = 20
    var result: [GifModel] = []
    private var selectedGifs:[GifModel] = []
    private var yFamilyIsNeeded:Bool = true
    private var gFamilyIsNeeded:Bool = true
    private var pgFamilyIsNeeded:Bool = true
    private var loadStatus = false
    private let loadMoreGifsScrollOffset:CGFloat = -10.0

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var gifsLoadingStatusView: UIView!
    @IBOutlet weak var progressStateInfo: UILabel!

    @IBAction func pgCheckBoxStatusIsChanged(_ sender: Any) {
        pgFamilyIsNeeded = !pgFamilyIsNeeded
        selectGifs()
    }

    @IBAction func yCheckBoxStatusIsChanged(_ sender: Any) {
        yFamilyIsNeeded = !yFamilyIsNeeded
        selectGifs()
    }

    @IBAction func gCheckBoxStatusIsChanged(_ sender: Any) {
        gFamilyIsNeeded = !gFamilyIsNeeded
        selectGifs()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedGifs = result

        showGifsLoadingStatusView(false)
        progressStateInfo.text = NSLocalizedString("Loading", comment: "")
        let width = UIScreen.main.bounds.width
        tableView.rowHeight = width*0.7
//        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedGifs.count == 0 {
            createAlert(title: NSLocalizedString("WarningTitle", comment: ""),
                        message: NSLocalizedString("WarningMessage", comment: ""))

        }
        return (gifsOnScreenCount > selectedGifs.count) ? selectedGifs.count : gifsOnScreenCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GifTableViewCell.identifier,
                                                 for: indexPath) as! GifTableViewCell

        cell.gifView.sd_setImage(with: URL(string: selectedGifs[indexPath.row].url),
                                 placeholderImage: UIImage(named: "ImagePlaceHolder"))

        if (selectedGifs[indexPath.row].isTrended) {
            cell.setTrended()
        }
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset

        guard deltaOffset <= loadMoreGifsScrollOffset else {
            return
        }
        guard !loadStatus else {
            return
        }
        loadStatus = true
        showGifsLoadingStatusView(true)
        loadMoreGifs(){
            self.gifsDidLoad()
        }
    }

    private func gifsDidLoad() {
        DispatchQueue.main.async{
            self.showGifsLoadingStatusView(false)
            self.tableView.reloadData()
        }
    }

    private func loadMoreGifs(completion: @escaping ()->Void) {
        DispatchQueue.global().async {
            self.gifsOnScreenCount += 20
            completion()
        }
    }

    private func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""),
                                      style: UIAlertActionStyle.default,
                                      handler: { (action) in
                                        alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert,animated: true, completion: nil)
    }

    private func selectGifs() {
        selectedGifs.removeAll()
        for gif in result{
            if gFamilyIsNeeded && gif.family == "g"{
                selectedGifs.append(gif)
            }
            if yFamilyIsNeeded && gif.family == "y"{
                selectedGifs.append(gif)
            }
            if pgFamilyIsNeeded && gif.family == "pg"{
                selectedGifs.append(gif)
            }
        }
        tableView.reloadData()
    }

    private func showGifsLoadingStatusView(_ isLoading: Bool) {
			gifsLoadingStatusView.isHidden = !isLoading
            activityIndicator.isHidden = !isLoading
            progressStateInfo.isHidden =  !isLoading
    }
}
