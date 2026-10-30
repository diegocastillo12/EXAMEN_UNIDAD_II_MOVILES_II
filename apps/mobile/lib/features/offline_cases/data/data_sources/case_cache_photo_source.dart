import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CaseCachePhotoSource {
  const CaseCachePhotoSource();
  Future<Uri?> download(Uri? uri) async {
    if (uri == null || uri.scheme != 'https') return null;
    final client = http.Client();
    try {
      return await (() async {
        final response = await client.send(
          http.Request('GET', uri)..followRedirects = false,
        );
        if (response.statusCode != 200 ||
            (response.contentLength ?? 0) > 2 * 1024 * 1024) {
          return null;
        }
        final mime = response.headers['content-type']?.split(';').first;
        if (!{'image/jpeg', 'image/png', 'image/webp'}.contains(mime)) {
          return null;
        }
        final bytes = BytesBuilder(copy: false);
        await for (final chunk in response.stream) {
          if (bytes.length + chunk.length > 2 * 1024 * 1024) return null;
          bytes.add(chunk);
        }
        return bytes.length == 0
            ? null
            : Uri.dataFromBytes(bytes.takeBytes(), mimeType: mime!);
      })().timeout(const Duration(seconds: 3));
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }
}
