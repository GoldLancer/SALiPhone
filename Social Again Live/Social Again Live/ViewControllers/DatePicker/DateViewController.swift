//
//  CountryViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 12.01.2021.
//

import UIKit
import MDatePickerView

protocol DateViewControllerDelegate {
    func selectedDate(selectedDate: Date)
}

class DateViewController: UIViewController {
    
    @IBOutlet weak var pickerView: UIView!
    
    lazy var MDate : MDatePickerView = {
        let mdate = MDatePickerView()
        mdate.delegate = self
        mdate.Color = UIColor(named: "main_green_color")!
        mdate.cornerRadius = 15
        mdate.translatesAutoresizingMaskIntoConstraints = false
        mdate.from = 1920
        mdate.to = 2021
        return mdate
    }()
    
    var delegate: DateViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }
    
    func initUI() {

        self.pickerView.addSubview(MDate)
        NSLayoutConstraint.activate([
            MDate.centerYAnchor.constraint(equalTo: self.pickerView.centerYAnchor, constant: 0),
            MDate.centerXAnchor.constraint(equalTo: self.pickerView.centerXAnchor, constant: 0),
            MDate.widthAnchor.constraint(equalTo: self.pickerView.widthAnchor, multiplier: 1.0),
            MDate.heightAnchor.constraint(equalTo: self.pickerView.heightAnchor, multiplier: 1.0)
        ])
    }
    
    func setDateValue(year: Int, month: Int, day: Int) {
        let calendar = Calendar.current
        var dateComponents: DateComponents? = calendar.dateComponents([.hour, .minute, .second], from: Date())

        if year != 0 {
            dateComponents?.day = day
            dateComponents?.month = month + 1
            dateComponents?.year = year
            let date: Date? = calendar.date(from: dateComponents!)
            
            MDate.selectDate = date
        } else {
            MDate.selectDate = Date()
        }
    }

    @IBAction func onClickDoneBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension DateViewController : MDatePickerViewDelegate {
    func mdatePickerView(selectDate: Date) {
        self.delegate?.selectedDate(selectedDate: selectDate)
    }
}
