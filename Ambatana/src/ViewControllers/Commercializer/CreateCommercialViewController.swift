//
//  CreateCommercialViewController.swift
//  LetGo
//
//  Created by Isaac Roldán Armengol on 4/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

class CreateCommercialViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        let themeCell = UINib(nibName: "CreateCommercialProductCell", bundle: nil)
        collectionView.registerNib(themeCell, forCellWithReuseIdentifier: "CreateCommercialProductCell")
        collectionView.backgroundColor = UIColor.whiteColor()
    }
    
    convenience init(viewModel: CreateCommercialViewModel) {
        self.init(viewModel: viewModel, nibName: "CreateCommercialViewController")
    }
}

extension CreateCommercialViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
        -> UICollectionViewCell {
            
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CreateCommercialProductCell",
                                                                                   forIndexPath: indexPath) as? CreateCommercialProductCell else { return UICollectionViewCell() }
//            cell.image.setImageWithURL(<#T##url: NSURL!##NSURL!#>)
            cell.imageView.backgroundColor = StyleHelper.productCellImageBgColor
//            cell.setupWithTitle(viewModel.titleForThemeAtIndex(indexPath.item),
//                                thumbnailURL: viewModel.imageUrlForThemeAtIndex(indexPath.item), indexPath: indexPath)
            
            return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
}

extension CreateCommercialViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width-30)/2
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
}