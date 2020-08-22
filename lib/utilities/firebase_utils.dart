import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_statuses/model/post_model.dart';
import 'package:my_statuses/utilities/constants.dart';
import 'package:my_statuses/utilities/utilities.dart';

class FirebaseUtils {
  static final StorageReference notificationsStorageReference =
      FirebaseStorage.instance.ref().child(Constants.statues);

  static CollectionReference statuesCollectionsReference =
      Firestore.instance.collection(Constants.statues);

  static Future<String> uploadImageToStorage(File file) async {
    print("uploadImageToStorage");
    final StorageUploadTask storageUploadTask = notificationsStorageReference
        .child(Utilities.getFileName(file))
        .putFile(file);
    final StorageTaskSnapshot storageTaskSnapshot =
        (await storageUploadTask.onComplete);
    final url = (await storageTaskSnapshot.ref.getDownloadURL());
    print("url : $url");
    return url;
  }

  static Future postNotification(PostModel model, String filePath) async {
    if (filePath != null) {
      // here deleteing old image from storage
      if (model.imageURL != null && model.imageURL.contains("https://")) {
        await FirebaseStorage.instance
            .getReferenceFromUrl(model.imageURL)
            .then((onValue) {
          onValue.delete();
        });
      }

      model.imageURL = await uploadImageToStorage(File(filePath));
      print("addProdcut url ${model.imageURL}");
    }

    DocumentReference ref = statuesCollectionsReference.document();

    if (model.docid != null) {
      ref = statuesCollectionsReference.document(model.docid);
    }
    model.docid = ref.documentID;
    model.imageURL = model.imageURL;
    print(model.toMap().toString());
    return await ref.setData(model.toMap());
  }
}