import 'package:flutter/material.dart';
import 'package:flutter_application_caht/Screens/AppService.dart';
import 'package:intl/intl.dart';
class MessageBubble extends StatefulWidget {
  const MessageBubble(
      {Key? key,
      required this.textColor,
      required this.replyToUserId,
      required this.bubbleColor,
      required this.messageText,
      required this.messageSenderImage,
      required this.isMe,
      required this.messageSenderID,
      required this.dateTime,
      required this.onSwipeToReply,
      required this.isRead,
      required this.replyToUserName,
      required this.messageSenderName})
      : super(key: key);

  final String messageSenderID;

  final String messageText;
  final bool isMe;
  final String messageSenderName;
  final Color bubbleColor;
  final Color textColor;
  final DateTime dateTime;
  final String replyToUserId;
  final String replyToUserName;
  final String messageSenderImage;
  final bool isRead;

  final void Function(String senderId, String senderName, bool isReplying,
      String senderMessage, bool autoFocus) onSwipeToReply;

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool isSwiping = false;
  double offsetX = 0.0;

  @override
  Widget build(BuildContext context) {
    final timeFormatter = DateFormat('hh:mm a');
    final formattedTime = timeFormatter.format(widget.dateTime);

    // Get the current user's ID
    final currentUserId = AppService().getMyUserModel().id;

    // Determine the bubble colors
    Color bubbleStartColor =
        widget.isMe ? Colors.deepPurple.shade300 : Colors.blue.shade300;
    Color bubbleEndColor =
        widget.isMe ? Colors.deepPurple.shade600 : Colors.blue.shade600;

    // Change color if the message is a reply to the current user
    if (widget.replyToUserId == currentUserId) {
      bubbleStartColor = Colors.orange.shade300;
      bubbleEndColor = Colors.orange.shade600;
    }

    return GestureDetector(
      onHorizontalDragStart: (details) {
        setState(() {
          isSwiping = true;
        });
      },
      onHorizontalDragUpdate: (details) {
        if (details.primaryDelta! > 0) return;

        setState(() {
          offsetX += details.primaryDelta!;
        });
      },
      onHorizontalDragEnd: (details) {
        setState(() {
          isSwiping = false;
          offsetX = 0.0;
        });
        if (details.primaryVelocity! < 0) {
          // Swiped from left to right
          if (!widget.isMe) {
            widget.onSwipeToReply(widget.messageSenderID,
                widget.messageSenderName, true, widget.messageText, true);
          }
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        transform: Matrix4.translationValues(offsetX, 0.0, 0.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment:
                widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!widget.isMe) ...[
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(widget.messageSenderImage),
                ),
                SizedBox(width: 10),
                Text(
                  widget.messageSenderName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(width: 10),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width * 0.3,
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [bubbleStartColor, bubbleEndColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: widget.isMe
                          ? Radius.circular(12)
                          : Radius.circular(0),
                      bottomRight: widget.isMe
                          ? Radius.circular(0)
                          : Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: widget.isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            if (widget.replyToUserId == currentUserId) ...[
                              TextSpan(
                                text:
                                    '${widget.messageSenderName} replied to you: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      const Color.fromARGB(255, 252, 251, 251),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: widget.messageText,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: widget.textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ] else ...[
                              TextSpan(
                                text: widget.replyToUserName.isNotEmpty
                                    ? "${widget.replyToUserName.toUpperCase()} : ${widget.messageText} "
                                    : widget.messageText,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: widget.textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: Icon(
                            widget.isRead
                                ? Icons.done_all_rounded
                                : Icons.check_sharp,
                            color: widget.isRead
                                ? Colors.lightBlueAccent
                                : Colors.black,
                            size: 20,
                          )),
                    ],
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
