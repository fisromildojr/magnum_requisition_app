import 'package:magnum_requisition_app/components/category_form.dart';
import 'package:magnum_requisition_app/models/category.dart';
import 'package:magnum_requisition_app/utils/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  _openCategoryFormModal(context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return CategoryForm(_addCategory);
      },
    );
  }

  Future<void> _addCategory(Category category) async {
    Navigator.of(context).pop();

    await FirebaseFirestore.instance.collection('categories').add({
      'name': category.name.toUpperCase(),
      'excluded': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categorias'),
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
      ),
      body: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('categories')
              .where('excluded', isEqualTo: false)
              .orderBy('name')
              .snapshots(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final documents = snapshot.data.documents;

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (ctx, i) {
                return Container(
                  child: Card(
                    elevation: 1,
                    child: ListTile(
                      title: Text(documents[i]['name']),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => _openCategoryFormModal(context),
      ),
    );
  }
}
