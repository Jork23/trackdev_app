import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const ProfilesPage(),
    );
  }
}

class ProfilesPage extends StatelessWidget {
  const ProfilesPage({super.key});

  // Aquesta funció va a buscar les dades
Future<List<dynamic>> getProfiles() async {
  final url = Uri.parse('https://jsonplaceholder.typicode.com/users');
  
  // Afegim 'headers' perquè el servidor sàpiga qui som
  final response = await http.get(url, headers: {
    "Accept": "application/json",
    "Access-Control-Allow-Origin": "*"
  });

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    // Això ens dirà si el servidor ens ha enviat un error 404, 500, etc.
    throw Exception('Error del servidor: ${response.statusCode}');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Els meus Profiles')),
      body: FutureBuilder(
        future: getProfiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            final llista = snapshot.data as List;
            return ListView.builder(
              itemCount: llista.length,
              itemBuilder: (context, i) {
                return ListTile(
                  leading: CircleAvatar(child: Text(llista[i]['name'][0])),
                  title: Text(llista[i]['name']),
                  subtitle: Text(llista[i]['email']),
                );
              },
            );
          }
          return Center(child: Text('Error: ${snapshot.error}'));
        },
      ),
    );
  }
}