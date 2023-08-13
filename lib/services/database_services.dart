import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseServices {
  final String? uid;

  DatabaseServices({this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");

  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "friends": [],
      "profilePic": "",
      "uid": uid,
      "bio": "",
    });
  }

  Future createFriendsCollection(
      String userId, String friendName, String friendId) async {
    userCollection.doc(userId).collection("friends").doc(friendId).set({
      "friendName": friendName,
      "friendIcon": "",
      "friendId": friendId,
      "friendBio": "",
      "messages": [],
      "recentMessage": "",
      "recentMessageSender": "",
    });
  }

  //get user data
  // Future gettingUserData() async {
  //   return await userCollection.doc(uid).get();
  // }
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  //get user groups
  getUserCollection() async {
    return userCollection.doc(uid).snapshots();
  }

  //create a group
  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    //update the members
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"]),
    });
  }

  //add friend
  Future<void> addFriend(
      String userId, String friendName, String friendId) async {
    DocumentReference friendDocumentReference =
        await userCollection.doc(userId).collection("friends").add({
      "friendIcon": "",
      "friendName": "${friendId}_$friendName",
      "friendBio": "",
      "friendId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    await friendDocumentReference.update({
      "friendId": friendDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    await userDocumentReference.update({
      "friends":
          FieldValue.arrayUnion(["${friendDocumentReference.id}_$friendName"]),
    });
  }

  // getting the groups chats
  getGroupsChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  // getting the friends chats
  getFriendsChats(String friendId) async {
    return userCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("friends")
        .doc(friendId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference documentReference = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    return documentSnapshot['admin'];
  }

  //get group members
  getGroupMembers(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  //search on groups by name
  searchGroupsByName(String groupName) {
    return groupCollection.where('groupName', isEqualTo: groupName).get();
  }

  //search on users by name
  searchFriendsByName(String fullName) {
    return userCollection.where("fullName", isEqualTo: fullName).get();
  }

  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> isUserFriend(String friendId, String friendName) async {
    DocumentSnapshot<Object?> documentSnapshot =
        await userCollection.doc(uid).get();
    List<dynamic> friends = documentSnapshot['friends'];
    return friends.contains("${friendId}_$friendName");
  }

// toggling the group join/exit
  Future toggleGroupJoinExit(
      String groupId, String userName, String groupName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    var groups = (documentSnapshot.data() as Map<String, dynamic>)['groups'];

    // if user has our groups -> then remove then or also in other part re join
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"]),
      });
      await groupDocumentReference.collection("members").doc(uid).delete();
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

// toggling the friend or not
  Future<void> toggleFriendOrNot(String friendId, String friendName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference friendsDocumentReference = userCollection.doc(uid).collection('friends').doc(friendId);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    var friends = (documentSnapshot.data() as Map<String, dynamic>)['friends'];

    // if user has our groups -> then remove then or also in other part re join
    if (friends.contains("${friendId}_$friendName")) {
      await userDocumentReference.update({
        "friends": FieldValue.arrayRemove(["${friendId}_$friendName"])
      });
      await friendsDocumentReference.update({
        "friends": FieldValue.arrayRemove(["${friendId}_$friendName"]),
      });
    } else {
      await userDocumentReference.update({
        "friends": FieldValue.arrayUnion(["${friendId}_$friendName"])
      });
      await friendsDocumentReference.update({
        "friends": FieldValue.arrayUnion(["${friendId}_$friendName"])
      });
    }
  }

  // send message to group
  sendMessageToGroup(
      String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }

  // send message to friend
  sendMessageToFriend(String userId, String friendId,
      Map<String, dynamic> chatMessageData) async {
    userCollection
        .doc(userId)
        .collection("friends")
        .doc(friendId)
        .collection("messages")
        .add(chatMessageData);
    userCollection.doc(userId).collection("friends").doc(friendId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }

  // delete message in group
  Future deleteMessageForAllGroups(String groupId, String messageId) async {
    await groupCollection
        .doc(groupId)
        .collection("messages")
        .doc(messageId)
        .delete();
  }

  // delete message in friend chat
  Future deleteMessageForAllFriends(
      String userId, String messageId, String friendId) async {
    await userCollection
        .doc(userId)
        .collection("friends")
        .doc(friendId)
        .collection("messages")
        .doc(messageId)
        .delete();
  }

  // delete user
  Future deleteUser(String groupId) async {
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);
    await groupDocumentReference.collection("members").doc(uid).delete();
  }

// Future<void> updateGroupName(String groupId, String groupName) async {
//   DocumentReference<Object?> groupDocumentReference =
//   groupCollection.doc(groupId);
//   await groupDocumentReference.update({"groupName": groupName});
//
//   DocumentReference<Object?> userDocumentReference =
//   userCollection.doc(uid);
//   await userDocumentReference.update({
//     "groups": FieldValue.arrayRemove([groupId]),
//   });
//   await userDocumentReference.update({
//     "groups": FieldValue.arrayUnion(["${groupId}_$groupName"]),
//   });
// }
//
// Future<void> updateFriendName(String friendId, String friendName) async {
//   DocumentReference<Object?> friendDocumentReference =
//   friendCollection.doc(friendId);
//   await friendDocumentReference.update({"friendName": friendName});
//
//   DocumentReference<Object?> userDocumentReference =
//   userCollection.doc(uid);
//   await userDocumentReference.update({
//     "friends": FieldValue.arrayRemove(["${friendId}_$friendName"]),
//   });
//   await userDocumentReference.update({
//     "friends": FieldValue.arrayUnion(["${friendId}_$friendName"]),
//   });
// }
}
