import 'post.dart';

class PostService {
  final List<Post> _posts = [];

  List<Post> getAllPosts() {
    return List.unmodifiable(_posts);
  }

  void addPost(Post post) {
    _posts.add(post);
  }
}
