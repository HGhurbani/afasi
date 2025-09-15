import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'blog_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/constants/app_constants.dart';

class WallpapersPage extends StatefulWidget {
  @override
  _WallpapersPageState createState() => _WallpapersPageState();
}

class _WallpapersPageState extends State<WallpapersPage> {
  List<BlogImage> images = [];
  bool isLoading = true;

  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    fetchImages();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AppConstants.bannerAdUnitId, // نفس الموجود في main
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() {}),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();
  }

  Future<void> fetchImages() async {
    try {
      final response = await http.get(Uri.parse(
        'https://appstaki.blogspot.com/feeds/posts/default?alt=atom&max-results=100',
      ));

      final document = XmlDocument.parse(response.body);
      final entries = document.findAllElements('entry');

      List<BlogImage> loadedImages = [];

      for (var entry in entries) {
        final title = entry.getElement('title')?.innerText ?? 'بدون عنوان';
        final content = entry.getElement('content')?.innerText ?? '';

        final imgMatch = RegExp(r'<img[^>]+src="([^">]+)"').firstMatch(content);
        if (imgMatch != null) {
          final imgUrl = imgMatch.group(1)!;
          loadedImages.add(BlogImage(title: title, imageUrl: imgUrl));
        }
      }

      setState(() {
        images = loadedImages;
        isLoading = false;
      });
    } catch (e) {
      print("❌ خطأ أثناء جلب الصور: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'الصور والخلفيات',
            style: TextStyle(fontFamily: 'Tajawal', color: Colors.white),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : images.isEmpty
            ? const Center(child: Text('لا توجد صور حالياً'))
            : GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            final img = images[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullImageView(img: img),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(img.imageUrl, fit: BoxFit.cover),
              ),
            );
          },
        ),
        bottomNavigationBar: _bannerAd != null
            ? SizedBox(
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        )
            : null,
      ),
    );
  }
}

class FullImageView extends StatefulWidget {
  final BlogImage img;
  const FullImageView({required this.img});

  @override
  State<FullImageView> createState() => _FullImageViewState();
}

class _FullImageViewState extends State<FullImageView> {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  int _actionCounter = 0;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AppConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() {}),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();
  }

  Future<bool> _requestImagePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.photos.isGranted || await Permission.mediaLibrary.isGranted) {
        return true;
      }

      // Android 13+ requires READ_MEDIA_IMAGES
      if (await Permission.photos.request().isGranted) return true;
      if (await Permission.mediaLibrary.request().isGranted) return true;
      if (await Permission.storage.request().isGranted) return true;

      return false;
    } else {
      return true; // iOS أو غيره
    }
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AppConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  void _maybeShowAd() {
    _actionCounter++;
    if (_actionCounter >= 3 && _interstitialAd != null) {
      _interstitialAd!.show();
      _actionCounter = 0;
      _loadInterstitialAd();
    }
  }

  Future<void> _downloadImage(String url) async {
    _maybeShowAd();

    bool hasPermission = false;

    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted ||
          await Permission.photos.isGranted ||
          await Permission.mediaLibrary.isGranted) {
        hasPermission = true;
      } else {
        PermissionStatus status = await Permission.manageExternalStorage.request();
        hasPermission = status.isGranted;
      }
    } else {
      hasPermission = true; // iOS أو أنظمة أخرى
    }

    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📛 يجب منح إذن التخزين أولاً")),
      );
      return;
    }

    try {
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;

      final dir = Directory('/storage/emulated/0/Pictures/Alafasi');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      final file = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ تم حفظ الصورة في المعرض (مجلد Alafasi)")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ فشل حفظ الصورة: $e")),
      );
    }
  }


  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.photos.isGranted) return true;

      final status = await Permission.photos.request();
      return status.isGranted;
    } else {
      return true; // iOS أو غيره
    }
  }



  Future<void> _shareImage(String url) async {
    _maybeShowAd();

    bool isGranted = await _requestStoragePermission();
    if (!isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📛 يجب منح إذن التخزين أولاً")),
      );
      return;
    }

    try {
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;

      final dir = await getExternalStorageDirectory();
      final filePath = '${dir!.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: widget.img.title.trim().isNotEmpty ? widget.img.title : 'صورة رائعة من التطبيق',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ فشل مشاركة الصورة: $e")),
      );
    }
  }



  Future<void> _setWallpaper(String url, int location) async {
    _maybeShowAd();

    final status = await _requestImagePermission();
    if (!status) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يجب منح إذن الصور أولاً")),
      );
      return;
    }


    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final response = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    try {
      await WallpaperManagerFlutter().setwallpaperfromFile(file, location);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ تم تعيين الخلفية بنجاح")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ فشل تعيين الخلفية: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.img.title)),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Image.network(widget.img.imageUrl),
              ),
            ),
            Container(
              color: Theme.of(context).primaryColor,
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _downloadImage(widget.img.imageUrl),
                    icon: const Icon(Icons.download),
                    label: const Text("تحميل"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _shareImage(widget.img.imageUrl),
                    icon: const Icon(Icons.share),
                    label: const Text("مشاركة"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showWallpaperOptions(widget.img.imageUrl),
                    icon: const Icon(Icons.wallpaper),
                    label: const Text("تعيين خلفية"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (_bannerAd != null)
              SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }
  void _showWallpaperOptions(String url) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("الشاشة الرئيسية"),
              onTap: () {
                Navigator.pop(context);
                _setWallpaper(url, WallpaperManagerFlutter.HOME_SCREEN);
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("شاشة القفل"),
              onTap: () {
                Navigator.pop(context);
                _setWallpaper(url, WallpaperManagerFlutter.LOCK_SCREEN);
              },
            ),
            ListTile(
              leading: const Icon(Icons.smartphone),
              title: const Text("كلا الشاشتين"),
              onTap: () {
                Navigator.pop(context);
                _setWallpaper(url, WallpaperManagerFlutter.BOTH_SCREENS);
              },
            ),
          ],
        );
      },
    );
  }

}
