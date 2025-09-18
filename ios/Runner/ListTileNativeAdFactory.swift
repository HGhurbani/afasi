import Foundation
import GoogleMobileAds
import UIKit

/// Factory that builds a list-tile styled native ad view matching the Flutter layout expectations.
final class ListTileNativeAdFactory: NSObject, GADNativeAdFactory {
  func createNativeAd(
    _ nativeAd: GADNativeAd,
    customOptions: [AnyHashable: Any]? = nil
  ) -> GADNativeAdView? {
    let adView = GADNativeAdView(frame: .zero)
    adView.translatesAutoresizingMaskIntoConstraints = false
    adView.backgroundColor = UIColor.secondarySystemBackground
    adView.layer.cornerRadius = 12
    adView.clipsToBounds = true

    let contentLayoutGuide = adView.layoutMarginsGuide
    adView.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

    // Icon view set to a fixed square size to resemble a list tile thumbnail.
    let iconImageView = UIImageView(frame: .zero)
    iconImageView.translatesAutoresizingMaskIntoConstraints = false
    iconImageView.contentMode = .scaleAspectFill
    iconImageView.layer.cornerRadius = 8
    iconImageView.clipsToBounds = true
    iconImageView.setContentHuggingPriority(.required, for: .horizontal)
    iconImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
    NSLayoutConstraint.activate([
      iconImageView.widthAnchor.constraint(equalToConstant: 60),
      iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor)
    ])

    // Headline label uses a semibold font similar to Flutter's ListTile.
    let headlineLabel = UILabel()
    headlineLabel.translatesAutoresizingMaskIntoConstraints = false
    headlineLabel.font = UIFont.preferredFont(forTextStyle: .headline)
    headlineLabel.numberOfLines = 2

    // Advertiser label shown beneath the headline if available.
    let advertiserLabel = UILabel()
    advertiserLabel.translatesAutoresizingMaskIntoConstraints = false
    advertiserLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    advertiserLabel.textColor = .secondaryLabel
    advertiserLabel.numberOfLines = 1

    // Primary call-to-action button aligned to the trailing edge.
    let callToActionButton = UIButton(type: .system)
    callToActionButton.translatesAutoresizingMaskIntoConstraints = false
    callToActionButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
    callToActionButton.backgroundColor = UIColor.systemBlue
    callToActionButton.tintColor = .white
    callToActionButton.layer.cornerRadius = 8
    callToActionButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    callToActionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    callToActionButton.setContentHuggingPriority(.required, for: .horizontal)
    callToActionButton.isUserInteractionEnabled = false

    let topTextStack = UIStackView(arrangedSubviews: [headlineLabel, advertiserLabel])
    topTextStack.translatesAutoresizingMaskIntoConstraints = false
    topTextStack.axis = .vertical
    topTextStack.spacing = 2

    let topRowStack = UIStackView(arrangedSubviews: [iconImageView, topTextStack, callToActionButton])
    topRowStack.translatesAutoresizingMaskIntoConstraints = false
    topRowStack.axis = .horizontal
    topRowStack.alignment = .center
    topRowStack.spacing = 12

    // Body label is shown beneath the top row to provide additional ad details.
    let bodyLabel = UILabel()
    bodyLabel.translatesAutoresizingMaskIntoConstraints = false
    bodyLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
    bodyLabel.textColor = .secondaryLabel
    bodyLabel.numberOfLines = 0

    let contentStack = UIStackView(arrangedSubviews: [topRowStack, bodyLabel])
    contentStack.translatesAutoresizingMaskIntoConstraints = false
    contentStack.axis = .vertical
    contentStack.spacing = 8

    adView.addSubview(contentStack)
    NSLayoutConstraint.activate([
      contentStack.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
      contentStack.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
      contentStack.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
      contentStack.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor)
    ])

    adView.headlineView = headlineLabel
    adView.bodyView = bodyLabel
    adView.iconView = iconImageView
    adView.callToActionView = callToActionButton
    adView.advertiserView = advertiserLabel

    headlineLabel.text = nativeAd.headline
    adView.nativeAd = nativeAd

    if let body = nativeAd.body, !body.isEmpty {
      bodyLabel.text = body
      bodyLabel.isHidden = false
    } else {
      bodyLabel.isHidden = true
    }

    if let advertiser = nativeAd.advertiser, !advertiser.isEmpty {
      advertiserLabel.text = advertiser
      advertiserLabel.isHidden = false
    } else {
      advertiserLabel.isHidden = true
    }

    if let callToAction = nativeAd.callToAction, !callToAction.isEmpty {
      callToActionButton.setTitle(callToAction, for: .normal)
      callToActionButton.isHidden = false
    } else {
      callToActionButton.isHidden = true
    }

    if let icon = nativeAd.icon?.image {
      iconImageView.image = icon
      iconImageView.isHidden = false
    } else {
      iconImageView.isHidden = true
    }

    return adView
  }
}
