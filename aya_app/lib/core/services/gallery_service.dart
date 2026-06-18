import 'package:dio/dio.dart';
import 'api_service.dart';
import 'auth_service.dart' show AuthException;

class Album {
  const Album({
    required this.id,
    required this.title,
    this.description,
    this.coverUrl,
    this.photoCount = 0,
    this.createdBy,
    required this.year,
  });

  final int id;
  final String title;
  final String? description;
  final String? coverUrl;
  final int photoCount;
  final int? createdBy;
  final int year;

  factory Album.fromJson(Map<String, dynamic> j) => Album(
        id: j['id'] as int,
        title: (j['title'] ?? '') as String,
        description: j['description'] as String?,
        coverUrl: j['cover_url'] as String?,
        photoCount: (j['photo_count'] ?? 0) as int,
        createdBy: j['created_by'] as int?,
        year: (j['year'] ?? DateTime.now().year) as int,
      );
}

class Photo {
  const Photo({
    required this.id,
    required this.imageUrl,
    this.caption,
    this.uploadedByName,
  });

  final int id;
  final String imageUrl;
  final String? caption;
  final String? uploadedByName;

  factory Photo.fromJson(Map<String, dynamic> j) => Photo(
        id: j['id'] as int,
        imageUrl: (j['image_url'] ?? '') as String,
        caption: j['caption'] as String?,
        uploadedByName: j['uploaded_by_name'] as String?,
      );
}

class AlbumDetail {
  const AlbumDetail({
    required this.album,
    required this.photos,
    required this.canManage,
    required this.isAdmin,
  });

  final Album album;
  final List<Photo> photos;
  final bool canManage;
  final bool isAdmin;
}

class GalleryService {
  GalleryService._();
  static final GalleryService instance = GalleryService._();

  Dio get _dio => ApiService.instance.dio;

  Future<List<Album>> albums() async {
    try {
      final res = await _dio.get('/gallery/albums');
      return (res.data['items'] as List)
          .map((e) => Album.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<AlbumDetail> album(int id) async {
    try {
      final res = await _dio.get('/gallery/albums/$id');
      final data = res.data as Map<String, dynamic>;
      return AlbumDetail(
        album: Album.fromJson(data['album'] as Map<String, dynamic>),
        photos: (data['photos'] as List)
            .map((e) => Photo.fromJson(e as Map<String, dynamic>))
            .toList(),
        canManage: (data['can_manage'] ?? false) as bool,
        isAdmin: (data['is_admin'] ?? false) as bool,
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<Album> createAlbum(
      {required String title, String? description, required int year}) async {
    try {
      final res = await _dio.post('/gallery/albums', data: {
        'title': title,
        'year': year,
        if (description != null && description.isNotEmpty) 'description': description,
      });
      return Album.fromJson(res.data['album'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<void> deleteAlbum(int id) async {
    try {
      await _dio.delete('/gallery/albums/$id');
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<Photo> uploadPhoto(int albumId, String filePath, {String? caption}) async {
    try {
      final form = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
        if (caption != null && caption.isNotEmpty) 'caption': caption,
      });
      final res = await _dio.post('/gallery/albums/$albumId/photos', data: form);
      return Photo.fromJson(res.data['photo'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<void> deletePhoto(int photoId) async {
    try {
      await _dio.delete('/gallery/photos/$photoId');
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  AuthException _map(DioException e) {
    final data = e.response?.data;
    if (e.response == null) {
      return const AuthException('NETWORK', 'Connection failed. Please try again.');
    }
    if (data is Map && data['code'] != null) {
      return AuthException(
          data['code'] as String, (data['message'] ?? 'Something went wrong.') as String);
    }
    return const AuthException('UNKNOWN', 'Something went wrong.');
  }
}
