import Foundation


class CheckBox: UIButton {

    let passiveColor = UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    let activeColor = UIColor.init(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)

    var isChecked: Bool = true {
        didSet{
            if isChecked == true {
                self.backgroundColor = passiveColor
            } else {
                self.backgroundColor = activeColor
            }
        }
    }

    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.isChecked = false
    }

    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}
