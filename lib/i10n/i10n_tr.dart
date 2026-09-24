// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'i10n.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class STr extends S {
  STr([String locale = 'tr']) : super(locale);

  @override
  String get screen_size_error => 'Ekran boyutu çok küçük.';

  @override
  String get admin => 'Admin';

  @override
  String get guest => 'Kullanıcı';

  @override
  String get role => 'Rol';

  @override
  String get login => 'Kullanıcı Adı';

  @override
  String get first_name => 'İsim';

  @override
  String get last_name => 'Soyisim';

  @override
  String get phone_number => 'Tel No';

  @override
  String get email => 'E-posta';

  @override
  String get active => 'Aktif';

  @override
  String get authorities => 'Roller';

  @override
  String get name => 'İsim';

  @override
  String get success => 'Başarılı';

  @override
  String get failed => 'Başarısız';

  @override
  String get required_field => 'Zorunlu Alan';

  @override
  String get min_length_2 => 'Minimum 2 karakter uzunluğunda olmalıdır';

  @override
  String get min_length_3 => 'Minimum 3 karakter uzunluğunda olmalıdır';

  @override
  String get min_length_4 => 'Minimum 4 karakter uzunluğunda olmalıdır';

  @override
  String get min_length_5 => 'Minimum 5 karakter uzunluğunda olmalıdır';

  @override
  String get max_length_10 => 'Maksimum 10 karakter uzunluğunda olmalıdır';

  @override
  String get max_length_20 => 'Maksimum 20 karakter uzunluğunda olmalıdır';

  @override
  String get max_length_50 => 'Maksimum 50 karakter uzunluğunda olmalıdır';

  @override
  String get max_length_100 => 'Maksimum 100 karakter uzunluğunda olmalıdır';

  @override
  String get max_length_250 => 'Maksimum 250 karakter uzunluğunda olmalıdır';

  @override
  String get max_length_500 => 'Maksimum 500 karakter uzunluğunda olmalıdır';

  @override
  String get max_length_1000 => 'Maksimum 1000 karakter uzunluğunda olmalıdır';

  @override
  String get max_length_4000 => 'Maksimum 4000 karakter uzunluğunda olmalıdır';

  @override
  String get required_range => 'Aralık gereklidir';

  @override
  String get list => 'Listele';

  @override
  String get filter => 'Filtrele';

  @override
  String get list_user => 'Kullanıcılar';

  @override
  String get new_user => 'Yeni Kullanıcı Ekle';

  @override
  String get edit_user => 'Kullanıcı Düzenle';

  @override
  String get view_user => 'Kullanıcı Görüntüle';

  @override
  String get delete_user => 'Kullanıcı Sil';

  @override
  String get email_pattern => 'E-posta adresi geçerli değil';

  @override
  String get turkish => 'Türkçe';

  @override
  String get english => 'İngilizce';

  @override
  String get create_user => 'Kullanıcı Oluştur';

  @override
  String get save => 'Kaydet';

  @override
  String get back => 'Geri';

  @override
  String get delete_confirmation => 'Silmek istediğinize emin misiniz?';

  @override
  String get settings => 'Ayarlar';

  @override
  String get account => 'Hesabım';

  @override
  String get change_password => 'Şifre Değiştir';

  @override
  String get language_select => 'Dil Seçimi';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get logout_sure => 'Çıkış yapmak istediğinize emin misiniz?';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get warning => 'Uyarı';

  @override
  String get unsaved_changes => 'Kaydedilmemiş değişiklikleriniz var. Çıkmak istediğinize emin misiniz?';

  @override
  String get no_changes_made => 'Değişiklik yapılmadı';

  @override
  String get no_data => 'Veri Yok';

  @override
  String get login_user_name => 'Kullanıcı adı';

  @override
  String get login_password => 'Şifre';

  @override
  String get current_password => 'Mevcut Şifre';

  @override
  String get new_password => 'Yeni Şifre';

  @override
  String get password_forgot => 'Şifremi unuttum';

  @override
  String get register => 'Kayıt Ol';

  @override
  String get password_max_length => 'Şifre en fazla 20 karakter uzunluğunda olmalıdır';

  @override
  String get password_min_length => 'Şifre en az 6 karakter uzunluğunda olmalıdır';

  @override
  String get login_button => 'Giriş Yap';

  @override
  String get loading => 'Loading...';

  @override
  String get email_send => 'E-posta Gönder';

  @override
  String translate_menu_title(String translate) {
    String _temp0 = intl.Intl.selectLogic(
      translate,
      {
        'account': 'Hesabım',
        'userManagement': 'Kullanıcı Yönetimi',
        'settings': 'Ayarlar',
        'logout': 'Çıkış',
        'info': 'Bilgiler',
        'language': 'Diller',
        'theme': 'Tema',
        'new_user': 'Yeni Kullanıcı Ekle',
        'list_user': 'Kullanıcılar',
        'other': 'Diğer',
      },
    );
    return '$_temp0';
  }

  @override
  String get login_with_email => 'E-posta ile Giriş';

  @override
  String get send_otp_code => 'OTP Kodu Gönder';

  @override
  String get invalid_email => 'Geçersiz e-posta adresi';

  @override
  String get resend_otp_code => 'OTP Kodu Tekrar Gönder';

  @override
  String get verify_otp_code => 'OTP Kodu Doğrula';

  @override
  String get only_numbers => 'Sadece sayılar kullanılabilir';

  @override
  String get otp_length => 'OTP 6 haneli olmalıdır';

  @override
  String get otp_code => 'OTP Kodu';

  @override
  String get otp_sent_to => 'OTP kodu gönderildi';

  @override
  String get taskSaveScreenTitle => 'Görev Kaydet';

  @override
  String get taskName => 'Görev Adı';

  @override
  String get taskPrice => 'Görev Fiyatı';

  @override
  String get theme => 'Tema';

  @override
  String get language => 'Dil';

  @override
  String get dashboard => 'Panel';

  @override
  String get refresh => 'Yenile';

  @override
  String get leads => 'Adaylar';

  @override
  String get customers => 'Müşteriler';

  @override
  String get revenue => 'Gelir';

  @override
  String get chart_kpi_placeholder => 'Grafik / KPI Alanı';

  @override
  String get recent_activity => 'Son Aktivite';

  @override
  String get sample_activity_item => 'Örnek aktivite';

  @override
  String get subtitle_context => 'Alt başlık / Bağlam';

  @override
  String get just_now => 'az önce';

  @override
  String get quick_actions => 'Hızlı İşlemler';

  @override
  String get new_lead => 'Yeni Aday';

  @override
  String get add_task => 'Görev Ekle';

  @override
  String get new_deal => 'Yeni Anlaşma';

  @override
  String get send_email_action => 'E-posta Gönder';

  @override
  String get more => 'Daha Fazla';

  @override
  String get nav_overview => 'Genel Bakış';

  @override
  String get nav_manage => 'Yönetim';

  @override
  String get nav_apps => 'Uygulamalar';

  @override
  String get nav_build => 'Oluştur';

  @override
  String get nav_orders => 'Siparişler';

  @override
  String get nav_customers => 'Müşteriler';

  @override
  String get nav_products => 'Ürünler';

  @override
  String get nav_inbox => 'Gelen Kutusu';

  @override
  String get nav_board => 'Pano';

  @override
  String get nav_calendar => 'Takvim';

  @override
  String get nav_chat => 'Sohbet';

  @override
  String get nav_components => 'Bileşenler';

  @override
  String get nav_forms => 'Formlar';

  @override
  String get nav_wizard => 'Sihirbaz';

  @override
  String get nav_profile => 'Profil';

  @override
  String get workspace_overview => 'Çalışma alanı genel bakışı';

  @override
  String get tasks => 'Görevler';

  @override
  String get apps => 'Uygulamalar';

  @override
  String get users => 'Kullanıcılar';
}
