import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:veg/sellerpages/startjourney/location.dart';

class StartJourney extends StatefulWidget {
  @override
  State<StartJourney> createState() => _StartJourney();
}

class _StartJourney extends State<StartJourney> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  String? _currentUserDistrict;
  Map<String, dynamic>? _searchResult;
  String? _vegetableImagePath;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserDistrict();
  }

  Future<void> _fetchCurrentUserDistrict() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String uid = user.uid;
        final DatabaseEvent event = await _database.child('Users/$uid').once();
        final DataSnapshot snapshot = event.snapshot;

        if (snapshot.value != null) {
          final Map<String, dynamic> userData =
          Map<String, dynamic>.from(snapshot.value as Map);

          setState(() {
            _currentUserDistrict = userData['district'];
          });

          print("Current User District: $_currentUserDistrict");
        } else {
          print("User data not found in database.");
        }
      } else {
        print("User is not logged in.");
      }
    } catch (e) {
      print("Error fetching user district: $e");
    }
  }

  Future<void> _searchItem(String query) async {
    try {
      final DatabaseEvent event =
      await _database.child('history_for_algo').once();
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        final Map<String, dynamic> data =
        Map<String, dynamic>.from(snapshot.value as Map);

        for (var vegetable in data.entries) {
          final vegetableName = vegetable.key;
          final districtData = Map<String, dynamic>.from(vegetable.value);

          if (query.trim().toLowerCase() ==
              vegetableName.trim().toLowerCase()) {
            Map<String, dynamic> matchingDistrictData = {};

            for (var districtEntry in districtData.entries) {
              final districtName = districtEntry.key;

              // Only show data for the current user's district
              if (_currentUserDistrict != null &&
                  districtName.toLowerCase() ==
                      _currentUserDistrict!.toLowerCase()) {
                final districtInfo =
                Map<String, dynamic>.from(districtEntry.value);

                if (districtInfo.isNotEmpty) {
                  Map<String, dynamic> subPlaceData = {};

                  for (var subPlaceEntry in districtInfo.entries) {
                    if (subPlaceEntry.key != 'total_quantity') {
                      final subPlaceName = subPlaceEntry.key;
                      final subPlaceInfo =
                      Map<String, dynamic>.from(subPlaceEntry.value);

                      if (subPlaceInfo.containsKey('total_quantity')) {
                        subPlaceData[subPlaceName] =
                        subPlaceInfo['total_quantity'];
                      }
                    }
                  }

                  if (subPlaceData.isNotEmpty) {
                    matchingDistrictData[districtName] = subPlaceData;
                  }
                }
              }
            }
            if (matchingDistrictData.isNotEmpty) {
              setState(() {
                _searchResult = {
                  'name': query,
                  'details': matchingDistrictData,
                };
                _vegetableImagePath =
                "assets/images/seller_image/Vegetables/${query.trim().toLowerCase()}.jpg"; // Set image
              });
              return;
            }
          }
        }
      }

      setState(() {
        _searchResult = null;
        _vegetableImagePath = null;
      });
    } catch (e) {
      print("Error in search: $e");
    }
  }

  /* Map<String, int> _getOtherDistrictsData(Map<String, dynamic> districtData) {
    print('Input districtData: $districtData');
    print('Current user district: $_currentUserDistrict');

    Map<String, int> otherDistrictsData = {};

    // Convert districtData to a List to use a regular for loop
    List<String> districtNames = districtData.keys.toList();

    // Loop through the districts using a for loop
    for (int i = 0; i < districtNames.length; i++) {
      String districtName = districtNames[i];
      var districtInfo = districtData[districtName];

      print('Processing district: $districtName');

      // Skip the current user's district
      if (_currentUserDistrict == null ||
          districtName.toLowerCase() != _currentUserDistrict!.toLowerCase()) {
        final districtDetails = Map<String, dynamic>.from(districtInfo);
        print('District details: $districtDetails');

        int totalSell = 0;

        // Process areas within the district
        districtDetails.forEach((areaName, areaInfo) {
          if (areaInfo is Map && areaInfo.containsKey('total_quantity')) {
            final int areaQuantity = areaInfo['total_quantity'] as int;
            print('Area: $areaName, Quantity: $areaQuantity');
            totalSell += areaQuantity;
            print('Running total for $districtName: $totalSell');
          }
        });

        // Only add to the result if the total is greater than 0
        if (totalSell > 0) {
          otherDistrictsData[districtName] = totalSell;
        }
      } else {
        print('Skipping current user district: $districtName');
      }
    }

    print('Final otherDistrictsData: $otherDistrictsData');
    return otherDistrictsData;
  }
*/
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text(
            'Select Your Path',
            style: TextStyle(fontSize: 20.0, color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: "Search Vegetable",
                              border: InputBorder.none,
                            ),
                            onFieldSubmitted: (value) {
                              _searchItem(value);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            _searchItem(_searchController.text);
                          },
                          child: const Icon(
                            Icons.search,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_searchResult != null)
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3), // Shadow position
                                ),
                              ],
                              image: _vegetableImagePath != null
                                  ? DecorationImage(
                                image: AssetImage(_vegetableImagePath!),
                                fit: BoxFit.cover,
                              )
                                  : null, // Handle null image path
                            ),
                            padding: const EdgeInsets.all(5),
                          ),
                          const SizedBox(width: 30),
                          Text(
                            "Item: ${_searchResult!['name']}",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ..._searchResult!['details']
                                .entries
                                .map<Widget>((districtEntry) {
                              final districtName = districtEntry.key;
                              final areas = Map<String, dynamic>.from(
                                  districtEntry.value);
                              final sortedAreas = areas.entries.toList()
                                ..sort((a, b) =>
                                    (b.value as int).compareTo(a.value as int));

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "District : $districtName",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ...List.generate(sortedAreas.length, (index) {
                                    final areaEntry = sortedAreas[index];
                                    final areaName = areaEntry.key;
                                    final quantity = areaEntry.value;

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 10.0, top: 10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${index + 1}. $areaName",
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          MapPageStar(
                                                            areaName: areaName,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  minimumSize:
                                                  const Size(50, 25),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.arrow_forward,
                                                  color: Colors.white,
                                                  size: 25,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(top: 1.0),
                                            child: Text(
                                              "     Total sell = $quantity kg",
                                              style:
                                              const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 10),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    /*  Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Other Districts",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ..._getOtherDistrictsData(_searchResult!['details']
                                    as Map<String, dynamic>)
                                .entries
                                .map((entry) {
                              final districtName = entry.key;
                              final totalSell = entry.value;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      districtName,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "$totalSell kg",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MapPageStar(
                                                  areaName: districtName,
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            minimumSize: const Size(50, 25),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                            size: 25,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ), */
                  ],
                )
              else
                const Center(
                  child: Text(
                    "No matching data found",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}