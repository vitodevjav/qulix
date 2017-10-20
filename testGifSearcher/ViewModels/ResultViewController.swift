
import UIKit
import SDWebImage

class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    private var gifsOnScreenCount = 20

    var result: [GifModel] = []
    private var selectedGifs:[GifModel] = []

    private var yFamilyIsNeeded:Bool = false
    private var gFamilyIsNeeded:Bool = false
    private var pgFamilyIsNeeded:Bool = false
    private var loadStatus = false

    @IBOutlet weak var tableView: UITableView!
   
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadMoreView: UIView!
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
    
    func prepareView(){
        loadMoreView.isHidden = true
        activityIndicator.isHidden = true
        stateInfoView.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedGifs = result
        
        prepareView()
        stateInfoView.text = NSLocalizedString("Loading", comment: "")
        let width = UIScreen.main.bounds.width
        tableView.rowHeight = width*0.7
        
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedGifs.count == 0 { createAlert(title: NSLocalizedString("WarningTitle", comment: ""), message: NSLocalizedString("WarningMessage", comment: ""))}

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

    func gifsDidLoad(){
        DispatchQueue.main.async{
            self.loadStatus = false
            self.activityIndicator.stopAnimating()
            self.loadMoreView.isHidden = true
            self.tableView.reloadData()
        }
    }
    
    func prepareViewForLoadingGifs(){
        loadMoreView.isHidden = false
        activityIndicator.isHidden = false
        stateInfoView.isHidden =  false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= -10 && !loadStatus {
            loadStatus = true
            prepareViewForLoadingGifs()
            activityIndicator.startAnimating()
            loadMore(){
                self.gifsDidLoad()
            }
        }
    }
    
    func loadMore(completion: @escaping ()->()){
        DispatchQueue.global().async {
            self.gifsOnScreenCount += 20
            completion()
        }
    }
    

    private func createAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert,animated: true, completion: nil)
    }
}
