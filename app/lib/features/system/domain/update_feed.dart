import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:taskforge/core/version.dart';

/// Where desktop builds look for the newest release: the JSON of a GitHub
/// "latest release" (`.../releases/latest`). Empty: no check is made.
const updateFeedUrl = String.fromEnvironment('UPDATE_FEED_URL');

/// A published release: its version and the page to download it from.
@immutable
class ReleaseInfo {
  const ReleaseInfo({required this.version, this.downloadUrl = ''});

  final String version;
  final String downloadUrl;

  /// Reads a GitHub release; null when the body is not one or has no version.
  static ReleaseInfo? fromJson(String body) {
    try {
      final json = jsonDecode(body);
      if (json is! Map<String, dynamic>) return null;
      final tag = json['tag_name'];
      if (tag is! String || parseSemVer(tag) == null) return null;
      final url = json['html_url'];
      return ReleaseInfo(
        version: tag.startsWith('v') ? tag.substring(1) : tag,
        downloadUrl: url is String && url.startsWith('https://') ? url : '',
      );
    } on FormatException {
      return null;
    }
  }

  bool isNewerThan(String client) => (compareSemVer(version, client) ?? 0) > 0;
}

/// What the banner says: the newest version known and, when the feed gave
/// one, where to get it.
@immutable
class UpdateNotice {
  const UpdateNotice({required this.version, this.downloadUrl = ''});

  final String version;
  final String downloadUrl;
}
