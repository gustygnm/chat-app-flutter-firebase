//Packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

//Providers
import '../providers/authentication_provider.dart';
import '../providers/chats_page_provider.dart';

//Services
import '../services/navigation_service.dart';

//Pages
import '../pages/chat_page.dart';

//Widgets
import '../widgets/containers.dart';
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';

//Models
import '../models/chat.dart';
import '../models/chat_user.dart';
import '../models/chat_message.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ChatsPageState();
  }
}

class _ChatsPageState extends State<ChatsPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late NavigationService _navigation;
  late ChatsPageProvider _pageProvider;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatsPageProvider>(
          create: (_) => ChatsPageProvider(_auth),
        ),
      ],
      child: SafeArea(child: _buildUI()),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Keluar"),
          content: const Text(
              "Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              child: const Text("Tidak"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Ya"),
              onPressed: () {
                Navigator.of(context).pop();
                _auth.logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (BuildContext context) {
        _pageProvider = context.watch<ChatsPageProvider>();
        return SizedBox(
          height: _deviceHeight,
          width: _deviceWidth,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TopBar(
                'Chats',
                primaryAction: IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    _showLogoutConfirmationDialog(context);
                  },
                ),
              ).horizontalpadded16().topPadded(8),
              _chatsList(),
            ],
          ),
        );
      },
    );
  }

  Widget _chatsList() {
    List<Chat>? chats = _pageProvider.chats;
    return Expanded(
      child: (() {
        if (chats != null) {
          if (chats.isNotEmpty) {
            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (BuildContext context, int index) {
                return _chatTile(
                  chats[index],
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                "No Chats Found.",
                style: TextStyle(color: Colors.grey),
              ),
            ).padded16();
          }
        } else {
          return centerPageLoading(color: Colors.transparent);
        }
      })(),
    );
  }

  Widget _chatTile(Chat chat) {
    List<ChatUser> recepients = chat.recepients();
    bool isActive = recepients.any((d) => d.wasRecentlyActive());
    String subtitleText = "";

    if (chat.messages.isNotEmpty) {
      subtitleText = chat.messages.first.type != MessageType.TEXT
          ? "Media Attachment"
          : chat.messages.first.content;
    } else {
      subtitleText = "No messages";
    }

    return CustomListViewTileWithActivity(
      height: _deviceHeight * 0.10,
      title: chat.title(),
      subtitle: subtitleText,
      imagePath: chat.imageURL(),
      isActive: isActive,
      isActivity: chat.activity,
      onTap: () {
        _navigation.navigateToPage(
          ChatPage(chat: chat),
        );
      },
    );
  }
}
