import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SpeechBubble extends StatelessWidget {
  final Function onTouched;
  SpeechBubble(
      {this.avatarUrl,
      this.message,
      this.time,
      this.delivered,
      this.isMe,
      this.userDisplayName,
      this.onTouched});

  final String message, time, avatarUrl, userDisplayName;
  final delivered, isMe;

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? Colors.white : Colors.greenAccent.shade100;
    final align = isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final icon = delivered ? Icons.done_all : Icons.done;
    final radius = isMe
        ? BorderRadius.only(
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(5.0),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(10.0),
          );
    return Row(children: [
      GestureDetector(
        onTap: () {
          // go to user riverlog page
          if (null != this.onTouched) {
            // Raise the event
            this.onTouched();
          }
        },
        child: CircleAvatar(
          radius: 20.0,
          backgroundColor: Colors.grey[200],
          backgroundImage: CachedNetworkImageProvider(avatarUrl),
        ),
      ),
      Flexible(
          child: Column(
        crossAxisAlignment: align,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(3.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    blurRadius: .5,
                    spreadRadius: 1.0,
                    color: Colors.black.withOpacity(.12))
              ],
              color: bg,
              borderRadius: radius,
            ),
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 48.0),
                  child: Text(message,
                      style: Theme.of(context).textTheme.bodyText2),
                ),
                Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 3.0),
                      Icon(
                        icon,
                        size: 12.0,
                        color: Colors.black38,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Row(
            crossAxisAlignment: align,
            children: [
              Text(userDisplayName,
                  style: TextStyle(
                    fontSize: 10.0,
                  )),
              Text(time,
                  style: TextStyle(
                    fontSize: 10.0,
                  ))
            ],
          )
        ],
      ))
    ]);
  }
}
