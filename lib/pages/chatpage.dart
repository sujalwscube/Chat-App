import 'package:chatting_application/services/chat/chat_service.dart';
import 'package:chatting_application/widgets/uihelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiveEmail;
  final String receiveruserId;
  const ChatPage({super.key,required this.receiveEmail,required this.receiveruserId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController=TextEditingController();
  final ChatService _chatService=ChatService();
  final firebase=FirebaseAuth.instance;

  void sendMessage()async{
    if(messageController.text.isNotEmpty){
      await _chatService.sendMessage(widget.receiveruserId, messageController.text);
      //Clear The Text After Send Message
      messageController.clear();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.receiveEmail}"),
        centerTitle: true,
      ),
      body: Column(children: [
        Expanded(child: _buildMessageList()),
        //User Input

        _buildMessageInput()
      ],),
    );
  }

  //Build Message List
  Widget _buildMessageList(){
    return StreamBuilder(stream: _chatService.getMessages(widget.receiveruserId, firebase.currentUser!.uid), builder: (context,snapshot){
      if(snapshot.hasError){
        return Center(child: Text("Oops an Error Occured ${snapshot.hasError.toString()}"),);
      }
      if(snapshot.connectionState==ConnectionState.waiting){
        return Center(child: Text("Loading..."),);
      }
      return ListView(
       children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
      );
    });
  }


  //Build Message Item
  Widget _buildMessageItem(DocumentSnapshot documentSnapshot){
    Map<String,dynamic>data=documentSnapshot.data() as Map<String,dynamic>;
    //Align the messages to right side
    var alignment=(data["senderId"]==firebase.currentUser!.uid)?Alignment.centerRight:Alignment.centerLeft ;
    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:(data["senderId"]==firebase.currentUser!.uid)?CrossAxisAlignment.end:CrossAxisAlignment.start ,
        children: [
        Text("${data["senderemail"]}"),
        Text("${data["message"]}")
      ],),
    );

  }

  //Build Message Input
  Widget _buildMessageInput(){
    return Row(children: [
      Expanded(child: UiHelper.CustomTextField(messageController,"Send Message...", false)),
      IconButton(onPressed:sendMessage, icon: Icon(Icons.send,size: 40,))
    ],);
  }
}
