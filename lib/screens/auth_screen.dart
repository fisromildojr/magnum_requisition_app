import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:magnum_requisition_app/components/auth_form.dart';
import 'package:magnum_requisition_app/models/auth_data.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = false;

  Future<void> _handleSubmit(AuthData authData) async {
    setState(() {
      _isLoading = true;
    });

    UserCredential userCredential;

    try {
      if (authData.isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: authData.email.trim(),
          password: authData.password,
        );
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: authData.email.trim(),
          password: authData.password,
        );

        final userData = {
          'name': authData.name,
          'email': authData.email,
          'active': false,
          'isAdmin': false,
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user.uid)
            .set(userData);
      }
    } catch (err) {
      var msg = err.code ?? 'Ocorreu um erro! Verifique suas credenciais!';
      if (err.code == "too-many-requests") msg = "Senha inválida...";
      if (err.code == "user-not-found") msg = "Usuário não encontrado...";
      if (err.code == "unknown") msg = "Verifique sua conexão!";
      if (err.code == "too-many-requests")
        msg =
            "Bloqueamos todas as solicitações deste dispositivo devido a atividade incomum. Tente mais tarde.";
      if (err.code == "user-disabled")
        msg = "Usuário desabilitado, procure o administrador!";
      print(err.code);
      print(err.message);
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // backgroundColor: Theme.of(context).primaryColor,
      backgroundColor: Colors.orange[300],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (Image.asset('assets/images/cropped.png') != null)
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  'assets/images/cropped.png',
                  // fit: BoxFit.cover,
                ),
              ),
            Stack(
              children: [
                AuthForm(_handleSubmit),
                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      margin: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
