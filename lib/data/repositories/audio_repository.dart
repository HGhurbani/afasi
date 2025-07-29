
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/models/supplication.dart';
import '../../core/models/audio_category.dart';

abstract class AudioRepository {
  List<AudioCategory> getAudioCategories();
  List<Supplication> getSupplicationsByCategory(String category);
}

class AudioRepositoryImpl implements AudioRepository {
  @override
  List<AudioCategory> getAudioCategories() {
    return [
      AudioCategory(name: "القرآن الكريم", supplications: _getQuranSupplications()),
      AudioCategory(name: "الأناشيد", supplications: _getAnasheedSupplications()),
      AudioCategory(name: "الأذكار", supplications: _getAdhkarSupplications()),
      AudioCategory(name: "الأدعية", supplications: _getAdeyaSupplications()),
      AudioCategory(name: "رمضانيات", supplications: _getRamadanSupplications()),
      AudioCategory(name: "الرقية الشرعية", supplications: _getRuqyaSupplications()),
    ];
  }

  @override
  List<Supplication> getSupplicationsByCategory(String category) {
    final categories = getAudioCategories();
    final categoryData = categories.firstWhere(
      (cat) => cat.name == category,
      orElse: () => categories.first,
    );
    return categoryData.supplications;
  }

  List<Supplication> _getQuranSupplications() {
    return [
      const Supplication(
        title: "آيات الشفاء في القرآن الكريم",
        audioUrl: "assets/audio/mishary13.mp3",
        textAssetPath: "assets/texts/شفاء.txt",
        icon: FontAwesomeIcons.quran,
        isLocalAudio: true,
      ),
      const Supplication(
        title: "سورة الكهف",
        audioUrl: "https://www.youtube.com/watch?v=-FxEYa8joK8",
        textAssetPath: "assets/texts/كهف.txt",
        icon: FontAwesomeIcons.quran,
      ),
      // باقي سور القرآن...
    ];
  }

  List<Supplication> _getAnasheedSupplications() {
    return [
      const Supplication(
        title: "عمر الفاروق",
        audioUrl: "https://www.youtube.com/watch?v=Gkflvn9v8Os&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR",
        textAssetPath: "assets/texts/عمر-الفاروق.txt",
        icon: FontAwesomeIcons.music,
      ),
      // باقي الأناشيد...
    ];
  }

  List<Supplication> _getAdhkarSupplications() {
    return [
      const Supplication(
        title: "أذكار الصباح",
        audioUrl: "assets/audio/mishary1.mp3",
        textAssetPath: "assets/texts/صباح.txt",
        icon: FontAwesomeIcons.solidSun,
        isLocalAudio: true,
      ),
      const Supplication(
        title: "أذكار المساء",
        audioUrl: "assets/audio/mishary2.mp3",
        textAssetPath: "assets/texts/مساء.txt",
        icon: FontAwesomeIcons.moon,
        isLocalAudio: true,
      ),
      // باقي الأذكار...
    ];
  }

  List<Supplication> _getRamadanSupplications() {
    return [
      const Supplication(
        title: "دعاء بلوغ رمضان",
        audioUrl: "https://www.youtube.com/watch?v=mGYScZSGNMY&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=80",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.moon,
      ),
      // باقي رمضانيات...
    ];
  }

  List<Supplication> _getAdeyaSupplications() {
    return [
      const Supplication(
        title: "دعاء السفر",
        audioUrl: "assets/audio/mishary3.mp3",
        textAssetPath: "assets/texts/سفر.txt",
        icon: FontAwesomeIcons.planeDeparture,
        isLocalAudio: true,
      ),
      // باقي الأدعية...
    ];
  }

  List<Supplication> _getRuqyaSupplications() {
    return [
      const Supplication(
        title: "الرقية الشرعية",
        audioUrl: "assets/audio/mishary8.mp3",
        textAssetPath: "assets/texts/الرقية.txt",
        icon: FontAwesomeIcons.shieldHalved,
        isLocalAudio: true,
      ),
      // باقي الرقية...
    ];
  }
}
