import 'package:google_maps_flutter/google_maps_flutter.dart';

class Magasin {
  final String nom;
  final String categorie;
  final String adresse;
  final String image;
  final LatLng location;
  final int rating;

  Magasin(
    this.nom,
    this.categorie,
    this.adresse,
    this.image,
    this.location,
    this.rating,
  );
}
