import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapplication/core/api/api_client.dart';
import 'package:myapplication/core/api/api_endpoints.dart';
import 'package:myapplication/core/providers/auth_provider.dart';
import 'package:myapplication/core/storage/secure_storage.dart';

class _AvatarApiClient extends ApiClient {
  _AvatarApiClient() : super(tokenStorage: const SecureTokenStorage());

  String? uploadedPath;
  int uploadCount = 0;

  @override
  Future<Response<dynamic>> postMultipart(String path, FormData data) async {
    uploadedPath = path;
    uploadCount++;
    return Response<dynamic>(
      data: {
        'id': 'user-1',
        'email': 'ahmed@gmail.com',
        'display_name': 'ahmed',
        'avatar_url': '/uploads/avatars/user-1/face.png',
        'units': 'metric',
        'locale': 'en',
        'timezone': 'Asia/Baghdad',
        'preferences': <String, dynamic>{},
      },
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
    );
  }
}

void main() {
  test(
    'uploadAvatarBytes posts multipart image and refreshes current user',
    () async {
      final api = _AvatarApiClient();
      final provider = AuthProvider(
        api: api,
        storage: const SecureTokenStorage(),
      );

      await provider.uploadAvatarBytes(
        bytes: [1, 2, 3],
        filename: 'face.png',
        contentType: 'image/png',
      );

      expect(api.uploadedPath, ApiEndpoints.meAvatar);
      expect(api.uploadCount, 1);
      expect(provider.user?.avatarUrl, '/uploads/avatars/user-1/face.png');
    },
  );
}
