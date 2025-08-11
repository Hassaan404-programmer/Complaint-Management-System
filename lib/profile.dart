import "package:flutter/material.dart";

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  Icon(Icons.person, size: 200),
                  SizedBox(height: 10),
                  Text(
                    "Ali",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "@username",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Something about you",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  SizedBox(height: 30),
                  TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.info),
                      hintText: "something about your ...",
                      labelText: "Bio",
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(onPressed: () {}, child: Text("Save"))
                ],
              ),
            ),
          ),
        ));
  }
}
