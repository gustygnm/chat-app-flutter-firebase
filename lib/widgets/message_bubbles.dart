import 'package:chat_app_flutter_firebase/widgets/containers.dart';
import 'package:flutter/material.dart';

//Packages
import 'package:timeago/timeago.dart' as timeago;

//Models
import '../models/chat_message.dart';
import '../utils/colors.dart';

class TextMessageBubble extends StatelessWidget {
  final bool isOwnMessage;
  final ChatMessage message;

  const TextMessageBubble(
      {super.key,
      required this.isOwnMessage,
      required this.message,});

  @override
  Widget build(BuildContext context) {
    List<Color> colorScheme = isOwnMessage
        ? [colorMenuDaftarIndividu, colorMenuDaftarIndividu]
        : [
            colorTextInfoMessage,
            colorTextInfoMessage,
          ];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: colorScheme,
          stops: const [0.30, 0.70],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ).bottomPadded4(),
          Text(
            timeago.format(message.sentTime),
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ).padded8(),
    );
  }
}

class ImageMessageBubble extends StatelessWidget {
  final bool isOwnMessage;
  final ChatMessage message;
  final double width;

  const ImageMessageBubble(
      {super.key,
      required this.isOwnMessage,
      required this.message,
      required this.width});

  @override
  Widget build(BuildContext context) {
    List<Color> colorScheme = isOwnMessage
        ? [colorMenuDaftarIndividu, colorMenuDaftarIndividu]
        : [
            colorTextInfoMessage,
            colorTextInfoMessage,
          ];
    DecorationImage image = DecorationImage(
      image: NetworkImage(message.content),
      fit: BoxFit.cover,
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: colorScheme,
          stops: const [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              image: image,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            timeago.format(message.sentTime),
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ).padded8(),
    );
  }
}
