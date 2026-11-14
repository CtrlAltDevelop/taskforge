import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'package:taskforge/core/auth/dpop/dpop_key.dart';

DpopKeyStore createDpopKeyStore() => WebDpopKeyStore();

/// Web: an ECDSA P-256 `CryptoKey` made with `extractable: false`, so script on the page (an XSS
/// bug, an extension) can ask the browser to sign but can never read the private key out. The key
/// object itself is kept in IndexedDB (a CryptoKey survives structured cloning), so a reload finds
/// the same key and the refresh cookie keeps working. If IndexedDB is refused (private window)
/// the key lives for the page only and the next load signs in again.
class WebDpopKeyStore implements DpopKeyStore {
  static const _database = 'taskforge-dpop';
  static const _storeName = 'keys';
  static const _recordId = 'device';

  Future<DpopSigner>? _loading;

  @override
  Future<DpopSigner> signer() => _loading ??= _loadOrCreate();

  @override
  Future<void> reset() async {
    _loading = null;
    try {
      final db = await _open();
      final store = db
          .transaction(_storeName.toJS, 'readwrite')
          .objectStore(_storeName);
      await _done(store.delete(_recordId.toJS));
      db.close();
    } on Object {
      // Nothing persisted: nothing to forget.
    }
  }

  Future<DpopSigner> _loadOrCreate() async {
    web.IDBDatabase? db;
    try {
      db = await _open();
      final stored = await _read(db);
      if (stored != null) return stored;
    } on Object {
      db = null; // IndexedDB unavailable: fall through to a page-lifetime key
    }
    final created = await _generate();
    if (db != null) {
      try {
        await _write(db, created);
      } on Object {
        // Keep the in-memory key; the next load makes another.
      }
    }
    return created;
  }

  Future<_WebSigner> _generate() async {
    final pair = await web.window.crypto.subtle
        .generateKey(
          {'name': 'ECDSA', 'namedCurve': 'P-256'}.jsify()!,
          false,
          ['sign', 'verify'].jsify()! as JSArray<JSString>,
        )
        .toDart;
    final keys = pair! as JSObject;
    final publicKey = keys.getProperty<JSObject>('publicKey'.toJS);
    final privateKey = keys.getProperty<JSObject>('privateKey'.toJS);
    return _WebSigner(privateKey, await _jwkOf(publicKey));
  }

  Future<Map<String, String>> _jwkOf(JSObject publicKey) async {
    final exported = await web.window.crypto.subtle
        .exportKey('jwk', publicKey as web.CryptoKey)
        .toDart;
    final jwk = exported! as JSObject;
    String field(String name) => jwk.getProperty<JSString>(name.toJS).toDart;
    return {'kty': 'EC', 'crv': 'P-256', 'x': field('x'), 'y': field('y')};
  }

  Future<web.IDBDatabase> _open() {
    final completer = Completer<web.IDBDatabase>();
    final request = web.window.indexedDB.open(_database, 1);
    request.onupgradeneeded = ((web.Event _) {
      (request.result! as web.IDBDatabase).createObjectStore(_storeName);
    }).toJS;
    request.onsuccess = ((web.Event _) {
      completer.complete(request.result! as web.IDBDatabase);
    }).toJS;
    request.onerror = ((web.Event _) {
      completer.completeError(StateError('IndexedDB unavailable'));
    }).toJS;
    return completer.future;
  }

  Future<JSAny?> _done(web.IDBRequest request) {
    final completer = Completer<JSAny?>();
    request.onsuccess = ((web.Event _) => completer.complete(
      request.result,
    )).toJS;
    request.onerror = ((web.Event _) {
      completer.completeError(StateError('IndexedDB request failed'));
    }).toJS;
    return completer.future;
  }

  Future<_WebSigner?> _read(web.IDBDatabase db) async {
    final store = db.transaction(_storeName.toJS).objectStore(_storeName);
    final record = await _done(store.get(_recordId.toJS));
    if (record == null || record.isUndefinedOrNull) return null;
    final object = record as JSObject;
    final privateKey = object.getProperty<JSObject>('privateKey'.toJS);
    final x = object.getProperty<JSString>('x'.toJS).toDart;
    final y = object.getProperty<JSString>('y'.toJS).toDart;
    return _WebSigner(privateKey, {
      'kty': 'EC',
      'crv': 'P-256',
      'x': x,
      'y': y,
    });
  }

  Future<void> _write(web.IDBDatabase db, _WebSigner signer) async {
    final record = JSObject()
      ..setProperty('privateKey'.toJS, signer.privateKey)
      ..setProperty('x'.toJS, signer.publicJwk['x']!.toJS)
      ..setProperty('y'.toJS, signer.publicJwk['y']!.toJS);
    final store = db
        .transaction(_storeName.toJS, 'readwrite')
        .objectStore(_storeName);
    await _done(store.put(record, _recordId.toJS));
  }
}

class _WebSigner implements DpopSigner {
  _WebSigner(this.privateKey, this.publicJwk);

  final JSObject privateKey;

  @override
  final Map<String, String> publicJwk;

  @override
  Future<Uint8List> sign(Uint8List message) async {
    // WebCrypto's ECDSA output is already the raw r || s a JWS wants.
    final signature = await web.window.crypto.subtle
        .sign(
          {'name': 'ECDSA', 'hash': 'SHA-256'}.jsify()!,
          privateKey as web.CryptoKey,
          message.toJS,
        )
        .toDart;
    return (signature! as JSArrayBuffer).toDart.asUint8List();
  }
}
