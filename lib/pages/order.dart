import 'package:flutter/material.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Column(
        children: [
          // Contenedor superior que ocupa todo el ancho
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              height: 70,
              width: double.infinity, // ocupa todo el ancho disponible
              decoration: BoxDecoration(color: Colors.white),
            ),
          ),

          const SizedBox(height: 5),

          // Fila con dos contenedores
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              children: [
                // contenedor categorias de productos
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(color: Colors.white),
                  ),
                ),

                const SizedBox(width: 10),
                // contenedor categorias de productos
                Container(
                  height: 60,
                  width: 700, // ancho fijo más pequeño
                  decoration: BoxDecoration(color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 1),

          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        //contenedor de ordenes
                        height: 300,
                        decoration: BoxDecoration(color: Colors.white),
                      ),

                      const SizedBox(height: 5),
                      Container(
                        //contenedor total
                        height: 50,
                        color: Colors.white,
                      ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          //boton NOTA
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.note),
                              label: Text('NOTA'),
                              style: ButtonStyle(
                                minimumSize: WidgetStateProperty.all(
                                  Size(130, 50),
                                ),
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                  Colors.black,
                                ),
                                alignment: Alignment.center,
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 5), //separamos en alto
                          const SizedBox(width: 5), //serparamos en ancho
                          //boton CANCELAR
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.cancel),
                              label: Text('CANCELAR'),
                              style: ButtonStyle(
                                minimumSize: WidgetStateProperty.all(
                                  Size(130, 50),
                                ),
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                  Colors.black,
                                ),
                                alignment: Alignment.center,
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 5), //separamos en alto
                          const SizedBox(width: 5), //serparamos en ancho
                          //boton tiempo
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.access_time),
                              label: Text('TIEMPOS'),
                              style: ButtonStyle(
                                minimumSize: WidgetStateProperty.all(
                                  Size(130, 50),
                                ),
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                  Colors.black,
                                ),
                                alignment: Alignment.center,
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 5),
                          const SizedBox(height: 5),
                          //boton ELIMINAR
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                minimumSize: WidgetStateProperty.all(
                                  Size(50, 50),
                                ),
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                  Colors.black,
                                ),
                                alignment: Alignment.center,
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                              ),
                              child: Icon(Icons.delete, size: 30),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),
                      Row(
                        children: [
                          //boton TRANSFERIR
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_back),
                                  SizedBox(width: 5),
                                  Text('MOVER'),
                                ],
                              ),
                              style: ButtonStyle(
                                minimumSize: WidgetStateProperty.all(
                                  Size(130, 50),
                                ),
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                  Colors.black,
                                ),
                                alignment: Alignment.center,
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 5),
                          const SizedBox(height: 5),
                          //boton 1
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              label: Text('1', style: TextStyle(fontSize: 20)),
                              style: ButtonStyle(
                                minimumSize: WidgetStateProperty.all(
                                  Size(90, 50),
                                ),
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                  Colors.black,
                                ),
                                alignment: Alignment.center,
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 5),
                          const SizedBox(height: 5),
                          //boton 2
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              label: Text('2', style: TextStyle(fontSize: 20)),
                              style: ButtonStyle(
                                minimumSize: WidgetStateProperty.all(
                                  Size(90, 50),
                                ),
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                  Colors.black,
                                ),
                                alignment: Alignment.center,
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 5),
                          const SizedBox(height: 5),
                          //boton 2
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              label: Text('3', style: TextStyle(fontSize: 20)),
                              style: ButtonStyle(
                                minimumSize: WidgetStateProperty.all(
                                  Size(90, 50),
                                ),
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                  Colors.black,
                                ),
                                alignment: Alignment.center,
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 5),
                          const SizedBox(height: 5),
                          //boton 2
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              label: Text('+', style: TextStyle(fontSize: 20)),
                              style: ButtonStyle(
                                minimumSize: WidgetStateProperty.all(
                                  Size(75, 50),
                                ),
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                  Colors.black,
                                ),
                                alignment: Alignment.center,
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),
                //contenedor de imagenes de productos
                Container(
                  height: 680,
                  width: 700,
                  decoration: BoxDecoration(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
