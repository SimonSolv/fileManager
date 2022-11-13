import UIKit
import SnapKit

class MainViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, CoordinatedProtocol {
    
    var dataFiles: [ImageData] = []
 
    var imagePicker = UIImagePickerController()
    
    var coordinator: AppCoordinator
    
    let userDefaults = UserDefaults.standard
    
    var sortType: SortType? = {
        let sort = UserDefaults.standard.object(forKey: "sort") as? String
        if sort != nil {
            if sort == "AZ" {
                return .AZ
            } else if sort == "ZA" {
                return .ZA
            } else {
                return nil
            }
        } else {
            return nil
        }
    }()
    
    private let sectionInsets = UIEdgeInsets(
      top: 50.0,
      left: 20.0,
      bottom: 50.0,
      right: 20.0
    )

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        view.backgroundColor = .white
        return view
    }()
    
//MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.sortPhotosAZ(notification:)),
                                               name: Notification.Name("AZ"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.sortPhotosZA(notification:)),
                                               name: Notification.Name("ZA"),
                                               object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let sort = userDefaults.object(forKey: "sort") as? String
        dataFiles = getFiles(sortedBy: self.sortType ?? .AZ)

        self.title = "File Manager"
        self.view.backgroundColor = .white
        setupViews()
        setupConstraints()
    }
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: Setup
    func setupViews() {
        self.view.addSubview(self.collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addImage))
        navigationItem.rightBarButtonItem = addButton
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupConstraints() {
        collectionView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
    }
//MARK: Working with images and views
    @objc func addImage() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            saveImage(image: pickedImage)
            guard self.sortType != nil else {
                updateCollectionView()
                return
            }
            sortPhotosBy(sortType: self.sortType!)
            self.updateCollectionView()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func newImageView(image:UIImage?) -> UIImageView {
        let imv = UIImageView()
        imv.backgroundColor = .black
        imv.image = image
        return imv
    }
    
    func updateCollectionView() {
        self.dataFiles = getFiles(sortedBy: self.sortType ?? .AZ)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    // Sorting photoFiles
    
    func sortPhotosBy(sortType: SortType) {
        switch sortType {
        case .AZ:
            sortPhotos(data: dataFiles, sorting: .AZ) { data in
                self.dataFiles = data
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        case .ZA:
            sortPhotos(data: dataFiles, sorting: .ZA) { data in
                self.dataFiles = data
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    @objc func sortPhotosAZ(notification: NSNotification) {
        self.sortType = .AZ
        sortPhotosBy(sortType: .AZ)
    }
    @objc func sortPhotosZA(notification: NSNotification) {
        self.sortType = .ZA
        sortPhotosBy(sortType: .ZA)
    }
    
}
//MARK: CollectionView Setup
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataFiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier,
                                                            for: indexPath) as? PhotoCollectionViewCell
        else {
            preconditionFailure("Invalid cell type")
        }
        cell.sourse = dataFiles[indexPath.row]
        cell.layer.cornerRadius = 15
        cell.clipsToBounds = true
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 20, height: 120)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(8.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(8.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
      return false
    }

    func collectionView(_ collectionView: UICollectionView, performPrimaryActionForItemAt indexPath: IndexPath) {
        let alertVC = UIAlertController(title: "Warning!", message: "Do you really want to delete this image?", preferredStyle: .alert )
        let okAction = UIAlertAction(title: "Ok", style: .destructive, handler: {(_: UIAlertAction!) in
            let name = self.dataFiles[indexPath.row].imageName
            deleteImage(name: name)
            self.updateCollectionView()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {(_: UIAlertAction!) in })
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
}



