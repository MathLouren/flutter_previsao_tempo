import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  bool _showPassword = false;

  void _login() {
    String email = emailController.text;
    String senha = senhaController.text;
    String nome = nomeController.text;

    if (email == 'admin@email.com' && senha == '123456') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(email: email, nome: nome),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Erro de Login'),
          content: Text('Email ou senha inválidos.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400,
          ), // 👈 largura máxima de 400px
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Icon(Icons.lock, size: 100, color: Colors.blue),
                  SizedBox(height: 20),
                  Text(
                    'Login',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: senhaController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('Entrar'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterPage()),
                      );
                    },
                    child: Text('Não tem conta? Criar agora'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  bool _showPassword = false;

  void _register() {
    String nome = nomeController.text;
    String email = emailController.text;
    String senha = senhaController.text;

    if (nome.isNotEmpty && email.isNotEmpty && senha.isNotEmpty) {
      // Simulação de criação de conta
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(email: email, nome: nome),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Erro'),
          content: Text('Todos os campos são obrigatórios.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Criar Conta')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Icon(Icons.person_add, size: 100, color: Colors.blue),
                  SizedBox(height: 20),
                  TextField(
                    controller: nomeController,
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: senhaController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _register,
                    child: Text('Cadastrar'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomePageState extends State<HomePage> {
  String _weatherInfo = '';
  String _city = '';
  final TextEditingController _cityController = TextEditingController();

  final String apiKey = '411fbfe0c29a437baaf233915251302'; // 👈 Substitua aqui

  @override
  void initState() {
    super.initState();
    _getLocationAndWeather();
  }

  Future<void> _getLocationAndWeather() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      Position position = await Geolocator.getCurrentPosition();

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      String city = placemarks.first.locality ?? 'Local';

      _getWeather(city);
    } catch (e) {
      setState(() {
        _weatherInfo = 'Erro ao obter localização';
      });
    }
  }

  Future<void> _getWeather(String city) async {
    try {
      final url =
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&lang=pt_br&units=metric';

      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _city = city;
          _weatherInfo =
              '${data['weather'][0]['description']}, ${data['main']['temp']}°C';
        });
      } else {
        setState(() {
          _weatherInfo = 'Cidade não encontrada.';
        });
      }
    } catch (e) {
      setState(() {
        _weatherInfo = 'Erro ao buscar clima';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Página Inicial')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bem-vindo, ${widget.nome}!',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 20),
                Text(
                  _city.isNotEmpty
                      ? 'Tempo em $_city:'
                      : 'Buscando localização...',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                Text(_weatherInfo, style: TextStyle(fontSize: 18)),
                SizedBox(height: 30),
                TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'Buscar outra cidade',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _getWeather(_cityController.text);
                  },
                  child: Text('Buscar clima'),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            UserInfo(email: widget.email, nome: widget.nome),
                      ),
                    );
                  },
                  child: Text('Ir para Perfil'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserInfo extends StatelessWidget {
  final String nome;
  final String email;

  UserInfo({required this.email, required this.nome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Página do Usuário')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Email: $email', style: TextStyle(fontSize: 24)),
            SizedBox(height: 12),
            Text('Nome: $nome', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String email;
  final String nome;

  HomePage({required this.email, required this.nome});

  @override
  _HomePageState createState() => _HomePageState();
}
