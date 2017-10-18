
import UIKit
import SDWebImage

class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    private let oopsWarningMessageString = "There are no results"
    private let warningTitleString = "Sorry.."

    private var gifsOnScreenCount = 50

    var result: [GifModel] = []
    private var selectedGifs:[GifModel] = []

    private var yFamilyIsNeeded:Bool = false
    private var gFamilyIsNeeded:Bool = false
    private var pgFamilyIsNeeded:Bool = false

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var stateInfoView: UILabel!
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

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedGifs = result

        let width = UIScreen.main.bounds.width
        tableView.rowHeight = width*0.7
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedGifs.count == 0 { createAlert(title: self.warningTitleString , message: self.oopsWarningMessageString)}

        if gifsOnScreenCount > selectedGifs.count {
            return selectedGifs.count
        }else {
            return gifsOnScreenCount
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! GifTableViewCell

        cell.gifView.sd_setImage(with: URL(string: selectedGifs[indexPath.row].url)!, placeholderImage: UIImage(named: "ImagePlaceHolder"))
        if (selectedGifs[indexPath.row].trended) {cell.starImageView.image = UIImage(named: "trendedImage")}

        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 {
            self.gifsOnScreenCount += 50
            tableView.reloadData()
        }
    }

    private func createAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert,animated: true, completion: nil)
    }
}
