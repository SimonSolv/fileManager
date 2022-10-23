import UIKit
import SnapKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CellId"
    
    lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 5
        return image
    }()
    
    lazy var fileNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Label"
        label.font = .boldSystemFont(ofSize: 18)
        label.numberOfLines = 0
        return label
    }()
    
    var sourse: [String: UIImage]? {
        didSet {
            for i in sourse!.keys {
                imageView.image = sourse![i]
                fileNameLabel.text = i
            }
            
        }
    }
    
    var itemName: Int? {
        didSet {
            fileNameLabel.text = "Image \(itemName!)"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 15
        contentView.clipsToBounds = true
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(fileNameLabel)
        
        imageView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView.snp.top).offset(10)
            make.width.equalTo(100)
            make.leading.equalTo(contentView.snp.leading).offset(10)
            make.height.equalTo(100)
        }
        
        fileNameLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView.snp.top)
            make.trailing.equalTo(contentView.snp.trailing).offset(-15)
            make.leading.equalTo(imageView.snp.trailing).offset(15)
            make.bottom.equalTo(contentView.snp.bottom)
        }
        
    }
}
