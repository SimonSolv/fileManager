import UIKit
import SnapKit
import KeychainAccess

enum LoginType {
    case first, second, changePasword
}

class LoginViewController: UIViewController, CoordinatedProtocol {
    
    var coordinator: AppCoordinator
    var firstPassword: String?
    var secondPassword: String?
    var type: LoginType
    let keychain = Keychain(service: "com.filemanager.app")
    
    let passwordButtonConfigurationFirst: UIButton.Configuration = {
        var config = UIButton.Configuration.filled()
        config.title = "Create Password"
        config.baseBackgroundColor = .systemBlue
        config.background = .listSidebarHeader()
        return config
    }()
    
    let passwordButtonConfigurationSecond: UIButton.Configuration = {
        var config = UIButton.Configuration.filled()
        config.title = "Confirm Password"
        config.baseBackgroundColor = .systemBlue
        config.background = .listSidebarHeader()
        return config
    }()
    
    let passwordButtonConfigurationSignedIn: UIButton.Configuration = {
        var config = UIButton.Configuration.filled()
        config.title = "Enter Password"
        config.baseBackgroundColor = .systemBlue
        config.background = .listSidebarHeader()
        return config
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to File Manager!"
        label.font = .boldSystemFont(ofSize: 30)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    lazy var passwordTextField: UITextField = {
        var textfield: UITextField = UITextField(frame: .zero)
        textfield.placeholder = "Your password"
        textfield.borderStyle = .roundedRect
        textfield.layer.borderColor = UIColor.systemGray4.cgColor
        textfield.addTarget(self, action: #selector(passwordTextChanged), for: .editingChanged)
        textfield.addTarget(self, action: #selector(passwordFieldTapped), for: .editingDidBegin)
        textfield.addTarget(self, action: #selector(secureTypeOn), for: .editingDidBegin)
        return textfield
    }()
    
    lazy var passwordButton = UIButton()
    
    init(coordinator: AppCoordinator, type: LoginType) {
        self.coordinator = coordinator
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(titleLabel)
        view.addSubview(passwordTextField)
        view.addSubview(passwordButton)
        view.backgroundColor = .systemMint
        setupConstraints()
        setupPasswordButton(type: self.type)
    }

    func setupConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top).offset(200)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(view.snp.width)
            make.height.equalTo(50)
        }
        
        passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.top).offset(150)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(view.snp.width).offset(-50)
            make.height.equalTo(50)
        }
        
        passwordButton.snp.makeConstraints { (make) in
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(view.snp.width).offset(-50)
            make.height.equalTo(50)
        }
    }
    
    func setupPasswordButton(type: LoginType) {
        switch type {
        case .first:
            self.passwordButton.configuration = passwordButtonConfigurationFirst
            self.passwordButton.addTarget(self, action: #selector(confirmPasswordButtonTapped), for: .touchUpInside)
        case .second:
            self.passwordButton.configuration = passwordButtonConfigurationSignedIn
            self.passwordButton.addTarget(self, action: #selector(passwordButtonTappedSecond), for: .touchUpInside)
        case .changePasword:
            self.passwordButton.configuration = passwordButtonConfigurationFirst
            self.passwordButton.addTarget(self, action: #selector(confirmPasswordButtonTappedCreate), for: .touchUpInside)
        }
    }
    
    @objc func passwordTextChanged(_ textField: UITextField) {
        firstPassword = textField.text
    }
    
    func passwordIsValid(password: String?) -> PasswordError {
        if password != nil {
            if password!.count > 3 {
                return PasswordError(isValid: true)
            } else {
                var error = PasswordError(isValid: false)
                error.error = "Password should be at least 4 cymbols!"
                return error
            }
        } else {
            var error = PasswordError(isValid: false)
            error.error = "Enter new password!"
            return error
        }
    }
    
    func checkPassword() -> Bool {
        guard passwordIsValid(password: self.firstPassword).isValid else {
            let alertVC = UIAlertController(title: "Warning:", message: passwordIsValid(password: self.firstPassword).error, preferredStyle: .alert )
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: {(_: UIAlertAction!) in
                self.passwordTextField.text = ""
            })
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true)
            return false
        }
        return true
    }
    @objc func passwordFieldTapped(_ textField: UITextField) {

    }
    
    @objc func confirmPasswordButtonTapped() {
        guard checkPassword() else { return }
        self.secondPassword = self.firstPassword
        self.firstPassword = ""
        self.passwordTextField.placeholder = "Re-enter password"
        self.passwordTextField.text = ""
        self.passwordButton.configuration = passwordButtonConfigurationSecond
        self.passwordButton.removeTarget(self, action: #selector(confirmPasswordButtonTapped), for: .touchUpInside)
        self.passwordButton.addTarget(self, action: #selector(passwordButtonTapped), for: .touchUpInside)
    }
    
    @objc func confirmPasswordButtonTappedCreate() {
        guard checkPassword() else { return }
        self.secondPassword = self.firstPassword
        self.firstPassword = ""
        self.passwordTextField.placeholder = "Re-enter password"
        self.passwordTextField.text = ""
        self.passwordButton.configuration = passwordButtonConfigurationSecond
        self.passwordButton.removeTarget(self, action: #selector(confirmPasswordButtonTappedCreate), for: .touchUpInside)
        self.passwordButton.addTarget(self, action: #selector(createNewPassword), for: .touchUpInside)
    }
    
    @objc func createNewPassword() {
        guard checkPassword() else { return }
        if self.firstPassword == self.secondPassword {
                let alertVC = UIAlertController(title: "Success!", message: "Your passwor has been changed!", preferredStyle: .alert )
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: {(_: UIAlertAction!) in
                    do {
                        try self.keychain.set(self.firstPassword!, key: "password")
                    } catch {
                        print(error.localizedDescription)
                    }

                    self.dismiss(animated: true)
                })
                alertVC.addAction(okAction)
                self.present(alertVC, animated: true)
            } else {
            let alertVC = UIAlertController(title: "Warning:", message: "Passwords don't match", preferredStyle: .alert )
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: {(_: UIAlertAction!) in
                self.passwordTextField.text = ""
            })
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true)
        }
    }
    
    @objc func secureTypeOn(_ textField: UITextField) {
        textField.isSecureTextEntry = true
    }
    
    @objc func passwordButtonTapped() {
        guard checkPassword() else { return }
        if self.firstPassword == self.secondPassword {
                let alertVC = UIAlertController(title: "Success!", message: "Your passwor has been changed!", preferredStyle: .alert )
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: {(_: UIAlertAction!) in
                    do {
                        try self.keychain.set(self.firstPassword!, key: "password")
                    } catch {
                        print(error.localizedDescription)
                    }
                    self.coordinator.presentTabBarController(iniciator: self)
                })
                alertVC.addAction(okAction)
                self.present(alertVC, animated: true)
            } else {
            let alertVC = UIAlertController(title: "Warning:", message: "Passwords don't match", preferredStyle: .alert )
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: {(_: UIAlertAction!) in
                self.passwordTextField.text = ""
            })
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true)
        }
        
    }
    
    @objc func passwordButtonTappedSecond() {
        guard checkPassword() else { return }
        let pass = keychain["password"]
        if self.firstPassword == pass {
            self.coordinator.presentTabBarController(iniciator: self)
        } else {
            let alertVC = UIAlertController(title: "Warning:", message: "Wrong password", preferredStyle: .alert )
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: {(_: UIAlertAction!) in
                self.passwordTextField.text = ""
            })
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true)
        }
    }
}
