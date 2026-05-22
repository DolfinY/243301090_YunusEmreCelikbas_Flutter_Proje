# 🏂 Kayak Merkezi - Skipass ve Ekipman Kiralama Uygulaması

**Öğrenci Adı Soyadı:** Yunus Emre Çelikbaş
**Öğrenci Numarası:** 243301090  

Bu proje, bir kayak merkezindeki skipass (geçiş bileti) ve fiziksel ekipmanların dijital ortamda yönetilmesini ve kiralanmasını sağlayan mobil uygulamadır.

## 🔑 Test Hesapları
Sistemi hızlıca test edebilmeniz için örnek hesap bilgileri:

**Admin Hesabı:**
* Email: admin@test.com
* Şifre: 123456

**Müşteri Hesabı:**
* Email: musteri@test.com
* Şifre: 123456

*(Not: Eğer veritabanını sıfırladıysanız, giriş ekranından kolayca bu rollerle yeni hesap oluşturabilirsiniz.)*

## 📦 Kullanılan Paketler
* `firebase_core`: Firebase bağlantı ve temel ayarları için.
* `firebase_auth`: Kullanıcı kayıt, giriş ve oturum yönetimi için.
* `cloud_firestore`: Ekipmanların, sepet işlemlerinin ve sistem loglarının gerçek zamanlı veritabanı işlemleri için.

## 📸 Ekran Görüntüleri
*(Yan yana düzgün görünmesi için HTML formatında boyutlandırılmıştır)*

<p align="center">
  <img src="screenshots/1.png" width="250" />
  <img src="screenshots/2.png" width="250" />
  <img src="screenshots/3.png" width="250" />
  <img src="screenshots/4.png" width="250" />
  <img src="screenshots/5.png" width="250" />
  <img src="screenshots/6.png" width="250" />
</p>

## 🌟 Öne Çıkan Özellikler
* **Rol Bazlı Yetki:** Adminler ürün ekleyip silebilirken, Müşteriler ürün kiralayabilir ve sepetlerini yönetebilir.
* **Gelişmiş Filtreleme:** Ekipmanlar kendi içinde (Mont, Kask, vb.) anlık olarak filtrelenebilir.
* **Dinamik Fiyatlama:** Gün seçimine göre toplam tutar anlık hesaplanır.
* **Kişisel Sepet:** Müşterilerin aktif kiralamalarını gördüğü ve iptal edebildiği "Kiralamalarım" ekranı.
* **Log Sistemi:** Sisteme giriş, ürün ekleme, silme ve kiralama gibi tüm hareketler anlık olarak loglanır ve Profil ekranında listelenir.