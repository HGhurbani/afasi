class BlogImage {
  final String title;
  final String imageUrl;

  BlogImage({required this.title, required this.imageUrl});

  factory BlogImage.fromJson(Map<String, dynamic> json) {
    final imageUrl = json['imageUrl'] as String? ?? '';
    if (imageUrl.isEmpty) {
      throw const FormatException('imageUrl is required');
    }

    return BlogImage(
      title: json['title'] as String? ?? 'بدون عنوان',
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'imageUrl': imageUrl,
    };
  }
}
