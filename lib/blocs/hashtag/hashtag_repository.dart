import 'package:yvrkayakers/blocs/hashtag/index.dart';

class HashtagRepository {
  final HashtagProvider _hashtagProvider = HashtagProvider();

  HashtagRepository();

  void test(bool isError) {
    _hashtagProvider.test(isError);
  }

  Future<String> updateHashtagVideos(
      String hashtag, List<ExtObjectLink> videoList) async {
    return _hashtagProvider.updateHashtagVideos(hashtag, videoList);
  }

  Future<HashtagModel> getHashtag(String hashtag) async {
    return _hashtagProvider.getHashtag(hashtag);
  }
}
