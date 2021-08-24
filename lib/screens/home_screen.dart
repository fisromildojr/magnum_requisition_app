import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:magnum_requisition_app/components/menu_card.dart';
import 'package:magnum_requisition_app/models/auth_data.dart';
import 'package:magnum_requisition_app/utils/app_routes.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> userData(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return userData;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final appBar = AppBar(
      title: Text("Início"),
      actions: [
        DropdownButtonHideUnderline(
          child: DropdownButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            items: [
              DropdownMenuItem(
                value: 'logout',
                child: Container(
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app),
                      SizedBox(width: 8),
                      Text('Sair'),
                    ],
                  ),
                ),
              ),
            ],
            onChanged: (item) {
              if (item == 'logout') {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushNamed(
                  AppRoutes.HOME,
                );
              }
            },
          ),
        ),
      ],
    );

    final availableHeight = MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: appBar,

      // drawer: Drawer(
      //   child: ListView(
      //     children: <Widget>[
      //       UserAccountsDrawerHeader(
      //         accountName: Text(
      //           userName().toString(),
      //           style: TextStyle(
      //             fontWeight: FontWeight.bold,
      //             fontSize: 17.0,
      //           ),
      //         ),
      //         accountEmail: Text("fis.romildojr@gmail.com"),
      //         currentAccountPicture: CircleAvatar(
      //           backgroundImage: NetworkImage(
      //               "https://cdn.pixabay.com/photo/2013/07/13/10/07/man-156584_960_720.png"),
      //         ),
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.add),
      //         title: Text("Solicitar"),
      //         onTap: () {
      //           Navigator.pushNamed(context, '/requisitions_form1');
      //         },
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.description),
      //         title: Text("Requisições"),
      //         onTap: () {
      //           Navigator.pushNamed(context, '/requisitions_list');
      //         },
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.supervised_user_circle),
      //         title: Text("Usuários"),
      //         onTap: () {
      //           Navigator.pushNamed(context, '/users_list');
      //         },
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.assignment),
      //         title: Text("Relatórios"),
      //         onTap: () {
      //           Navigator.pushNamed(context, '/reports');
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (ctx, snapshot) {
          // print(snapshot.data.id);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final user = AuthData(
            id: snapshot.data.id,
            name: snapshot.data['name'],
            email: snapshot.data['email'],
            active: snapshot.data['active'],
            isAdmin: snapshot.data['isAdmin'],
          );

          final fbm = FirebaseMessaging();
          if (user.isAdmin) {
            fbm.subscribeToTopic('requisition_create');
            fbm.subscribeToTopic('user_create');
          }
          fbm.subscribeToTopic('requisition_update_' + user.id);
          fbm.requestNotificationPermissions();

          fbm.requestNotificationPermissions();

          return Stack(
            children: [
              Column(
                children: [
                  if (user.isAdmin)
                    Container(
                      height: availableHeight * 0.2,
                      padding: EdgeInsets.all(10.0),
                      child: MenuCard(
                        title: "Relatorio",
                        icon: Icons.file_copy,
                        color: Colors.orange,
                        url: AppRoutes.RELATORIOS,
                        user: user,
                      ),
                    ),
                  Container(
                    height: availableHeight * 0.8,
                    padding: EdgeInsets.all(10.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      children: <Widget>[
                        MenuCard(
                          title: "Solicitar",
                          icon: Icons.add,
                          color: Colors.blue,
                          url: AppRoutes.REQUISITION_FORM_SCREEN,
                          user: user,
                        ),
                        MenuCard(
                          title: "Requisições",
                          icon: Icons.description,
                          color: Colors.deepOrange,
                          url: AppRoutes.REQUISITIONS,
                          user: user,
                        ),
                        if (user.isAdmin)
                          MenuCard(
                            title: "Usuários",
                            icon: Icons.supervised_user_circle,
                            color: Colors.orange,
                            url: AppRoutes.USERS,
                            user: user,
                          ),
                        if (user.isAdmin)
                          MenuCard(
                            title: "Categorias",
                            icon: Icons.category,
                            color: Colors.lightGreen,
                            url: AppRoutes.CATEGORIES,
                            user: user,
                          ),
                        if (user.isAdmin)
                          MenuCard(
                            title: "Departamentos",
                            icon: Icons.extension,
                            color: Colors.lightBlue,
                            url: AppRoutes.DEPARTMENTS,
                            user: user,
                          ),
                        if (user.isAdmin)
                          MenuCard(
                            title: "Fornecedores",
                            icon: Icons.person_pin_circle,
                            color: Colors.red,
                            url: AppRoutes.PROVIDERS,
                            user: user,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!user.active)
                Container(
                  color: Colors.black87,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 200,
                          child: Image.asset(
                            'assets/images/face-emoji.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FittedBox(
                            child: Text(
                              'Você não tem permissão suficiente!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FittedBox(
                            child: Text(
                              'Procure um dos administradores para liberar seu acesso!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
