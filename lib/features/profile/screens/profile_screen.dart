import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen ({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16), 
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              child: Icon(
                Icons.person,
                size: 50,
              ),
            ), 
            
            const SizedBox(height: 6,), 
            const Text(
              "Usuario Buy Market", 
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold
              ),
            ), 
            const SizedBox(height: 6,), 
            const Text(
              'usuario@buyMarket.com', 
              style: TextStyle(
                color: Colors.grey
              ),
            ), 
            const SizedBox(height: 30,), 
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Mis compras'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: (){},
            ), 
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favoritos'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }

}