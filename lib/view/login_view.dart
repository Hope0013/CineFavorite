import 'package:cine_favorite/controller/auth_controller.dart';
import 'package:cine_favorite/model/user_model.dart';
import 'package:flutter/material.dart';
import 'search_view.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController _authController = AuthController();
  final TextEditingController _nameController = TextEditingController();

  List<UserModel> _users = [];
  bool _isLoading = true;

  // Imagens para os perfis
  final List<String> _defaultAvatars = [
    'https://upload.wikimedia.org/wikipedia/commons/0/0b/Netflix-avatar.png',
    'https://mir-s3-cdn-cf.behance.net/project_modules/disp/84c20033850498.56ba69ac290ea.png',
    'https://mir-s3-cdn-cf.behance.net/project_modules/disp/1bdc9a33850498.56ba69ac2ba5b.png',
    'https://mir-s3-cdn-cf.behance.net/project_modules/disp/bf6a4b33850498.56ba69ac2b3f2.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var list = await _authController.getAllUsers();
      setState(() {
        _users = list;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar perfis. Verifique o banco de dados.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _selectUser(UserModel user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SearchView(user: user)),
    );
  }

  // Diálogo para confirmar a exclusão do perfil
  void _confirmDeleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Excluir Perfil', style: TextStyle(color: Colors.white)),
          content: Text(
            'Deseja realmente excluir o perfil "${user.name}"?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                if (user.id != null) {
                  await _authController.deleteUser(user.id!);
                  _loadUsers(); // Recarrega a lista sem o usuário excluído
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Perfil "${user.name}" excluído.')),
                  );
                }
              },
              child: Text('Excluir', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAddUserDialog() {
    _nameController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Criar Perfil', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _nameController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Nome do perfil',
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                String name = _nameController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.pop(context);
                  String avatar = (_defaultAvatars..shuffle()).first;
                  UserModel newUser = await _authController.login(name, avatar);
                  _selectUser(newUser);
                }
              },
              child: Text('Criar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 40),
            Text(
              'Usuários',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Segure o perfil para excluir',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            SizedBox(height: 30),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.red))
                  : Center(
                      child: SingleChildScrollView(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 25,
                          runSpacing: 25,
                          children: [
                            ..._users.map((user) {
                              return GestureDetector(
                                onTap: () => _selectUser(user),
                                onLongPress: () => _confirmDeleteUser(user), // Clique longo para excluir
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundImage: NetworkImage(
                                        user.profilePic,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      user.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            GestureDetector(
                              onTap: _showAddUserDialog,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.grey, width: 2),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Adicionar',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}