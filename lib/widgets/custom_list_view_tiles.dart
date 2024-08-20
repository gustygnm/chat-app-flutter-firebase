//Packages
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

//Widgets
import '../widgets/rounded_image.dart';
import '../widgets/message_bubbles.dart';

//Models
import '../models/chat_message.dart';
import '../models/chat_user.dart';

class CustomListViewTile extends StatelessWidget {
  final double height;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isSelected;
  final Function onTap;
  final bool thisIsMe;

  const CustomListViewTile({
    super.key,
    required this.height,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isActive,
    required this.isSelected,
    required this.onTap,
    required this.thisIsMe,
  });

  @override
  Widget build(BuildContext context) {
    return !thisIsMe
        ? ListTile(
            trailing: isSelected
                ? const Icon(Icons.check, color: Colors.white)
                : null,
            onTap: () => onTap(),
            minVerticalPadding: height * 0.20,
            leading: RoundedImageNetworkWithStatusIndicator(
              key: UniqueKey(),
              size: height / 2,
              imagePath: imagePath,
              isActive: isActive,
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        : const SizedBox();
  }
}

class CustomListViewTileWithActivity extends StatelessWidget {
  final double height;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isActivity;
  final Function onTap;

  const CustomListViewTileWithActivity({
    super.key,
    required this.height,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isActive,
    required this.isActivity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onTap(),
      minVerticalPadding: height * 0.20,
      leading: RoundedImageNetworkWithStatusIndicator(
        key: UniqueKey(),
        size: height / 2,
        imagePath: imagePath,
        isActive: isActive,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: isActivity
          ? Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SpinKitThreeBounce(
                  color: Colors.blue,
                  size: height * 0.10,
                ),
              ],
            )
          : Text(
              subtitle,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w400),
            ),
    );
  }
}

class CustomChatListViewTile extends StatelessWidget {
  final bool isOwnMessage;
  final ChatMessage message;
  final ChatUser sender;

  const CustomChatListViewTile({
    super.key,
    required this.isOwnMessage,
    required this.message,
    required this.sender,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double messageWidth = width * 0.7; // Menyesuaikan lebar pesan

    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
            isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwnMessage)
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: width * 0.08, // Ukuran gambar pengguna
                child: RoundedImageNetwork(
                  key: UniqueKey(),
                  imagePath: sender.imageURL,
                  size: width * 0.08,
                ),
              ),
            ),
          SizedBox(
            width: width * 0.05, // Spasi antara gambar dan bubble pesan
          ),
          Expanded(
            child: Align(
              alignment:
                  isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
              child: message.type == MessageType.TEXT
                  ? ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: messageWidth,
                      ),
                      child: TextMessageBubble(
                        isOwnMessage: isOwnMessage,
                        message: message,
                      ),
                    )
                  : ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: messageWidth,
                      ),
                      child: ImageMessageBubble(
                        isOwnMessage: isOwnMessage,
                        message: message,
                        width: width * 0.55,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// class CustomChatListViewTile extends StatelessWidget {
//   final bool isOwnMessage;
//   final ChatMessage message;
//   final ChatUser sender;
//
//   const CustomChatListViewTile({
//     super.key,
//     required this.isOwnMessage,
//     required this.message,
//     required this.sender,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.sizeOf(context).width;
//
//     return Container(
//       padding: const EdgeInsets.only(top: 16),
//       width: width,
//       child: Row(
//         mainAxisSize: MainAxisSize.max,
//         mainAxisAlignment:
//         isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           if (!isOwnMessage)
//             Flexible(
//               child: RoundedImageNetwork(
//                 key: UniqueKey(),
//                 imagePath: sender.imageURL,
//                 size: width * 0.08,
//               ),
//             ),
//           SizedBox(
//             width: width * 0.05,
//           ),
//           Expanded(
//             child: message.type == MessageType.TEXT
//                 ? TextMessageBubble(
//               isOwnMessage: isOwnMessage,
//               message: message,
//               width: width,
//             )
//                 : ImageMessageBubble(
//               isOwnMessage: isOwnMessage,
//               message: message,
//               width: width * 0.55,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
