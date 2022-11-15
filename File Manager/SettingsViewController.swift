import UIKit
import SnapKit

class SettingsViewController: UIViewController, CoordinatedProtocol {
    var coordinator: AppCoordinator
    
    let userDefaults = UserDefaults.standard

    var buttonConfiguration: UIButton.Configuration = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemGray5
        config.background = .listSidebarCell()
        //config.contentInsets = .init(top: 20, leading: -200, bottom: 20, trailing: 20)
        config.titleAlignment = .automatic
        return config
    }()
    
    lazy var sortButton: UIButton = {
        let btn = UIButton(configuration: buttonConfiguration)
        btn.setTitle("Sort files", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var changePasswordButton: UIButton = {
        let btn = UIButton(configuration: buttonConfiguration)
        btn.setTitle("Change password", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(changePasswordButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(sortButton)
        view.addSubview(changePasswordButton)
        setupConstraints()
    }

    @objc func sortButtonTapped() {
        let alertVC = UIAlertController(title: "SELECT SORT TYPE", message: nil, preferredStyle: .actionSheet )
        let sort1 = UIAlertAction(title: "sort a-z", style: .default, handler: {(_: UIAlertAction!) in
            NotificationCenter.default.post(name: Notification.Name("AZ"), object: nil)
            self.userDefaults.set("AZ", forKey: "sort")
            self.dismiss(animated: true)
        })
        let sort2 = UIAlertAction(title: "sort z-a", style: .default, handler: {(_: UIAlertAction!) in
            NotificationCenter.default.post(name: Notification.Name("ZA"), object: nil)
            self.userDefaults.set("ZA", forKey: "sort")
            self.dismiss(animated: true)
        })
        let confirm = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_: UIAlertAction!) in
            self.dismiss(animated: true)
        })
        alertVC.addAction(sort1)
        alertVC.addAction(sort2)
        alertVC.addAction(confirm)
        self.present(alertVC, animated: true)
    }
    
    @objc func changePasswordButtonTapped() {
        let vc = LoginViewController(coordinator: self.coordinator, type: .changePasword)
        vc.titleLabel.text = "Create new password!"
        self.present(vc, animated: true)
    }
    
    func setupConstraints() {
        
        sortButton.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(view.snp.width).offset(-20)
            make.height.equalTo(50)
        }
        
        changePasswordButton.snp.makeConstraints { (make) in
            make.top.equalTo(sortButton.snp.bottom).offset(15)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(view.snp.width).offset(-20)
            make.height.equalTo(50)
        }
    }
}
