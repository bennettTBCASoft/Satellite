//
//  ViewController.swift
//  APIPractice
//
//  Created by TBCASoft-Bennett on 2022/3/13.
//

import UIKit

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var mCollectionView: UICollectionView!
    
    var satellite: [Satellite] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mCollectionView.delegate = self
        self.mCollectionView.dataSource = self
        fetchSatelliteData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return satellite.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCollectionViewCell
        
        cell.satellite = satellite[indexPath.item]
        cell.update()
        
        return cell
    }
    
    func fetchSatelliteData(){
        let address = "https://raw.githubusercontent.com/cmmobile/NasaDataSet/main/apod.json"
        
        if let url = URL(string: address) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("\(error.localizedDescription)")
                } else {
                    if let response = response as? HTTPURLResponse, let data = data {
                        print("Status Code: \(response.statusCode)")
                        
                        let decoder = JSONDecoder()
                        if let satelliteData = try? decoder.decode([Satellite].self, from: data){
                            for dataInfo in satelliteData {
                                self.satellite.append(dataInfo)
                            }
                            
                            DispatchQueue.main.async {
                                self.mCollectionView.reloadData()
                            }
                        }
                    }
                }
            }.resume()
        } else {
            print("Invalid URL")
        }
    }
    
    private let itemsPerRow: CGFloat = 4
    private let sectionInsets = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 20.0, right: 10.0)
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItme = availableWidth / itemsPerRow
        return CGSize(width: widthPerItme, height: widthPerItme)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

class PhotoCollectionViewCell: UICollectionViewCell {
    var satellite: Satellite!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    // escaping 是指，當傳入的參數要在外部被使用時，就得加上@escaping keyword
    func fetchImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        
        let tempDirectory = FileManager.default.temporaryDirectory
        
        let imageFileUrl = tempDirectory.appendingPathComponent(url.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: imageFileUrl.path){
            let image = UIImage(contentsOfFile: imageFileUrl.path)
            completion(image)
        } else {
            self.imageView.image = nil
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    try? data.write(to: imageFileUrl)
                    completion(image)
                } else {
                    completion(nil)
                }
            }.resume()
        }
    }
    
    func update() {
        label.text = satellite.title
        imageView.image = UIImage(systemName: "questionmark.circle")
        fetchImage(url: satellite.url) { image in
            guard let image = image else { return }
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
}
