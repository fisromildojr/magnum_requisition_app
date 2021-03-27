import 'package:flutter/material.dart';
import 'package:magnum_requisition_app/models/auth_data.dart';

class MenuCard extends StatelessWidget {
  MenuCard({this.title, this.icon, this.color, this.url, this.user});

  final String title;
  final IconData icon;
  final MaterialColor color;
  final String url;
  final AuthData user;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            url,
            arguments: user,
          );
        },
        splashColor: Theme.of(context).primaryColor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 60.0,
                color: color,
              ),
              Text(title, style: new TextStyle(fontSize: 15.0)),
            ],
          ),
        ),
      ),
    );
  }
}
