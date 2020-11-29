import 'dart:async';
import 'package:yvrkayakers/blocs/hashtag/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HashtagProvider {
  Future<void> loadAsync(String token) async {
    /// write from keystore/keychain
    await Future.delayed(Duration(seconds: 2));
  }

  Future<void> saveAsync(String token) async {
    /// write from keystore/keychain
    await Future.delayed(Duration(seconds: 2));
  }

  void test(bool isError) {
    if (isError == true) {
      throw Exception('manual error');
    }
  }

  Future<String> updateHashtagVideos(
      String hashtag, List<ExtObjectLink> videoList) async {
    var foundHashtagObj =
        FirebaseFirestore.instance.collection('/hashtags').doc(hashtag);
    foundHashtagObj
        .update({'relatedVideos': videoList.map((e) => e.toJson()).toList()});
    //also update last fetch date
    foundHashtagObj.update({'lastFetchVideos': DateTime.now()});
  }

  Future<HashtagModel> getHashtag(String hashtag) async {
    var foundHashtagRef =
        FirebaseFirestore.instance.collection('/hashtags').doc(hashtag);
    var foundHashtagObj = await foundHashtagRef.get();
    if (!foundHashtagObj.exists) {
      await foundHashtagRef.set((HashtagModel(hashtag, List<ExtObjectLink>(),
              DateTime.now().add(Duration(days: -365))))
          .toJson());
      foundHashtagObj = await foundHashtagRef.get();
    }
    return HashtagModel.fromFire(foundHashtagObj);
  }
}
