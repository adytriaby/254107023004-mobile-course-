import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/network_errors.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/post_repository.dart';
import 'package:week4_api/main.dart';
import 'package:week4_api/router.dart';

class FakePostRepository extends PostRepository {
  FakePostRepository({this.items, this.throwError = false}) : super(Dio());

  final List<Post>? items;
  final bool throwError;

  @override
  Future<List<Post>> fetchPosts() async {
    if (throwError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
    }
    return items ?? const [];
  }

  @override
  Future<List<Post>> fetchPostsPage(
      {required int page, int limit = 10}) async {
    return fetchPosts();
  }

  @override
  Future<Post> fetchPost(int id) async {
    if (throwError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/posts/$id'),
        type: DioExceptionType.connectionError,
      );
    }
    final list = items ?? const [];
    return list.firstWhere(
      (p) => p.id == id,
      orElse: () => list.isEmpty
          ? const Post(userId: 1, id: 1, title: '', body: '')
          : list.first,
    );
  }

  @override
  Future<List<Comment>> fetchComments(int postId) async => const [];
}

const _sample = [
  Post(userId: 1, id: 1, title: 'Judul Pertama', body: 'Isi pertama'),
  Post(userId: 1, id: 2, title: 'Judul Kedua', body: 'Isi kedua'),
];

void main() {
  setUp(() => router.go('/'));

  group('model', () {
    test('Post.fromJson aman terhadap field yang hilang', () {
      final post = Post.fromJson({'id': 7});
      expect(post.id, 7);
      expect(post.title, '');
      expect(post.userId, 0);
    });

    test('Post.fromJson menangani tipe angka campuran', () {
      final post = Post.fromJson({'userId': 2, 'id': '3', 'title': null});
      expect(post.id, 3);
      expect(post.title, '');
    });

    test('Comment.fromJson aman null', () {
      final c = Comment.fromJson({'postId': 5});
      expect(c.postId, 5);
      expect(c.name, '');
      expect(c.email, '');
    });
  });

  group('friendlyErrorMessage', () {
    test('connection error', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
      expect(friendlyErrorMessage(err), contains('terhubung'));
    });

    test('timeout', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.receiveTimeout,
      );
      expect(friendlyErrorMessage(err), contains('timeout'));
    });

    test('bad response 404', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/posts/1'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/posts/1'),
          statusCode: 404,
        ),
      );
      expect(friendlyErrorMessage(err), contains('404'));
    });
  });

  group('provider', () {
    test('sukses dengan repository palsu', () async {
      final container = ProviderContainer(
        overrides: [
          postRepositoryProvider.overrideWithValue(
            FakePostRepository(items: _sample),
          ),
        ],
      );
      addTearDown(container.dispose);
      final posts = await readPostsOnce(container);
      expect(posts.length, 2);
      expect(posts.first.title, 'Judul Pertama');
    });

    test('error dengan repository palsu', () async {
      final container = ProviderContainer(
        overrides: [
          postRepositoryProvider
              .overrideWithValue(FakePostRepository(throwError: true)),
        ],
      );
      addTearDown(container.dispose);
      final err = await readPostsErrorOnce(container);
      expect(err, isA<DioException>());
      expect(friendlyErrorMessage(err!), contains('terhubung'));
    });
  });

  group('widget', () {
    testWidgets('menampilkan daftar post dan navigasi ke detail',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            postRepositoryProvider.overrideWithValue(
              FakePostRepository(items: _sample),
            ),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Judul Pertama'), findsOneWidget);
      expect(find.text('Judul Kedua'), findsOneWidget);

      await tester.tap(find.text('Judul Pertama'));
      await tester.pumpAndSettle();

      expect(find.text('Post #1'), findsOneWidget);
      expect(find.text('Komentar'), findsOneWidget);
    });

    testWidgets('menampilkan pesan error saat gagal memuat',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            postRepositoryProvider
                .overrideWithValue(FakePostRepository(throwError: true)),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('terhubung'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);
    });
  });
}
