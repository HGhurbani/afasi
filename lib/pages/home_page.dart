// lib/pages/home_page.dart
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/supplication.dart';
import '../data/audio_data.dart';
import '../managers/ad_manager.dart';
import 'text_reader_page.dart';

class HomePage extends StatefulWidget {
  final bool isDarkMode; // سنأخذ المعلومة من MyApp

  const HomePage({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // الأقسام
  String _selectedCategory = "الأذكار";

  // قائمة الصوتيات المعروضة بناءً على القسم والبحث
  List<Supplication> filteredSupplications = [];

  // قائمة المفضلة
  final List<Supplication> favorites = [];

  // حقل البحث
  final TextEditingController _searchController = TextEditingController();

  // مشغل الصوت
  final AudioPlayer _audioPlayer = AudioPlayer();

  // الصوت الجاري تشغيله
  Supplication? _currentSupplication;

  // الكاش لروابط يوتيوب
  final Map<String, String> _youtubeCache = {};

  // خصائص التحكم في التشغيل
  bool _isAutoNext = false;
  bool _isRepeat = false;

  // Banner Ad
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    // تحميل القائمة بناءً على القسم الافتراضي
    filteredSupplications = List<Supplication>.from(audioCategories[_selectedCategory]!);

    // استماع لانتهاء التشغيل
    _audioPlayer.processingStateStream.listen((processingState) {
      if (processingState == ProcessingState.completed) {
        if (_isAutoNext) {
          _playNext();
        }
      }
    });

    loadLastCategory();
    loadFavorites();
    checkDownloadedStatus();

    // تحميل إعلانات
    AdManager.loadBannerAd(
      onBannerLoaded: (ad) {
        setState(() {});
      },
      onBannerFailed: (ad, error) {},
    );
    _bannerAd = AdManager.bannerAd;

    AdManager.loadInterstitialAd();
    AdManager.loadRewardedAd();

    // الاستماع لحالة التشغيل
    _audioPlayer.playingStream.listen((isPlaying) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _bannerAd?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ------------------ التحميل والحفظ للمفضلة والقسم ------------------

  Future<void> loadLastCategory() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCategory = prefs.getString('lastCategory');
    if (lastCategory != null && audioCategories.containsKey(lastCategory)) {
      setState(() {
        _selectedCategory = lastCategory;
        filteredSupplications = lastCategory == "المفضلة"
            ? List<Supplication>.from(favorites)
            : List<Supplication>.from(audioCategories[lastCategory]!);
      });
    }
  }

  void updateCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastCategory', category);
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
      filteredSupplications = category == "المفضلة"
          ? List<Supplication>.from(favorites)
          : List<Supplication>.from(audioCategories[category]!);
    });
    Navigator.pop(context); // إغلاق القائمة الجانبية
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? favTitles = prefs.getStringList('favorites');
    if (favTitles != null) {
      favorites.clear();
      audioCategories.forEach((category, suppList) {
        for (var supp in suppList) {
          if (favTitles.contains(supp.title)) {
            favorites.add(supp);
          }
        }
      });
      if (_selectedCategory == "المفضلة") {
        setState(() {
          filteredSupplications = List<Supplication>.from(favorites);
        });
      }
    }
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favTitles = favorites.map((fav) => fav.title).toList();
    await prefs.setStringList('favorites', favTitles);
  }

  // ------------------ تشغيل الصوت ------------------

  Future<void> playAudio(Supplication supp) async {
    setState(() {
      _currentSupplication = supp;
    });

    // لو كان الصوت أصلاً موجودًا في assets
    if (supp.isLocalAudio) {
      try {
        await _audioPlayer.setAsset(supp.audioUrl);
        _audioPlayer.play();
        return;
      } catch (e) {
        print("Error playing local audio: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ في تشغيل الصوت المحلي.')),
        );
        return;
      }
    }

    // لو كان الصوت محملاً مسبقًا في الجهاز
    final dir = await getApplicationSupportDirectory();
    final filePath = '${dir.path}/${supp.title}.mp3';
    if (await isFileExists(filePath)) {
      supp.isDownloaded = true;
      try {
        await _audioPlayer.setFilePath(filePath);
        _audioPlayer.play();
        return;
      } catch (e) {
        print("Error playing downloaded audio: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ في تشغيل الملف الصوتي المحمل.')),
        );
        return;
      }
    }

    // لو لم يكن هناك إنترنت
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد إنترنت.')),
      );
      return;
    }

    // التعامل مع روابط اليوتيوب
    String source;
    if (supp.audioUrl.contains("youtube.com") ||
        supp.audioUrl.contains("youtu.be")) {
      final String? videoId = extractYoutubeVideoId(supp.audioUrl);
      if (videoId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('رابط تحميل غير صالح.')),
        );
        return;
      }
      if (_youtubeCache.containsKey(videoId)) {
        source = _youtubeCache[videoId]!;
      } else {
        showLoadingDialog("جاري تجهيز الصوت ...");
        final yt = YoutubeExplode();
        try {
          final manifest = await yt.videos.streamsClient.getManifest(videoId);
          final audioStreamInfo = manifest.audioOnly.withHighestBitrate();
          source = audioStreamInfo.url.toString();
          _youtubeCache[videoId] = source;
        } catch (e) {
          print("Error extracting YouTube audio: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('خطأ في استخراج الصوت حاول مرة آخرى.')),
          );
          yt.close();
          Navigator.pop(context);
          return;
        }
        yt.close();
        Navigator.pop(context);
      }
    } else {
      // رابط مباشر
      source = supp.audioUrl;
    }

    try {
      await _audioPlayer.setUrl(source);
      _audioPlayer.play();
    } catch (e) {
      print("Error playing audio: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ في تشغيل الصوت.')),
      );
    }
  }

  void pauseAudio() {
    _audioPlayer.pause();
    setState(() {});
  }

  // ------------------ عمليات التنقل بين الصوتيات ------------------

  void _playNext() {
    if (_currentSupplication == null) return;
    final int currentIndex = filteredSupplications
        .indexWhere((s) => s.title == _currentSupplication!.title);
    if (currentIndex < filteredSupplications.length - 1) {
      playAudio(filteredSupplications[currentIndex + 1]);
    }
  }

  void _playPrevious() {
    if (_currentSupplication == null) return;
    final int currentIndex = filteredSupplications
        .indexWhere((s) => s.title == _currentSupplication!.title);
    if (currentIndex > 0) {
      playAudio(filteredSupplications[currentIndex - 1]);
    }
  }

  void _rewind10() {
    final Duration current = _audioPlayer.position;
    final Duration newPosition = current - const Duration(seconds: 10);
    _audioPlayer.seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  void _forward10() {
    final Duration current = _audioPlayer.position;
    final Duration duration = _audioPlayer.duration ?? Duration.zero;
    final Duration newPosition = current + const Duration(seconds: 10);
    _audioPlayer.seek(newPosition > duration ? duration : newPosition);
  }

  void _togglePlayPause() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
    setState(() {});
  }

  // ------------------ التحميل ------------------

  Future<void> downloadAudio(Supplication supp) async {
    if (supp.isLocalAudio) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الصوت متاح بالفعل دون إنترنت.')),
      );
      return;
    }

    // فحص هل الصوت محمل مسبقا؟
    final dir = await getApplicationSupportDirectory();
    final filePath = '${dir.path}/${supp.title}.mp3';
    if (await isFileExists(filePath)) {
      supp.isDownloaded = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الصوت متاح بالفعل دون إنترنت.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: const [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(
              child: Text("يرجى الانتظار حتى يبدأ التحميل", textDirection: TextDirection.rtl),
            ),
          ],
        ),
      ),
    );
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pop(context);

    // التعامل مع رابط اليوتيوب أو الرابط المباشر
    String urlToDownload = supp.audioUrl;
    if (supp.audioUrl.contains("youtube.com") ||
        supp.audioUrl.contains("youtu.be")) {
      final yt = YoutubeExplode();
      final String? videoId = extractYoutubeVideoId(supp.audioUrl);
      if (videoId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الصوت غير صالح.')),
        );
        return;
      }
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      final audioStreamInfo = manifest.audioOnly.withHighestBitrate();
      urlToDownload = audioStreamInfo.url.toString();
      yt.close();
    }

    try {
      final client = http.Client();
      final request = http.Request("GET", Uri.parse(urlToDownload));
      final response = await client.send(request);

      final int contentLength = response.contentLength ?? 0;
      int downloadedBytes = 0;
      final List<int> bytes = [];

      final progressNotifier = ValueNotifier<double>(0.0);
      final downloadedBytesNotifier = ValueNotifier<int>(0);
      final pausedNotifier = ValueNotifier<bool>(false);
      StreamSubscription<List<int>>? subscription;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ValueListenableBuilder<double>(
            valueListenable: progressNotifier,
            builder: (context, progress, _) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(value: progress),
                    const SizedBox(height: 20),
                    Text(
                      "جاري تحميل الصوت... ${(progress * 100).toStringAsFixed(0)}%",
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                actions: [
                  ValueListenableBuilder<bool>(
                    valueListenable: pausedNotifier,
                    builder: (context, paused, _) {
                      return TextButton(
                        onPressed: () {
                          if (subscription != null) {
                            if (!paused) {
                              subscription!.pause();
                              pausedNotifier.value = true;
                            } else {
                              subscription!.resume();
                              pausedNotifier.value = false;
                            }
                          }
                        },
                        child: Text(paused ? "استئناف" : "إيقاف مؤقت"),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      );

      subscription = response.stream.listen(
        (newBytes) {
          bytes.addAll(newBytes);
          downloadedBytes += newBytes.length;
          downloadedBytesNotifier.value = downloadedBytes;
          if (contentLength > 0) {
            progressNotifier.value = downloadedBytes / contentLength;
          }
        },
      );

      await subscription.asFuture();
      Navigator.pop(context);
      client.close();

      final file = await saveFile(bytes, filePath);
      setState(() {
        supp.isDownloaded = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحميل ${supp.title} بنجاح!')),
      );
    } catch (e) {
      Navigator.pop(context);
      print("Download error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء التحميل أعد المحاولة.')),
      );
    }
  }

  // ------------------ قراءة النص ------------------

  Future<void> readText(Supplication supp) async {
    try {
      final String content = await rootBundle.loadString(supp.textAssetPath);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TextReaderPage(title: supp.title, content: content),
        ),
      );
    } catch (e) {
      print("Error loading text: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء قراءة النص أو لا يوجد نص.')),
      );
    }
  }

  // ------------------ واجهة المستخدم العامة ------------------

  String get appBarTitle => _selectedCategory;

  Color get accentBlue => widget.isDarkMode ? Colors.blueGrey : const Color(0xFF3498DB);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            appBarTitle,
            style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: showInstructions,
              tooltip: 'تعليمات الاستخدام',
            ),
            IconButton(
              icon: const Icon(Icons.volunteer_activism, color: Colors.white),
              onPressed: () {
                confirmAndShowRewardedAd();
              },
              tooltip: 'تبرع بمشاهدة إعلان',
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                child: const Center(
                  child: Text(
                    'الشيخ مشاري العفاسي',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.book, color: Theme.of(context).primaryColor),
                title: const Text("القرآن الكريم"),
                onTap: () => updateCategory("القرآن الكريم"),
              ),
              ListTile(
                leading: Icon(Icons.music_note, color: Theme.of(context).primaryColor),
                title: const Text("الأناشيد"),
                onTap: () => updateCategory("الأناشيد"),
              ),
              ListTile(
                leading: Icon(Icons.accessibility_new, color: Theme.of(context).primaryColor),
                title: const Text("الأذكار"),
                onTap: () => updateCategory("الأذكار"),
              ),
              ListTile(
                leading: Icon(Icons.record_voice_over, color: Theme.of(context).primaryColor),
                title: const Text("الأدعية"),
                onTap: () => updateCategory("الأدعية"),
              ),
              ListTile(
                leading: Icon(Icons.dark_mode, color: Theme.of(context).primaryColor),
                title: const Text("رمضانيات"),
                onTap: () => updateCategory("رمضانيات"),
              ),
              ListTile(
                leading: Icon(Icons.healing, color: Theme.of(context).primaryColor),
                title: const Text("الرقية الشرعية"),
                onTap: () => updateCategory("الرقية الشرعية"),
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.favorite, color: Theme.of(context).primaryColor),
                title: const Text("المفضلة"),
                onTap: () => updateCategory("المفضلة"),
              ),
              ListTile(
                leading: Icon(Icons.help, color: Theme.of(context).primaryColor),
                title: const Text("تعليمات الاستخدام"),
                onTap: () {
                  Navigator.pop(context);
                  showInstructions();
                },
              ),
              ListTile(
                leading: Icon(Icons.privacy_tip, color: Theme.of(context).primaryColor),
                title: const Text("سياسة الخصوصية"),
                onTap: () {
                  Navigator.pop(context);
                  showPrivacyPolicyDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.shop, color: Theme.of(context).primaryColor),
                title: const Text("تطبيق القرآن الكريم"),
                onTap: () async {
                  Navigator.pop(context);
                  final Uri url = Uri.parse(
                      'https://play.google.com/store/apps/details?id=com.quran.kareem.islamic');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('لا يمكن فتح الرابط.')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // حقل البحث
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'ابحث هنا',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: filterSearchResults,
              ),
            ),
            // القائمة
            Expanded(
              child: ListView.builder(
                itemCount: filteredSupplications.length,
                itemBuilder: (context, index) {
                  final supp = filteredSupplications[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      onTap: () {
                        if (_currentSupplication != null &&
                            _currentSupplication!.title == supp.title &&
                            _audioPlayer.playing) {
                          pauseAudio();
                        } else {
                          playAudio(supp);
                          AdManager.checkAndShowInterstitialAd();
                        }
                      },
                      title: Text(supp.title),
                      subtitle: Text(
                        (supp.isLocalAudio || supp.isDownloaded)
                            ? 'متاح بدون إنترنت'
                            : 'قم بالتحميل لإستماع بدون إنترنت',
                        style: TextStyle(
                          color: (supp.isLocalAudio || supp.isDownloaded)
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      trailing: Wrap(
                        spacing: 12,
                        children: [
                          IconButton(
                            icon: Icon(
                              (_currentSupplication != null &&
                                      _currentSupplication!.title == supp.title &&
                                      _audioPlayer.playing)
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              if (_currentSupplication != null &&
                                  _currentSupplication!.title == supp.title &&
                                  _audioPlayer.playing) {
                                pauseAudio();
                              } else {
                                playAudio(supp);
                                AdManager.checkAndShowInterstitialAd();
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.download,
                              color: (supp.isLocalAudio || supp.isDownloaded)
                                  ? Colors.grey
                                  : Theme.of(context).primaryColor,
                            ),
                            onPressed: (supp.isLocalAudio || supp.isDownloaded)
                                ? () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'الصوت متاح بالفعل دون إنترنت.')),
                                    );
                                  }
                                : () {
                                    downloadAudio(supp);
                                  },
                            tooltip: 'تحميل الصوت',
                          ),
                          IconButton(
                            icon: Icon(
                              favorites.any((fav) => fav.title == supp.title)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                if (favorites.any((fav) => fav.title == supp.title)) {
                                  favorites.removeWhere((fav) => fav.title == supp.title);
                                } else {
                                  favorites.add(supp);
                                }
                                if (_selectedCategory == "المفضلة") {
                                  filteredSupplications = List<Supplication>.from(favorites);
                                }
                              });
                              saveFavorites();
                            },
                            tooltip: 'إضافة إلى المفضلة',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // عرض البانر إن توفر
            if (_bannerAd != null)
              SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                width: _bannerAd!.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
        bottomNavigationBar: _currentSupplication != null ? _buildAudioPlayer() : null,
      ),
    );
  }

  // ------------------ Widgets المساعدة ------------------

  Widget _buildAudioPlayer() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // العنوان وزر الإغلاق
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _currentSupplication?.title ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _currentSupplication = null;
                    });
                  },
                  tooltip: 'إغلاق المشغل',
                ),
              ],
            ),
            // شريط التمرير
            StreamBuilder<Duration>(
              stream: _audioPlayer.positionStream,
              builder: (context, snapshot) {
                final Duration position = snapshot.data ?? Duration.zero;
                final Duration duration = _audioPlayer.duration ?? Duration.zero;
                return Column(
                  children: [
                    Slider(
                      min: 0.0,
                      max: duration.inSeconds.toDouble() > 0
                          ? duration.inSeconds.toDouble()
                          : 1.0,
                      value: position.inSeconds
                          .toDouble()
                          .clamp(0.0, duration.inSeconds.toDouble()),
                      onChanged: (value) {
                        _audioPlayer.seek(Duration(seconds: value.toInt()));
                      },
                      activeColor: Colors.white,
                      inactiveColor: Colors.white70,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatDuration(position),
                            style: const TextStyle(color: Colors.white)),
                        Text(formatDuration(duration),
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (_currentSupplication != null) {
                  readText(_currentSupplication!);
                }
              },
              icon: const Icon(Icons.menu_book),
              label: const Text("قراءة"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            // أزرار التحكم
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white),
                  onPressed: _playPrevious,
                  tooltip: 'السابق',
                ),
                IconButton(
                  icon: const Icon(Icons.replay_10, color: Colors.white),
                  onPressed: _rewind10,
                  tooltip: 'إعادة 10 ثوانٍ',
                ),
                IconButton(
                  icon: Icon(
                    _audioPlayer.playing ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: _togglePlayPause,
                  tooltip: _audioPlayer.playing ? 'إيقاف' : 'تشغيل',
                ),
                IconButton(
                  icon: const Icon(Icons.forward_10, color: Colors.white),
                  onPressed: _forward10,
                  tooltip: 'تقديم 10 ثوانٍ',
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                  onPressed: _playNext,
                  tooltip: 'التالي',
                ),
              ],
            ),
            const SizedBox(height: 4),
            // مفاتيح التكرار والتشغيل التلقائي
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Switch(
                  value: _isRepeat,
                  onChanged: (bool value) {
                    setState(() {
                      _isRepeat = value;
                      _audioPlayer.setLoopMode(
                        _isRepeat ? LoopMode.one : LoopMode.off,
                      );
                    });
                  },
                  activeColor: accentBlue,
                  activeTrackColor: Colors.white,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: accentBlue,
                ),
                const SizedBox(width: 8),
                const Text(
                  'تكرار',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Switch(
                  value: _isAutoNext,
                  onChanged: (bool value) {
                    setState(() {
                      _isAutoNext = value;
                    });
                  },
                  activeColor: accentBlue,
                  activeTrackColor: Colors.white,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: accentBlue,
                ),
                const SizedBox(width: 8),
                const Text(
                  'تشغيل التالي تلقائي',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ وظائف مساعدة ------------------

  void filterSearchResults(String query) {
    final List<Supplication> currentList = _selectedCategory == "المفضلة"
        ? favorites
        : audioCategories[_selectedCategory] ?? [];
    setState(() {
      filteredSupplications = query.isNotEmpty
          ? currentList.where((item) => item.title.contains(query)).toList()
          : List<Supplication>.from(currentList);
    });
  }

  Future<bool> isFileExists(String path) async {
    final file = await saveFile([], path, checkOnly: true);
    return file.existsSync();
  }

  Future<File> saveFile(List<int> bytes, String path, {bool checkOnly = false}) async {
    final file = File(path);
    if (!checkOnly) {
      await file.writeAsBytes(bytes);
    }
    return file;
  }

  void showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(
              child: Text(message, textDirection: TextDirection.rtl),
            ),
          ],
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String minutes = twoDigits(duration.inMinutes.remainder(60));
    final String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  String? extractYoutubeVideoId(String url) {
    final RegExp regExp = RegExp(r'(?:v=|\/)([0-9A-Za-z_-]{11}).*',
        caseSensitive: false, multiLine: false);
    final Match? match = regExp.firstMatch(url);
    return match != null ? match.group(1) : null;
  }

  // ------------------ نوافذ حوار وتعليمات ------------------

  final String privacyPolicyText = '''
سياسة الخصوصية لتطبيق مشاري العفاسي

(هنا تضع نص السياسة بالكامل كما في مشروعك)
''';

  void showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("سياسة الخصوصية"),
        content: SingleChildScrollView(
          child: Text(
            privacyPolicyText,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("حسناً"),
          ),
        ],
      ),
    );
  }

  void showInstructions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تعليمات الاستخدام'),
        content: SingleChildScrollView(
          child: const Text(
            'هنا نص تعليمات الاستخدام...\n'
            '1. ...\n'
            '2. ...\n'
            'إلخ.',
            textDirection: TextDirection.rtl,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  Future<void> confirmAndShowRewardedAd() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد'),
        content: const Text(
          'يرجى التأكيد بأنك شاهدت الإعلان لدعم التطبيق...',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لا')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('نعم')),
        ],
      ),
    );
    if (confirm == true) {
      AdManager.showRewardedAd(context);
    }
  }

  Future<void> checkDownloadedStatus() async {
    final dir = await getApplicationSupportDirectory();
    for (var category in audioCategories.keys) {
      for (var supp in audioCategories[category]!) {
        if (!supp.isLocalAudio) {
          final filePath = '${dir.path}/${supp.title}.mp3';
          if (await isFileExists(filePath)) {
            supp.isDownloaded = true;
          }
        }
      }
    }
    setState(() {});
  }
}
