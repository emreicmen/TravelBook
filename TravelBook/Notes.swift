/*
 
 Bu uygulamada ana öğreti harita kullanımıdır. Kütüphaneden map kit view eklenerek ulaşılabilir. Eklemeyi yapıp ViewController'a eklemeyi yapıyoruz
 
 1-MapView'ın çalışması için import yapıp ViewController'a implementeler yapmamız gerekiyor
 
 2-Kullanıcının öncelikle kullanıcının konumunu alacağız.Bunun için ayrı bir import yapacağız
 
 3-Konumu aldık.Aldıktan sonra ne yapacağımızı didUpdateLocaitons fonksiyonunda yazacağız
 
 4-Konumu alıp zoomladık.Haritaya basınca pin ekleteceğiz.Yne gestureRecognizer kullancağız ama önceki gesture'lardan farklı yoldan yapacağız.Ekranda isimlere de yer vereceğiz.Bunun için textfieldları koyuyoruz.Girdğimiz yer adı ve yorum pin'de title ve subtitle olarak eklenecek
 
 5-Sonrasında CoreData'ya ver kaydetme işlemini gerçekleştireceğiz.CoreData'd entity oluşturuyoruz.
 
 6-Verileri çekeceğiz ve göstreceğiz.Bu işlem için yeni bir ViewController ekliyoruz ve burada TableView olacak.ViewConrolleri ekledikten sonra projeye CochoTouchClass formatında dosya ekliyoruz ve ana ViewController'ı yeni eklediğimiz yapıyoruz. Ekleme yaptıktan sonra viewController'ın özelliklerinden sağ üstteki menüden controller ekleme işlemini yapıyoruz.TableView ekleme ve tanıtma işlemlerini de yapıyoruz.Daha sonra sağ üst' + butonu ekleyeceğiz
 
 7-Verileri göstereceğiz.Bu verileri CoreData'dan çekeceğiz
 
 8- + butonuna basınca ekleme ekranına, TableView'dan tıklanınca da veri gösterme ekranına gideceğiz. Gidilecek olan bu ekranlar tek bir ekran olacak. Tıklanana göre tasarımı değiştireceğiz.
    Genel algoritma şöyle olacak: ListView'dan selectedTitle ve selectedTitleId göndereceğiz. unlar boşsa ekleme modunda doluysa gösterme modunda olacak. Gösterme modunda CoreData işlemlerini yapıp veri çekeceğiz. Aynı zamanda + butonu ile gidildiyse selected'lar boş,TableView'dan gittiyse dolu gidecek. Dolu gidince zaten id ve title'ı alıp CoreData'dan bu parametrelere uyan veriyi çekeceğiz
    Ekranları moda göre değiştirdik sırada da verileri çekme işlemi var(8.3)
    Yer değişse de eklenen yeri göstreceğiz.Bunun için locationManager'da konum almayı durdurup stop updating diyeceğiz.Konumu bir kere alacağız(8.4)
 
 9- Kaydetme işlemi yapıldıktan sonra tableView ekranına dönüş yaptırıp tableView'da güncelleme yapacağız
 
 10-Pini özellştirerek pine basınca yanlarında menüler çıkacak.Sonrasında navigasyon yaparak buraya yol tarifi verecek
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 */
