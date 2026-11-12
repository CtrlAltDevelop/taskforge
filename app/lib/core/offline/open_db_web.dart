import 'package:taskforge/core/offline/local_db.dart';

/// Web: no local database (persistence in browsers is not verified), so the
/// app works online only.
LocalDb? openLocalDb() => null;
