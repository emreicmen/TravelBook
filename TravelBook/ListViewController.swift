//
//  ListViewController.swift
//  TravelBook
//
//  Created by Yunus İçmen on 26.09.2023.
//

import UIKit

//7 Verileri çekmek için CoreData'yı import ediyoruz
import CoreData

//6 tableView fonksiyonlarını kullanabilmek için UITabBarDelegate,UITableViewDataSource eklemelerini yapıyoruz
class ListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    //6.2'de çekeceğimiz verileri içine atmamız için değişken oluşturuyoruz
    var titleArray = [String]()
    var idArray = [UUID]()
    
    //8.1 kapsamında buradan choosenTitle ve choosenTitleId gönderip ViewController'a bunlrı göndereceğiz
    var choosenTitle = ""
    var choosenTitleId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //6 tableview'ı tanıtıyoruz
        tableView.delegate = self
        tableView.dataSource = self
        
        //6.1 Navigationcontroller'ı kllanarak sağ üstte + butonu koyacağız
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        //6.3 6.2'de verileri çektik ve verileri didLoad olur olmaz göstermek için burada çağırıyoruz
        getData()
    }
    
    //9.1 taleView'ı her ekran açılığında güncellemeliyiz
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newPlace"), object: nil)
    }
    
    //6 TableView'ın implementesiyle gelen fonksiyon. Row'da kaç tane item olacak
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //6.2'de verileri çekip diziye attık.Dizi elemanı kadar cell oluşturması için dizi sayısı kadar dönüyoruz
        return titleArray.count
    }
    
    //6 TableView'ın implementesiyle gelen fonksiyon. Row'da neler olacak
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row] //6.2'de oluşturduğumuz array'i veriyoruz ki Cell'de dizideki title görünsün
        return cell
    }

    //6.1 butonuna tıklayınca ne olacak burada belirtiyoruz
    @objc func addButtonClicked(){
        
        //8.1 kapsamında choosenTitle'ı boş gönderip ViewController'ın ekleme modunda açılmasını sağlayacağız
        choosenTitle = ""
        
        //Segue yaparak Map ekranna gideceğiz
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    //6.2 Dataları çekmek için fonksiyon oluşturuyoruz.Ayrıca bu fonksyonu didLoad'ın altında da çağırmamız gerek
    @objc func getData(){
        //Verilerimizi çekmek için
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        request.returnsObjectsAsFaults = false
        
        //Verileri çektik.Bu verileri değişkene atıp içinden verileri kontrol edip ulaşabileceğiz
        do{
            let results = try context.fetch(request)
            if results.count > 0 {
                //Verileri temizliyoruz ki çoklama olmasın
                self.titleArray.removeAll(keepingCapacity: false)
                self.idArray.removeAll(keepingCapacity: false)
                
                //Veriler listesinde içinde dönüp bize lazım olan verileri çekeceğiz
                for result in results as! [NSManagedObject]{
                    //Burada forkey olarak verilen alanlardaki verileri çekeceğz
                    if let title = result.value(forKey: "title") as? String{
                        self.titleArray.append(title)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        self.idArray.append(id)
                    }
                    
                    //TableView içerisinde gösterceğimiz için TableView'ı refreshliyoruz
                    tableView.reloadData()
                }
            }
        }catch{
            print("Error")
        }
    }
    
    //8.1 için tbleview'ın row'u tıklanınca ne olacak
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Burada choosenTitle'ı dolu göndererek ViewController'ın gösterme modunda açılmasını sağlayacağız
        choosenTitle = titleArray[indexPath.row]
        choosenTitleId = idArray[indexPath.row]
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    //8.1 için segue kontrolü yapacağız
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewController"{
            //Burada da seçilen title'ı viewcontroller'a gönderiyoruz.ViewController'da zaten boş ve dolu olma durumuna göre işlemler yapıldı
            let destinationVC = segue.destination as! ViewController
            destinationVC.selectedTitle = choosenTitle
            destinationVC.selectedTitleID = choosenTitleId
        }
    }
    
}
