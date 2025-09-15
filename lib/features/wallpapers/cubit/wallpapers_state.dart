part of 'wallpapers_cubit.dart';

const Object _unset = Object();

enum WallpapersStatus { initial, loading, success, failure }

class WallpapersState extends Equatable {
  const WallpapersState({
    this.status = WallpapersStatus.initial,
    this.images = const [],
    this.errorMessage,
    this.listBannerAd,
    this.detailBannerAd,
  });

  final WallpapersStatus status;
  final List<BlogImage> images;
  final String? errorMessage;
  final BannerAd? listBannerAd;
  final BannerAd? detailBannerAd;

  WallpapersState copyWith({
    WallpapersStatus? status,
    List<BlogImage>? images,
    Object? errorMessage = _unset,
    Object? listBannerAd = _unset,
    Object? detailBannerAd = _unset,
  }) {
    return WallpapersState(
      status: status ?? this.status,
      images: images ?? this.images,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      listBannerAd: identical(listBannerAd, _unset)
          ? this.listBannerAd
          : listBannerAd as BannerAd?,
      detailBannerAd: identical(detailBannerAd, _unset)
          ? this.detailBannerAd
          : detailBannerAd as BannerAd?,
    );
  }

  @override
  List<Object?> get props => [
        status,
        images,
        errorMessage,
        listBannerAd,
        detailBannerAd,
      ];
}

class WallpapersActionResult {
  const WallpapersActionResult._(this.success, this.message);

  const WallpapersActionResult.success(String message)
      : this._(true, message);

  const WallpapersActionResult.failure(String message)
      : this._(false, message);

  final bool success;
  final String message;

  bool get hasMessage => message.isNotEmpty;
}
