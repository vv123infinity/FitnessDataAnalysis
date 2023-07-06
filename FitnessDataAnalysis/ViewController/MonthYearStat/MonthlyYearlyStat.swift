//
//  MonthlyStat.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/19.
//

import UIKit

class MonthlyYearlyStat: UIViewController {

    @IBOutlet weak var segmentControl   : UISegmentedControl!
    @IBOutlet weak var containerView    : UIView!
    @IBOutlet weak var sView: UIScrollView!

    
    private lazy var monthlyStatVC: MonthlyStatTable = {
           // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

           // Instantiate View Controller
        //
//        var viewController = storyboard.instantiateViewController(withIdentifier: "MonthlyStat") as! MonthlyStat
        var viewController = storyboard.instantiateViewController(withIdentifier: "MonthlyStatTable") as! MonthlyStatTable
//        viewController.sportType = UserDefaults.standard.integer(forKey: "analyzeSportType")
        self.add(asChildViewController: viewController)

        return viewController
       }()
    
    private lazy var yearlyStatVC: YearlyStat = {
           // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

           // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "YearlyStat") as! YearlyStat
        self.add(asChildViewController: viewController)

        return viewController
       }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpUI()
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem // This will
        
    }
    
    func setUpUI(){
        setUpBKcolor()
        self.setSegmentControl()
        self.setupView()
        if UserDefaults.standard.bool(forKey: "useSmiley"){
                  self.setUpFontSmiley()
            
            
        }
        
        
//        UserDefaults.standard.set(0, forKey: "analyzeSportType")
//        self.setUpRightButtons()
        
    }
    
    
    func setUpRightButtons(){
        self.navigationItem.rightBarButtonItem?.tintColor = ColorUtil.getBarBtnColor()
        
        // 现在测试自行车
        let cycle = UIAction(title: "🚴‍♀️🚴‍♂️"){ (action) in
            print("hello, cycle")
            UserDefaults.standard.set(0, forKey: "analyzeSportType")

        }
        let running = UIAction(title: "🏃🏃‍♀️"){ (action) in
            print("hello, running")
            UserDefaults.standard.set(0, forKey: "analyzeSportType")
        }
        
        let myMenu = UIMenu(title: "😀神兽保佑，没有Bug😇", options: .singleSelection, children: [cycle, running])
        
        self.navigationItem.rightBarButtonItem?.menu = myMenu
        
        self.navigationItem.rightBarButtonItem?.shouldGroupAccessibilityChildren = true
        
    }
    
    
    //        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    //        let play = UIBarButtonItem(title: "Play", style: .plain, target: self, action: #selector(playTapped))
    //
    //        self.navigationItem.rightBarButtonItems = [add, play]
    
    @objc func addTapped() {
        print("add!!")
    }
    
    @objc func playTapped() {
        print("hello!")
    }
    
    
    func setUpBKcolor(){
        self.view.backgroundColor = ColorUtil.getBackgroundColorStyle1()
        self.sView.backgroundColor = ColorUtil.getBackgroundColorStyle1()
    }
    
    func setUpFontSmiley() {
        let font = SmileyFontSize.getNormal()
        self.segmentControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: SmileyFontSize.getNormal()]
    }
    
    
    
    func setSegmentControl() {
        // 标题设置
        self.segmentControl.setTitle(NSLocalizedString("monthlyStat", comment: ""), forSegmentAt: 0)
        self.segmentControl.setTitle(NSLocalizedString("yearlyStat", comment: ""), forSegmentAt: 1)
//        self.segmentControl
        
        // 格式设置
        let colorSet = ColorUtil.getSegConColor()
        
        self.segmentControl.backgroundColor = colorSet.bk
        self.segmentControl.layer.borderColor = colorSet.border.cgColor
        self.segmentControl.selectedSegmentTintColor = colorSet.highlight
//        self.segmentControl.layer.shadowOpacity = 1
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: colorSet.normalTxt]
        self.segmentControl.setTitleTextAttributes(titleTextAttributes, for:.normal)

        let titleTextAttributes1 = [NSAttributedString.Key.foregroundColor: colorSet.selectedTxt]
        self.segmentControl.setTitleTextAttributes(titleTextAttributes1, for:.selected)
        
    }


    static func viewController() -> MonthlyYearlyStat {
        return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MonthlyYearlyStat") as! MonthlyYearlyStat
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }



    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        updateView()
    }


    private func add(asChildViewController viewController: UIViewController) {

        // Add Child View Controller
        addChild(viewController)

        // Add Child View as Subview
        containerView.addSubview(viewController.view)

        // Configure Child View
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }

    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)

        // Remove Child View From Superview
        viewController.view.removeFromSuperview()

        // Notify Child View Controller
        viewController.removeFromParent()
    }


    private func updateView() {
        if segmentControl.selectedSegmentIndex == 0 {
            remove(asChildViewController: yearlyStatVC)
            add(asChildViewController: monthlyStatVC)
        } else {
            remove(asChildViewController: monthlyStatVC)
            add(asChildViewController: yearlyStatVC)
        }
    }

    func setupView() {
        updateView()
    }



    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}

    


