import 'package:demo_chat_application/src/foundation/msg_widget/other_msg_widget.dart';
import 'package:demo_chat_application/src/foundation/msg_widget/own_msg_widget.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'msg_model.dart';

class GroupPage extends StatefulWidget {
  final String name;
  final String userId;
  const GroupPage({Key? key, required this.name, required this.userId})
      : super(key: key);

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  IO.Socket? socket;
  List<MsgModel> listMsg = [];
  final TextEditingController _msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    connect();
  }

  void connect() {
    socket = IO.io("http://localhost:3000", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket!.connect();
    socket!.onConnect((_) {
      print('connected into frontend');
      socket!.on("sendMsgServer", (msg) {
        print(msg);
        if (msg["userId"] != widget.userId) {
          setState(() {
            listMsg.add(
              MsgModel(
                  msg: msg["msg"],
                  type: msg["type"],
                  sender: msg["senderName"]),
            );
          });
        }
      });
    });
  }

  void sendMsg(String msg, String senderName) {
    MsgModel ownMsg = MsgModel(msg: msg, type: "ownMsg", sender: senderName);
    listMsg.add(ownMsg);
    setState(() {
      listMsg;
    });
    socket!.emit('sendMsg', {
      "type": "ownMsg",
      "msg": msg,
      "senderName": senderName,
      "userId": widget.userId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Users"),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: listMsg.length,
                  itemBuilder: (context, index) {
                    if (listMsg[index].type == "ownMsg") {
                      return OwnMSgWidget(
                          sender: listMsg[index].sender,
                          msg: listMsg[index].msg);
                    } else {
                      return OtherMSgWidget(
                          sender: listMsg[index].sender,
                          msg: listMsg[index].msg);
                    }
                  })),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Row(
              children: [
                Expanded(
                    child: TextFormField(
                  controller: _msgController,
                  decoration: InputDecoration(
                      hintText: "Type here ...",
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          String msg = _msgController.text;
                          if (msg.isNotEmpty) {
                            sendMsg(_msgController.text, widget.name);
                            _msgController.clear();
                          }
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.black,
                          size: 26,
                        ),
                      )),
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
