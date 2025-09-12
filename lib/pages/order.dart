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
                                minimumSize: MaterialStateProperty.all(
                                  Size(150, 50),
                                ),
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.white,
                                ),
                                foregroundColor: MaterialStateProperty.all(
                                  Colors.black,
                                ),
                                alignment: Alignment.center,
                                shape: MaterialStateProperty.all(
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
                                minimumSize: MaterialStateProperty.all(
                                  Size(150, 50),
                                ),
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.white,
                                ),
                                foregroundColor: MaterialStateProperty.all(
                                  Colors.black,
                                ),
                                alignment: Alignment.center,
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 5),
                          //boton TIEMPOS
                          Align(alignment: Alignment.centerLeft),
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
