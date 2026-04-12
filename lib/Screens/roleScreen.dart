import 'package:flutter/material.dart';

class Rolescreen extends StatelessWidget {
  const Rolescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Join Local Helpers',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Center(child: Text('How would you like to use the platform?')),
          SizedBox(height: 30),
          Padding(
            padding: EdgeInsets.all(30),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Column(
                  children: [
                    Row( children: [
                          Icon(Icons.person)
                    ]
                    ),
                    SizedBox(height: 20,),
                    Row(
                      children: [
                      Text('I Need Help', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, wordSpacing: 5),),
                    ]),
                    SizedBox(height: 10,),
                    Text('Post tasks and find qualified local helpers to assist you with various jobs.' ,softWrap: true, ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
