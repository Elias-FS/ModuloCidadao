import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modulo_cidadao/screens/seleciona_ticket.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:modulo_cidadao/Model/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



class maps extends StatefulWidget {
  const maps({Key? key}) : super(key: key);

  @override
  _mapsState createState() => _mapsState();
}

class _mapsState extends State<maps> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  List<LatLng> vetorDeCoordenadas1 = [];

  Future<void> getZoneCoords() async {
    final result =
    await FirebaseFunctions.instanceFor(region: "southamerica-east1")
        .httpsCallable('getZonaAzulCidadao')
        .call();
      for(var item in result.data[0]["points"]) {
        vetorDeCoordenadas1.add(LatLng(item["_latitude"], item["_longitude"]));
        print(vetorDeCoordenadas1);
      }
  }

  static const  vetorDeLojas = [LatLng(-22.85664450504122, -47.21118569636944),
    LatLng(-22.856633991780658, -47.212044188759094)];


  //coordenadas do banco área 2
  static const  vetorDeCoordenadas2 = [LatLng(-22.850581584002967, -47.21561588037242),
    LatLng(-22.852611720198848, -47.213714430768306),
    LatLng(-22.852585767617885, -47.21354411050538),
    LatLng(-22.849503593340934, -47.213595207143214)];


      static final CameraPosition _hortolandia = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(-22.85250050972797, -47.21071312998611),
      tilt: 59.440717697143555,
      zoom: 18.151926040649414);


  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? androidNotification = message.notification?.android;

      if(notification!=null&&androidNotification!=null){
        flutterLocalNotificationsPlugin.show(
            notification.hashCode.toInt(),
            notification.title.toString(),
            notification.body.toString(),
            NotificationDetails(
                android:AndroidNotificationDetails(
                    channel.id,
                    channel.name,
                    channelDescription: channel.description,
                    color: Colors.blue,
                    playSound: true,
                    icon: '@mipmap/ic_launcher'
                )
            )
        );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title.toString()),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body.toString())],
                  ),
                ),
              );
            });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    getZoneCoords();

    final Polygon _Polygon = Polygon(
        consumeTapEvents: true,
        polygonId: PolygonId('_Polygon'),
        points: vetorDeCoordenadas1,
        strokeWidth: 5,
        fillColor: Colors.lightBlueAccent.withOpacity(0.3),
        onTap: () {
          final AlertDialog infoArea = AlertDialog(
                       //Puxa a área do banco
            title: Text('Area Azul do Mapa'),
                 //chamar infos do banco da área aqui
            content: Text('RS 02:00 por hora. \n-Sorveteria Souza\n- Café Colonial Padaria & Confeitaria\n- Café do Nil'),
            actions: [
              FlatButton(
                textColor: Color(0xFF6200EE),
                onPressed: () {
                  Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => seleciona_ticket()),
                  );
                },
                child: Text('Comprar'),
              ),
            ],
          );
          showDialog(context: context, builder: (context) => infoArea);
        }
    );


    final Polygon _Polygon2 = Polygon(
        consumeTapEvents: true,
        polygonId: PolygonId('_Polygon'),
        points: vetorDeCoordenadas2,
        strokeWidth: 5,
        fillColor: Colors.deepPurpleAccent.withOpacity(0.3),
        onTap: () {
          final AlertDialog infoArea = AlertDialog(
                        //Puxa a área do banco
            title: Text('Area Roxa do Mapa'),
                    //chamar infos do banco da área aqui
            content: Text('RS 02:00 por hora. \n- Mult Preços\n- Agro Teca Animal\n- Ice Skobra Bar'),
            actions: [
              FlatButton(
                textColor: Color(0xFF6200EE),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => seleciona_ticket()),
                  );
                },
                child: Text('Comprar'),
              ),
            ],
          );
          showDialog(context: context, builder: (context) => infoArea);
        }
    );


     final Polyline _Polyline = Polyline(
        polylineId: PolylineId('_Polyline'),
        points: vetorDeLojas,
        width: 0
    );

       final Marker _Marker = Marker(
         markerId: MarkerId('_Marker'),
         position: vetorDeLojas[1],
       );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Areas de Zona Azul'),
          backgroundColor: Colors.lightBlueAccent[700],
        ),
        body: Stack(
            children:[
              GoogleMap(
                  mapType: MapType.normal,
                  onMapCreated: _onMapCreated,
                  polylines: {
                    _Polyline
                  },
                  polygons: {
                    _Polygon2,
                    _Polygon
                  },
                  //markers: {
                    //_Marker
                  //},
                  initialCameraPosition: _hortolandia
              ),
            ]
        ),
      ),
    );
  }
}