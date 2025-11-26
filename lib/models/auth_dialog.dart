import 'package:flutter/material.dart';
import '../models/auth_service.dart';

class AuthDialog extends StatefulWidget {
  final String titulo;
  final String mensaje;

  const AuthDialog({
    super.key,
    this.titulo = 'Autorización requerida',
    this.mensaje = 'Ingrese las credenciales de administrador',
  });

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _mostrarPassword = false;
  bool _verificando = false;
  String? _errorMensaje;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _verificarCredenciales() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMensaje = 'Por favor complete todos los campos';
      });
      return;
    }

    setState(() {
      _verificando = true;
      _errorMensaje = null;
    });

    try {
      // Verificar credenciales con Firebase Auth
      final adminData = await AuthService.verificarCredencialesAdmin(
        email,
        password,
      );

      if (!mounted) return;

      if (adminData != null) {
        // Credenciales correctas
        Navigator.pop(context, {
          'autorizado': true,
          'adminNombre': adminData['nombre'],
          'adminId': adminData['id'],
          'adminEmail': adminData['email'],
        });
      } else {
        // Credenciales incorrectas o no es admin
        setState(() {
          _errorMensaje = 'Credenciales incorrectas o no es administrador';
          _passwordController.clear();
          _verificando = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMensaje = 'Error al verificar: $e';
        _verificando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.lock, color: Colors.orange, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(widget.titulo, style: const TextStyle(fontSize: 18)),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.mensaje,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Información
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ingrese el email y contraseña de un administrador',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Campo de email
            TextField(
              controller: _emailController,
              enabled: !_verificando,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email de administrador',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 15),

            // Campo de contraseña
            TextField(
              controller: _passwordController,
              obscureText: !_mostrarPassword,
              enabled: !_verificando,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _mostrarPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _mostrarPassword = !_mostrarPassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: (_) => _verificarCredenciales(),
            ),

            // Indicador de carga
            if (_verificando) ...[
              const SizedBox(height: 15),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Verificando...',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],

            // Mensaje de error
            if (_errorMensaje != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMensaje!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _verificando ? null : () => Navigator.pop(context, null),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _verificando ? null : _verificarCredenciales,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: _verificando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Autorizar'),
        ),
      ],
    );
  }
}
