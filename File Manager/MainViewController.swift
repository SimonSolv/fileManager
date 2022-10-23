import UIKit
import SnapKit

class MainViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var dataFiles: [Int:[String:UIImage]] = [:]
 
    var imagePicker = UIImagePickerController()
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        dataFiles = getFiles()
        self.title = "File Manager"
        self.view.backgroundColor = .white
        setupViews()
        setupConstraints()
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
            updateCollectionView()
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
        self.dataFiles = getFiles()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
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
            for i in self.dataFiles[indexPath.row]!.keys {
                deleteImage(name: i)
            }
            self.updateCollectionView()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {(_: UIAlertAction!) in })
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
}



