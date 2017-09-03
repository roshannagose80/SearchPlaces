//
//  PhotoDetailsViewController.swift
//  SearchPlaces
//
//  Created by Roshan Nagose on 02/09/17.
//  Copyright © 2017 SearchPlaces. All rights reserved.
//

import UIKit
import Photos

class PhotoDetailsViewController: UIViewController {

     var assetCollection: PHAssetCollection!
    @IBOutlet weak var fullImageView: UIImageView!
    
    var selectedImage: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let _ = selectedImage{
            fullImageView.image = selectedImage
        }
        
//        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
//            
//            let fetchOptions = PHFetchOptions()
//            fetchOptions.predicate = NSPredicate(format: "title = %@", "Search Places")
//            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
//            
//            if let _: AnyObject = collection.firstObject {
//                return collection.firstObject!
//            }
//            
//            return nil
//        }
//        
//        if let assetCollection = fetchAssetCollectionForAlbum() {
//            self.assetCollection = assetCollection
//            return
//        }
//        
//        PHPhotoLibrary.shared().performChanges({
//            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "Search Places")
//        }) { success, _ in
//            if success {
//                self.assetCollection = fetchAssetCollectionForAlbum()
//            }
//        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        
        saveImage(image: fullImageView.image!)
       // self.dismiss(animated: true, completion: nil)
    }
    
    func saveImage(image: UIImage) {
        CustomPhotoAlbum().save(image: image) { (success) in
            self.dismiss(animated: true, completion: nil)
        }
    }


    @IBAction func cancelButtonAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
  
}


class CustomPhotoAlbum: NSObject {
    static let albumName = "Search Places"
    static let shared = CustomPhotoAlbum()
    
     var assetCollection: PHAssetCollection!
    
     override init() {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
    }
    
     func checkAuthorizationWithHandler(completion: @escaping ((_ success: Bool) -> Void)) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                self.checkAuthorizationWithHandler(completion: completion)
            })
        }
        else if PHPhotoLibrary.authorizationStatus() == .authorized {
            self.createAlbumIfNeeded()
            completion(true)
        }
        else {
            completion(false)
        }
    }
    
     func createAlbumIfNeeded() {
        if let assetCollection = fetchAssetCollectionForAlbum() {
            // Album already exists
            self.assetCollection = assetCollection
        } else {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)   // create an asset collection with the album name
            }) { success, error in
                if success {
                    self.assetCollection = self.fetchAssetCollectionForAlbum()
                } else {
                    // Unable to create album
                }
            }
        }
    }
    
     func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    func save(image: UIImage, completion: @escaping ((_ success: Bool) -> Void)) {
        self.checkAuthorizationWithHandler { (success) in
            if success {
                if let assetCollection = self.fetchAssetCollectionForAlbum() {
                    // Album already exists
                    self.assetCollection = assetCollection
                    PHPhotoLibrary.shared().performChanges({
                        let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                        let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
                        let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                        let enumeration: NSArray = [assetPlaceHolder!]
                        albumChangeRequest!.addAssets(enumeration)
                        
                    }, completionHandler: { success, error in
                        completion(true)
                    })
                } else {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)   // create an asset collection with the album name
                    }) { success, error in
                        if success {
                            self.assetCollection = self.fetchAssetCollectionForAlbum()
                            PHPhotoLibrary.shared().performChanges({
                                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                                let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
                                let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                                let enumeration: NSArray = [assetPlaceHolder!]
                                albumChangeRequest!.addAssets(enumeration)
                                
                            }, completionHandler: { success, error in
                                completion(true)
                            })
                        } else {
                            completion(true)

                        }
                    }
                }
            }
        }
    }
}
