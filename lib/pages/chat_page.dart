import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//Widgets
import '../utils/colors.dart';
import '../widgets/containers.dart';
import '../widgets/custom_list_view_tiles.dart';
import '../widgets/custom_input_fields.dart';

//Models
import '../models/chat.dart';
import '../models/chat_message.dart';

//Providers
import '../providers/authentication_provider.dart';
import '../providers/chat_page_provider.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;

  const ChatPage({super.key, required this.chat});

  @override
  State<StatefulWidget> createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late ChatPageProvider _pageProvider;

  late GlobalKey<FormState> _messageFormState;
  late ScrollController _messagesListViewController;

  @override
  void initState() {
    super.initState();
    _messageFormState = GlobalKey<FormState>();
    _messagesListViewController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatPageProvider>(
          create: (_) => ChatPageProvider(
              widget.chat.uid, _auth, _messagesListViewController, context),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (BuildContext context) {
        _pageProvider = context.watch<ChatPageProvider>();
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                ),
                onPressed: () {
                  _showDeleteConfirmationDialog(context);
                },
              )
            ],
            title: Center(
              child: Text(
                widget.chat.title(),
                style: const TextStyle(
                  color: colorNeutral90,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onPressed: () {
                _pageProvider.goBack();
              },
            ),
          ),
          body: Column(
            children: [
              Expanded(child: _messagesListView()),
              _sendMessageForm(),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hapus"),
          content: Text(
              "Anda akan menghapus semua chat dari ${widget.chat.title()}?"),
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
                _pageProvider.deleteChat();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _messagesListView() {
    if (_pageProvider.messages != null) {
      if (_pageProvider.messages?.isNotEmpty == true) {
        return ListView.builder(
          controller: _messagesListViewController,
          itemCount: _pageProvider.messages!.length,
          itemBuilder: (BuildContext context, int index) {
            ChatMessage message = _pageProvider.messages![index];
            bool isOwnMessage = message.senderID == _auth.user.uid;

            var matchingMembers =
            widget.chat.members.where((m) => m.uid == message.senderID);
            var sender =
            matchingMembers.isNotEmpty ? matchingMembers.first : null;

            return CustomChatListViewTile(
              message: message,
              isOwnMessage: isOwnMessage,
              sender: sender!,
            ).horizontalpadded16();
          },
        ).topPadded16();
      } else {
        return const Center(
          child: Align(
            alignment: Alignment.center,
            child: Text(
              "Be the first to say Hi!",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Widget _sendMessageForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Form(
        key: _messageFormState,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _imageMessageButton(),
            _messageTextField(),
            _sendMessageButton(),
          ],
        ),
      ),
    ).padded16();
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth * 0.65,
      child: CustomTextFormField(
          onSaved: (value) {
            _pageProvider.message = value;
          },
          regEx: r"^(?!\s*$).+",
          hintText: "Type a message",
          obscureText: false),
    );
  }

  Widget _sendMessageButton() {
    double size = _deviceHeight * 0.04;
    return SizedBox(
      height: size,
      width: size,
      child: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.send,
          color: Colors.white,
        ),
        onPressed: () {
          if (_messageFormState.currentState!.validate()) {
            _messageFormState.currentState!.save();
            _pageProvider.sendTextMessage();
            _messageFormState.currentState!.reset();
          }
        },
      ),
    );
  }

  Widget _imageMessageButton() {
    double size = _deviceHeight * 0.04;
    return SizedBox(
      height: size,
      width: size,
      child: FloatingActionButton(
        backgroundColor: colorGreyCircleAppBar,
        onPressed: () {
          _pageProvider.sendImageMessage();
        },
        child: const Icon(
          Icons.camera_enhance,
          color: Colors.black54,
        ),
      ),
    );
  }
}
