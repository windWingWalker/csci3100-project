import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csci3100/models/user.dart';
import 'package:csci3100/services/likedb.dart';
import 'package:csci3100/services/userdb.dart';
import 'package:csci3100/shared/constants.dart';
import 'package:csci3100/shared/inputs.dart';
import 'package:csci3100/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {

  bool noMoreUser = false;
  @override
  Widget build(BuildContext context) {
    CardController controller; //Use this to trigger swap.
    final user = Provider.of<User>(context);
    if (user != null){
      final UserDB userdb = UserDB(uid: user.uid, currentUser: user);
      final LikeDB likedb = LikeDB(uid: user.uid);
      return StreamBuilder<List<User>>(
          stream: userdb.filteredUsers,
          builder: (context, snapshot) {
            if (snapshot.hasData){
              List<User> users = snapshot.data;
              return StreamBuilder<QuerySnapshot>(
                    stream: likedb.likes,
                    builder: (context, snapshot) {
                      if (snapshot.hasData){
                        List<DocumentSnapshot> likes = snapshot.data.documents;
                        for(var i = 0; i < users.length; i++){
                          for (var j = 0; j <likes.length; j++){
                            if(users[i].uid == likes[j]['to']){
                              users.removeAt(i);
                            }
                          }
                        }
                        return StreamBuilder<QuerySnapshot>(
                            stream: likedb.dislikes,
                            builder: (context, snapshot) {
                              if (snapshot.hasData){
                                List<DocumentSnapshot> dislikes = snapshot.data.documents;
                                for(var i = 0; i < users.length; i++){
                                  for (var j = 0; j <dislikes.length; j++){
                                    if(users[i].uid == dislikes[j]['to']){
                                      users.removeAt(i);
                                    }
                                  }
                                }
                                if (users.length != 0 && user.isActivate && !noMoreUser){
                                  return Scaffold(
                                    appBar: AppBar(
                                      title: Text("CUagain"),
                                      flexibleSpace: Container(
                                        decoration: appBarDecoration,
                                      ),
                                    ),
                                    body: Container(
                                      decoration: bodyDecoration,
                                      child: Center(
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                  height: MediaQuery.of(context).size.height * 0.6,
                                                  child: new TinderSwapCard(
                                                      orientation: AmassOrientation.BOTTOM,
                                                      totalNum: users.length,
                                                      stackNum: 3,
                                                      swipeEdge: 4.0,
                                                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                                                      maxHeight: MediaQuery.of(context).size.width * 0.9,
                                                      minWidth: MediaQuery.of(context).size.width * 0.8,
                                                      minHeight: MediaQuery.of(context).size.width * 0.8,
                                                      cardBuilder: (context, index) => Card(
                                                        child: Image.network('${users[index].url}'),
                                                      ),
                                                      cardController: controller = CardController(),
                                                      swipeUpdateCallback:
                                                          (DragUpdateDetails details, Alignment align) {
                                                        /// Get swiping card's alignment
                                                        if (align.x < 0) {
                                                          //Card is LEFT swiping
                                                        } else if (align.x > 0) {
                                                          //Card is RIGHT swiping
                                                        }
                                                      },
                                                      swipeCompleteCallback:
                                                          (CardSwipeOrientation orientation, int index) {
                                                        if (orientation == CardSwipeOrientation.RIGHT){
                                                          likedb.sendLike(users[index].uid);
                                                          if (users.length == 1){
                                                            setState(() {
                                                              noMoreUser = true;
                                                            });
                                                          }
                                                        }else if (orientation == CardSwipeOrientation.LEFT){
                                                          likedb.sendDislike(users[index].uid);
                                                          if (users.length == 1){
                                                            setState(() {
                                                              noMoreUser = true;
                                                            });
                                                          }
                                                        }
                                                        /// Get orientation & index of swiped card!
                                                      })),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  MyHomeButton(Icons.clear, ()=> controller.triggerLeft()),
                                                  MyHomeButton(Icons.info, () => Navigator.of(context).pushNamed('/intro', arguments: users[0].uid)),
                                                  MyHomeButton(Icons.check, ()=>controller.triggerRight())
                                                ],
                                              ),
                                            ],
                                          )),
                                    ),
                                  );
                                }else if (user.isActivate != true){ //if user is inactive
                                  return Scaffold(
                                    appBar: AppBar(
                                      title: Text("CUagain"),
                                      flexibleSpace: Container(
                                        decoration: appBarDecoration,
                                      ),
                                    ),
                                    body: Container(
                                      decoration: bodyDecoration,
                                      child: Center(
                                        child: Text("Your account is inactivate", style: TextStyle(color: Colors.orange, fontSize: 50),),
                                      ),
                                    ),
                                  );
                                }else{ //when all user has shown
                                  return Scaffold(
                                    appBar: AppBar(
                                      title: Text("CUagain"),
                                      flexibleSpace: Container(
                                        decoration: appBarDecoration,
                                      ),
                                    ),
                                    body: Container(
                                      decoration: bodyDecoration,
                                      child: Center(
                                        child: Text("No user for you to choose now", style: TextStyle(color: Colors.orange, fontSize: 50),),
                                      ),
                                    ),
                                  );
                                }
                              }else{
                                return Loading();
                              }
                            }
                        );
                      }
                      else{
                        return Loading();
                      }
                    }
                );
            }else{
              return Loading();
            }
          }
      );
    }else{
      return Loading();
    }
  }
}



