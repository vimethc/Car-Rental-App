import 'package:car_rental_app/presentation/pages/car_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:car_rental_app/data/models/car.dart';
import 'package:car_rental_app/presentation/widgets/booking_ticket_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapsDetailsPage extends StatefulWidget {
  final Car car;

  const MapsDetailsPage({super.key, required this.car});

  @override
  _MapsDetailsPageState createState() => _MapsDetailsPageState();
}

class _MapsDetailsPageState extends State<MapsDetailsPage> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  bool _showBookingTicket = false;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this
    );

    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(_controller!)
    ..addListener(() { setState(() {
    }); });

    _controller!.forward();

    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: ()=>Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(6.9271, 79.8612),
              initialZoom: 14
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a','b','c']
              )
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _carDetailsCard(widget.car)
          ),
          if (_showBookingTicket)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: BookingTicketWidget(
                    car: widget.car,
                    passengerName: 'John Doe',
                    bookingDate: '07 Apr 2024',
                    onConfirm: () async {
                      try {
                        // Get a reference to the Firestore instance
                        FirebaseFirestore firestore = FirebaseFirestore.instance;

                        // Create a new document in the 'bookings' collection
                        await firestore.collection('bookings').add({
                          'carModel': widget.car.model,
                          'passengerName': 'John Doe', // Using placeholder name
                          'bookingDate': '07 Apr 2024', // Using placeholder date
                          'pricePerHour': widget.car.pricePerHour,
                          'timestamp': FieldValue.serverTimestamp(), // Add a timestamp
                        });

                        // Show confirmation SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Booking Confirmed and Saved!'), // Updated message
                            duration: Duration(seconds: 2),
                          ),
                        );

                        // Navigate back to CarListScreen
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => CarListScreen()),
                          (route) => false,
                        );
                      } catch (e) {
                        // Handle errors during saving
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error saving booking: ${e.toString()}'),
                            backgroundColor: Colors.redAccent,
                            duration: Duration(seconds: 4),
                          ),
                        );
                        print('Error saving booking to Firestore: $e');
                      }
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _carDetailsCard(Car car) {
    return SizedBox(
      height: 350,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10)
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20,),
                Text(car.model, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),),
                SizedBox(height: 10,),
                Row(
                  children: [
                    Icon(Icons.directions_car, color: Colors.white, size: 16,),
                    SizedBox(width: 5,),
                    Text(
                      '> ${car.distance} km',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(width: 10,),
                    Icon(Icons.battery_full, color: Colors.white, size: 14,),
                    SizedBox(width: 5,),
                    Text(
                      car.fuelCapacity.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                )
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Features", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                  _featureIcons(),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${car.pricePerHour}/day', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                      ElevatedButton(
                          onPressed: (){
                            setState(() {
                              _showBookingTicket = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                          child: Text('Book Now', style: TextStyle(color: Colors.white),)
                      )
                    ],
                  )
                ],
              ),
            ),
          ),

          Positioned(
            top: 50,
            right: 20,
            child: Image.asset('assets/white_car.png')
          )
        ],
      ),
    );
  }

  Widget _featureIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _featureIcon(Icons.local_gas_station, 'Diesel', 'Common Rail'),
        _featureIcon(Icons.speed, 'Acceleration', '0 - 100km/s'),
        _featureIcon(Icons.ac_unit, 'Cold', 'Temp Control'),
      ],
    );
  }

  Widget _featureIcon(IconData icon, String title, String subtitle){
    return Container(
      width: 100,
      height: 100,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: 1)
      ),
      child: Column(
        children: [
          Icon(icon, size: 28,),
          Text(title),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey, fontSize: 10),
          )
        ],
      ),
    );
  }
}