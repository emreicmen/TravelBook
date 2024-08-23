//
//  ViewController.swift
//  TravelBook
//
//  Created by Yunus İçmen on 25.09.2023.
//

import UIKit

//1 MapKiti kulanmak için import ve implemente işlemlerini yapıyoruz
import MapKit
//2-Kullanıcının konumunu bulmak için.Ayrıca implemente de yapıyoruz
import CoreLocation

//5-CoreDatayı kullanmak için
import CoreData

class ViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    //+ butonu ile MApView keldik ve buraya tanıtmak için bunu yazdık
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    
    //2.1 Kullanıcının konumunu almak için.Kullanıcının konumuyla ilgili işlem yapacaksak CLLocationManager'ı kullanmamız gerekiyor
    var locationManager = CLLocationManager()
    
    //5 kapsamında t4'te aldığımız koordinatları almak için tanıttık
    var choosenLatitude = Double()
    var choosenLongitude = Double()
    
    //8 Burada seçilen title boş ise ekran veri ekleme modunda açılacak dolu ise gösterme modunda açılacak.Bu kontrolü didLoad altında yapacağız
    var selectedTitle = ""
    var selectedTitleID : UUID?
    
    //8.3 kapsamında verileri dizi içinden çekip bu değişkenlere atacağız
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1-Mapin Ekran açılır açılmaz yüklenmesi için burada self'e atama yapıyoruz
        mapView.delegate = self
        //2.2 Locaiton-Manager'ının delegate'inin ViewController olduğubu belitmemiz gerekir
        locationManager.delegate = self
        //2.3 Kullanıcının konumunu ne kadar keskinlikte olacağını belirtmemiz gerekir
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //Best en iyi konumu verir ama fazla pil yer
        //2.4 Kullanıcıdan izin alamız gerekir.İzni alırken ne yazacağını LaunchScreen altındaki Info alanından yapacağız
        locationManager.requestWhenInUseAuthorization()
        //2.5 Kullanıcının yerini almaya başlıyoruz
        locationManager.startUpdatingLocation()
        
        //4 Pin koymak için gesture oluşturacağız.Burdaki fark uzun basılıp basılmadığını algılayacağız
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        //Kaç saniye bassın onu belirleyeceğiz
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
        
        //8.1 ListViewController'dan gelen selectedTitle ve selectedTitleID kontrollerini yaparak ekranın yapısını değiştireceğiz(ListViewController'da yapıldı)
        if selectedTitle != ""{//Burada boş değilse CoreData'dan çekme işlemlerini yapacağız
            //ListViewController'dan selectdeTitle ve id'sinin atamasını burada yaptık.Burada CoreDaa'dan verileri çekeceğiz
            let stringUUID = selectedTitleID!.uuidString
            //8.3 kapsamında verileri çekeceğiz
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchReqest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = selectedTitleID!.uuidString//Çekilen id'yi where'e vermek için stringe çevirdik
            //Burada sorguyu shere koşulu ekleyeceğiz
            fetchReqest.predicate = NSPredicate(format: "id = %@", idString) //id'si isString'e eşit olan verileri getir dedik
            fetchReqest.returnsObjectsAsFaults = false
            
            do{
                let results =  try context.fetch(fetchReqest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        //Verileri diziden çekeceğiz. Burada çektiğimiz verileri annotationlara atacağız. Değişkenleri boş olarak oluşturuyoruz
                        if let title = result.value(forKey: "title") as? String{
                            annotationTitle = title
                            if let subtitle = result.value(forKey: "subtitle") as? String{
                                annotationSubtitle = subtitle
                                if let latitude = result.value(forKey: "latitude") as? Double{
                                    annotationLatitude = latitude
                                    if let longitude = result.value(forKey: "longitude") as? Double{
                                        annotationLongitude = longitude
                                        
                                        //Annotation(Pin) oluşturduk ve pine koordinatlarını verdik
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitle
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        annotation.coordinate = coordinate
                                        
                                        //Pini göstereceğiz
                                        mapView.addAnnotation(annotation)
                                        nameText.text = annotationTitle
                                        commentText.text = annotationSubtitle
                                        
                                        //Burada artık anlık konum aldırmayı durduruyoruz.Amacımız konum değiştiğinde haritanın da ekranda otomatik haritayı getirmesi
                                        locationManager.stopUpdatingLocation()
                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
            }catch{
                print("Error")
            }
            
        }else{
            //Boşsa ekleme işlemini yapacağız
        }
        
    }
    //3-Kullanıcının konumunu aldıktan sonra ne yapacağız.Konumu alındığı anda.Değişen konumları diziye atar
    //CLLocation bize enlem ve boylam verir
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //SelectedTitle boşsa ekleme ekranına gidecek
        if selectedTitle == "" {
            //Burada hartaya zoomla diyeceğiz.Aşağıda değişkene konumun enlem ve boylamını atadık.Sonrasında zoomlamayı yapacağız
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            //Zoomlamayı yapacağız
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) //Ne kadar küçükse o kadar yakın gösterilir
            //Region oluşturarak yukarıda oluşturduğumuz değişkenler kullanacağız
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }
        
    }
    
    //4 kapsamındaki gesture'a verilecek olan fonkisyon.Burada parametreyi çağırarak LongPress'in özelliklerine erişeceğiz
    @objc func chooseLocation(gestureRecognizer:UILongPressGestureRecognizer){
        //Tıklanılan yerin konumunu alacağız.Koordinatlarıyla pin oluşturup haritaya ekleceğiz
        //GestureRecognizer(Haritataya tıklama işlemi başladı mı kontrol edeceğiz)
        if gestureRecognizer.state == .began{
            let touchPoint = gestureRecognizer.location(in: self.mapView)
            //Dokunulan noktayı koordinata çevireceğiz
            let touchedCoordinates = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            //Yukarıda koordinatları aldık.Sırada pini ekleyeceğiz
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
            self.mapView.addAnnotation(annotation)
            
            //5'te kullanmak için alınan koordinatları atadık.Buyı 4. değil 5.aşamada yazdık
            choosenLatitude = touchedCoordinates.latitude
            choosenLongitude = touchedCoordinates.longitude
        }
    }
    
    //5-CoreDataya kaydetme işlemi için CoreData şmportu yapılır.Burada AppDelegate üzerinden coreData işlemlerimizi gerçekleştireceğiz
    @IBAction func saveButton(_ sender: Any) {
        //Bu kodlar coreDataya kaydetmek için standart kodlar
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        newPlace.setValue(nameText.text, forKey: "title")
        newPlace.setValue(commentText.text, forKey: "subtitle")
        newPlace.setValue(choosenLatitude, forKey: "latitude")
        newPlace.setValue(choosenLongitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        //kaydetme işlemi burada yapılır
        do{
            try context.save()
            print("Saved!!")
        }catch{
            print("Error")
        }
        
        //9-Save button ile tableView ekranına dönmek için
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
        //Bir önceki viewController'a götürür.Geri gittikten sonra tableView'ı güncelleyeceğiz
        navigationController?.popViewController(animated: true)
    }
    
    //10 Burada pini(annotation) özelleştireceğiz
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{//Kullanıcımızın yerini pin ile göstermek istemiyoruz
            return nil
        }
        let reusId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reusId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusId)
                pinView?.canShowCallout = true
                pinView?.tintColor = UIColor.black
                
                //Callout(baloncuk) içerisinde button olacak
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    //10.1 Burada 10'daki i butonuna tıklayınca ne olacak
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedTitle != "" {
            //Navigasyonu başlatmak için
            var requestLocaiton = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            CLGeocoder().reverseGeocodeLocation(requestLocaiton) { (placemarks,error) in
                if let placemark = placemarks {
                    if placemark.count > 0 {
                        let newPlacemark = MKPlacemark(placemark: placemark[0])
                        let item = MKMapItem(placemark: newPlacemark)
                        item.name = self.annotationTitle
                        //Nasıl bir navigasyon yapacağız onu belirtiyoruz.Yürüyerek mi araçla mı
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                    }
                }
                
            }
        }
    }
}

