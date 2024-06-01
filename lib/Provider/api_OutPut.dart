import 'package:flutter/material.dart';
import 'MessageModel.dart';
import '../data/api_helper.dart';

class ChatProvider extends ChangeNotifier {
  List<MessageModel> listMsgs = [];

  sendMsg({required String prompt}) async {
    listMsgs.insert(0, MessageModel(msg: prompt, senderId: 0));
    notifyListeners();

    // Ai reply
    try {
      var result = await ApiHelper().generateAiMsg(prompt: prompt);
      listMsgs.insert(0, MessageModel(msg: result.toString(), senderId: 1));
      notifyListeners();
    } catch (e) {
      listMsgs.insert(0, MessageModel(msg: e.toString(), senderId: 1));
      notifyListeners();
    }
  }

  List<MessageModel> allMsgs() {
    return listMsgs;
  }
}
