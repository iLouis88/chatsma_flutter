import 'package:chatsma_flutter/common/enums/message_enum.dart';
import 'package:flutter/material.dart';
import 'package:chatsma_flutter/common/utils/colors.dart';
import 'package:swipe_to/swipe_to.dart';

class SenderMessageCard extends StatelessWidget {
  const SenderMessageCard({
    Key? key,
    required this.message,
    required this.date,
    required this.onRightSwipe,
    required this.repliedText,
    required this.username,
    required this.repliedMessageType,
  }) : super(key: key);

  
  final String message;
  final String date;
  final VoidCallback onRightSwipe;
  final String repliedText;
  final String username;
  final MessageEnum repliedMessageType;

  @override
  Widget build(BuildContext context) {
    return SwipeTo(
      onRightSwipe: onRightSwipe,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Row(
            children: [
              Flexible(
                // ham tu dong xuong dong khi nhiều dữ liệu
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  color: senderMessageColor,
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          // left: 10,
                          // right: 30,
                          // top: 5,
                          // bottom: 20,
                          left: 10,
                          right: 10,
                          top: 10,
                          bottom: 10,
                        ),
                        child: Wrap(
                          children: [
                            Text(
                              message,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Positioned(
                      //   bottom: 2,
                      //   right: 10,
                      //   child: Text(
                      //     date,
                      //     style: TextStyle(
                      //       fontSize: 10,
                      //       color: Colors.grey[600],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 2,
                  right: 10,
                ),
                child: Text(
                  date,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
