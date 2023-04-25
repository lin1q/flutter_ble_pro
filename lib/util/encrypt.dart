import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

Uint8List aesDec128Encrypt(Uint8List buf) {
  final key = Key.fromUtf8('5hvbam6kfbyctw5h');
  final iv = IV.fromLength(16);

  final encrypter = Encrypter(AES(key, mode: AESMode.ecb));

  final encrypted = encrypter.encryptBytes(buf, iv: iv);
  return encrypted.bytes;
}

Uint8List aesDec128Decrypt(List<int> buf) {
  final key = Key.fromUtf8('5hvbam6kfbyctw5h');
  final iv = IV.fromLength(16);

  final decrypter = Encrypter(AES(key, mode: AESMode.ecb));
  Encrypted encBuf = Encrypted(Uint8List.fromList(buf));

  final encrypted = decrypter.decryptBytes(encBuf, iv: iv);
  return Uint8List.fromList(encrypted);
}
