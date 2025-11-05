import 'package:flutter/material.dart';
import '../widgets/content_card.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({Key? key}) : super(key: key);

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final List<Map<String, dynamic>> usuarios = [
    {
      'nombre': 'Juan Pérez',
      'email': 'juan@pos.com',
      'rol': 'Administrador',
      'estado': 'Activo',
    },
    {
      'nombre': 'María López',
      'email': 'maria@pos.com',
      'rol': 'Cajero',
      'estado': 'Activo',
    },
    {
      'nombre': 'Carlos Ruiz',
      'email': 'carlos@pos.com',
      'rol': 'Vendedor',
      'estado': 'Inactivo',
    },
  ];

  void nuevoUsuario() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función crear nuevo usuario')),
    );
  }

  void editarUsuario(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editar ${usuarios[index]['nombre']}')),
    );
  }

  void eliminarUsuario(int index) {
    setState(() {
      usuarios.removeAt(index);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Usuario eliminado')));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ContentCard(
        title: 'Gestión de Usuarios',
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Usuarios del Sistema',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: nuevoUsuario,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Nuevo Usuario'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildUserTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTable() {
    return Table(
      border: TableBorder.all(color: const Color(0xFFE2E8F0)),
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
          children: [
            _buildTableHeader('Nombre'),
            _buildTableHeader('Email'),
            _buildTableHeader('Rol'),
            _buildTableHeader('Estado'),
            _buildTableHeader('Acciones'),
          ],
        ),
        ...usuarios.asMap().entries.map((entry) {
          int index = entry.key;
          var usuario = entry.value;
          return TableRow(
            children: [
              _buildTableCell(usuario['nombre']),
              _buildTableCell(usuario['email']),
              _buildTableCell(usuario['rol']),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Chip(
                  label: Text(usuario['estado']),
                  backgroundColor: usuario['estado'] == 'Activo'
                      ? Colors.green[100]
                      : Colors.grey[300],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => editarUsuario(index),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        size: 20,
                        color: Colors.red,
                      ),
                      onPressed: () => eliminarUsuario(index),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(padding: const EdgeInsets.all(12), child: Text(text));
  }
}
