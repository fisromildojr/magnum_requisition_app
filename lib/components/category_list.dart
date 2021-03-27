import 'package:magnum_requisition_app/models/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryList extends StatefulWidget {
  final void Function(Category category) onTap;

  CategoryList(this.onTap);

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  _selectCategory(BuildContext context, Category category) {
    widget.onTap(category);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('categories')
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
            final Category category = Category(
              id: documents[i].id,
              name: documents[i]['name'],
            );
            // print(provider.fantasyName + ' => ' + provider.email);
            return Container(
              child: ListTile(
                title: Text(category.name),
                onTap: () => _selectCategory(context, category),
              ),
            );
          },
        );
      },
    );
  }
}
