import 'dart:async';

//Packages
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

//Services
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/media_service.dart';
import '../services/navigation_service.dart';

//Providers
import '../providers/authentication_provider.dart';

//Models
import '../models/chat_message.dart';

class ChatPageProvider extends ChangeNotifier {
  late DatabaseService _db;
  late CloudStorageService _storage;
  late MediaService _media;
  late NavigationService _navigation;

  final AuthenticationProvider _auth;
  final ScrollController _messagesListViewController;
  final BuildContext context;

  final String _chatId;
  List<ChatMessage>? messages;

  late StreamSubscription _messagesStream;

  String? _message;

  String get message {
    return message;
  }

  set message(String value) {
    _message = value;
  }

  ChatPageProvider(this._chatId, this._auth, this._messagesListViewController, this.context) {
    _db = GetIt.instance.get<DatabaseService>();
    _storage = GetIt.instance.get<CloudStorageService>();
    _media = GetIt.instance.get<MediaService>();
    _navigation = GetIt.instance.get<NavigationService>();
    listenToMessages();
    listenToKeyboardChanges();
  }

  @override
  void dispose() {
    _messagesStream.cancel();
    super.dispose();
  }

  void listenToMessages() {
    try {
      _messagesStream = _db.streamMessagesForChat(_chatId).listen(
            (snapshot) {
          List<ChatMessage> messages = snapshot.docs.map(
                (m) {
              Map<String, dynamic> messageData =
              m.data() as Map<String, dynamic>;
              return ChatMessage.fromJSON(messageData);
            },
          ).toList();
          print("Messages received: ${messages.length}"); // Tambahkan ini
          this.messages = messages;
          notifyListeners();
        },
      );
    } catch (e) {
      if (context.mounted) {
        _showSnackbar(context, "Error getting messages");
      }
    }
  }

  void listenToKeyboardChanges() {
    // Implementasi mendengarkan perubahan keyboard jika diperlukan
  }

  void sendTextMessage() {
    if (_message != null) {
      ChatMessage messageToSend = ChatMessage(
        content: _message!,
        type: MessageType.TEXT,
        senderID: _auth.user.uid,
        sentTime: DateTime.now(),
      );
      _db.addMessageToChat(_chatId, messageToSend);
    }
  }

  void sendImageMessage() async {
    try {
      PlatformFile? file = await _media.pickImageFromLibrary();
      if (file != null) {
        String? downloadURL = await _storage.saveChatImageToStorage(
            _chatId, _auth.user.uid, file);
        ChatMessage messageToSend = ChatMessage(
          content: downloadURL!,
          type: MessageType.IMAGE,
          senderID: _auth.user.uid,
          sentTime: DateTime.now(),
        );
        _db.addMessageToChat(_chatId, messageToSend);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackbar(context, "Error sending image message.");
      }
    }
  }

  void deleteChat() {
    goBack();
    try {
      _db.deleteChat(_chatId);
    } catch (e) {
      if (context.mounted) {
        _showSnackbar(context, "Error deleting chat.");
      }
    }
  }

  void goBack() {
    _navigation.goBack();
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
