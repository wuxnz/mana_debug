/*
 * Encode/Decode functions for Dart
 *
 * Copyright 2011 Google Inc.
 * Neil Fraser (fraser@google.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

String encodeURI(text) {
  StringBuffer encodedText = StringBuffer();
  const String whiteList =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.!~*\'()#;,/?:@&=+\$';
  const String hexDigits = '0123456789ABCDEF';
  for (int i = 0; i < text.length; i++) {
    if (whiteList.contains(text[i])) {
      encodedText.write(text[i]);
      continue;
    }
    int charCode = text[i].codeUnitAt(0);
    List<int> byteList = [];
    if (charCode < 0x80) {
      byteList.add(charCode);
    } else if (charCode < 0x800) {
      byteList.add(charCode >> 6 | 0xC0);
      byteList.add(charCode & 0x3F | 0x80);
    } else if (0xD800 <= charCode && charCode < 0xDC00) {
      int nextCharCode = text.length == i + 1 ? 0 : text[i + 1].codeUnitAt(0);
      if (0xDC00 <= nextCharCode && nextCharCode < 0xE000) {
        charCode += 0x40;
        byteList.add(charCode >> 8 & 0x7 | 0xF0);
        byteList.add(charCode >> 2 & 0x3F | 0x80);
        byteList
            .add(((charCode & 0x3) << 4) | (nextCharCode >> 6 & 0xF) | 0x80);
        byteList.add(nextCharCode & 0x3F | 0x80);
      } else {
        throw Exception('URI malformed: Missing high surrogate.');
      }

      i++;
    } else if (0xDC00 <= charCode && charCode < 0xE000) {
      throw Exception('URI malformed: Orphaned high surrogate.');
    } else if (charCode < 0x10000) {
      byteList.add(charCode >> 12 | 0xE0);
      byteList.add(charCode >> 6 & 0x3F | 0x80);
      byteList.add(charCode & 0x3F | 0x80);
    }
    for (int i = 0; i < byteList.length; i++) {
      encodedText
        ..write('%')
        ..write(hexDigits[byteList[i] >> 4])
        ..write(hexDigits[byteList[i] & 0xF]);
    }
  }
  return encodedText.toString();
}

String encodeURIComponent(text) {
  text = encodeURI(text);
  return text
      .replaceAll('#', '%23')
      .replaceAll(';', '%3B')
      .replaceAll(',', '%2C')
      .replaceAll('/', '%2F')
      .replaceAll('?', '%3F')
      .replaceAll(':', '%3A')
      .replaceAll('@', '%40')
      .replaceAll('&', '%26')
      .replaceAll('=', '%3D')
      .replaceAll('+', '%2B')
      .replaceAll('\$', '%24');
}

String decodeURI(text) {
  const String hexDigits = '0123456789ABCDEF';

  List<String> parts = text.split('%');
  int state = 0;
  int? multiByte;
  bool surrogate = false;

  for (int i = 1; i < parts.length; i++) {
    String part = parts[i];
    if (part.length < 2) {
      throw Exception('URI malformed: Missing digits.');
    }
    int hex1 = hexDigits.indexOf(part[0].toUpperCase());
    int hex2 = hexDigits.indexOf(part[1].toUpperCase());
    parts[i] = part.substring(2);
    if (hex1 == -1 || hex2 == -1) {
      throw Exception('URI malformed: Invalid digits.');
    }
    int charCode = hex1 * 16 + hex2;
    if (state == 0) {
      if (charCode < 0x80) {
        multiByte = charCode;
        state = 0;
      } else if ((charCode & 0xE0) == 0xC0) {
        multiByte = charCode & 0x1F;
        state = 1;
      } else if ((charCode & 0xF0) == 0xE0) {
        multiByte = charCode & 0xF;
        state = 2;
      } else if ((charCode & 0xF8) == 0xF0) {
        multiByte = charCode & 0x7;
        state = 3;
        surrogate = true;
      } else {
        throw Exception('URI malformed: Unknown Unicode.');
      }
    } else {
      if ((charCode & 0xC0) != 0x80) {
        throw Exception('URI malformed: Expect 10xxxxxx.');
      }
      multiByte = (multiByte! << 6) | (charCode & 0x3F);
      state--;
    }
    if (state == 0) {
      if (surrogate) {
        surrogate = false;

        int x = (multiByte >> 10) - 0x40 + 0xD800;
        int y = (multiByte & 0x3FF) + 0xDC00;
        if (x >= 0xDC00 || y >= 0xE000) {
          throw Exception('URI malformed: Invalid surrogate.');
        }
        parts.insert(i, String.fromCharCodes([x, y]));
      } else {
        parts.insert(i, String.fromCharCodes([multiByte]));
      }

      i++;
    } else {
      if (parts[i].isNotEmpty) {
        throw Exception('URI malformed: Incomplete code.');
      }
    }
  }
  if (state != 0) {
    throw Exception('URI malformed: Truncated code.');
  }
  return parts.join('');
}

String decodeURIComponent(text) {
  return decodeURI(text);
}
