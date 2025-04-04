import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
                primary:
                    Color.fromARGB(255, 103, 57, 120)), // OK/Cancel buttons
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for text fields
  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  String gender = "Other";
  bool showPreferences = false;
  String? _selectedCountry;
  String? _selectedCity;
  List<String> _selectedInterests = [];

  final Map<String, List<String>> countryCities = {
    'United States': ['New York', 'Los Angeles', 'Chicago', 'San Francisco'],
    'Canada': ['Toronto', 'Vancouver', 'Montreal'],
    'United Kingdom': ['London', 'Manchester', 'Birmingham'],
    'Australia': ['Sydney', 'Melbourne', 'Brisbane'],
    'India': ['Mumbai', 'Bangalore', 'Delhi', 'Kochi'],
    'Other': []
  };

  final List<String> _interests = [
    'UI/UX Design',
    'Artificial Intelligence',
    'Finance',
    'Web Development',
    'Mobile Development',
    'Data Science',
    'Cybersecurity',
    'Cloud Computing',
    'Blockchain',
    'Other'
  ];

  // Preferences
  String? _timeCommitment;
  bool isLoading = true; // For showing loading indicator

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadProfilePicture();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();

    if (userDoc.exists) {
      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;

      if (data != null) {
        setState(() {
          // Profile
          nameController.text = data['profile']?['fullName'] ?? "";
          dobController.text = data['profile']?['dob'] ?? "";
          gender = data['profile']?['gender'] ?? "Non-binary";
          _selectedCountry =
              data['profile']?['location']?['country'] ?? "Unknown Country";
          _selectedCity =
              data['profile']?['location']?['city'] ?? "Unknown City";
          print(data['profile']?['location']);
          print(data['profile']?['gender']);
          print(_selectedCity);

          // Preferences
          _selectedInterests =
              List<String>.from(data['preferences']?['interests'] ?? []);
          _timeCommitment =
              (data['preferences']?['dailyCommitment'] ?? '30').toString();
          print(_timeCommitment);

          isLoading = false;
        });
      }
    }
  }

  Future<void> _saveUserData() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Name can't be empty"),
      ));
      return;
    } else if (dobController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please Select a Valid Date of Birth"),
      ));
      return;
    } else if (gender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Select a Gender'),
      ));
      return;
    } else if (_selectedCountry!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Select a Country'),
      ));
      return;
    } else if (_selectedCity!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Select a City'),
      ));
      return;
    } else if (_selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please Select a Valid Interest/Goal"),
      ));
      return;
    } else if (_timeCommitment == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pick Valid Learning Time!'),
      ));
      return;
    }

    // Define the theme color
    Color borderColor = const Color.fromARGB(255, 127, 65, 186);

    // Show confirmation bottom sheet before saving
    bool? confirm = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thick top line
              Container(
                width: 35,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 78, 68, 98),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 15),

              // Title
              const Text(
                "Save Changes",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Message
              const Text(
                "Are you sure you want to save these changes?",
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  // Cancel Button (Outlined)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pop(context, false), // Cancel action
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: borderColor, width: 2), // Border color
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: borderColor, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Save Button (Filled)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context, true), // Confirm action
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            borderColor, // Fill color same as outline
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (confirm != true) return; // Exit if user cancels

    User? user = _auth.currentUser;
    if (user == null) return;

    String uid = user.uid;

    //change name on cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cachedUsername', nameController.text);

    Map<String, dynamic> profile = {
      'fullName': nameController.text,
      'dob': dobController.text,
      'gender': gender,
      'location': {"country": _selectedCountry, "city": _selectedCity}
    };

    Map<String, dynamic> preferences = {
      'interests': _selectedInterests,
      'dailyCommitment': _timeCommitment,
    };

    // Upload to Firebase
    await _firestore.collection('users').doc(uid).set({
      'profile': profile,
      'preferences': preferences,
    }, SetOptions(merge: true));

    // Close the current page after saving
    Navigator.pop(context);
  }

  late String profileImageUrl = '';
  //load picture
  Future<void> _loadProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    String? cachedProfileUrl = prefs.getString('cachedProfilePicture');

    if (cachedProfileUrl != null) {
      setState(() {
        profileImageUrl = cachedProfileUrl; // Load from cache
      });
      return; // Avoid Firestore call
    }

    // If no cache, fetch from Firestore
    String userId = FirebaseAuth.instance.currentUser!.uid;
    print(userId);
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      var data = userDoc.data() as Map<String, dynamic>?;
      var profile = data?['profile'] as Map<String, dynamic>?;

      if (profile != null && profile.containsKey('profilePicture')) {
        String profileUrl = profile['profilePicture'];

        setState(() {
          profileImageUrl = profileUrl;
        });

        // Save to cache for next time
        await prefs.setString('cachedProfilePicture', profileUrl);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            const Text("Edit Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  profileImageUrl.isNotEmpty
                      ? CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(profileImageUrl),
                        )
                      : CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          child: const Icon(Icons.person,
                              size: 50, color: Colors.black87),
                        ),
                  // Positioned(
                  //   bottom: 0,
                  //   right: 0,
                  //   child: Container(
                  //     padding: const EdgeInsets.all(6),
                  //     decoration: const BoxDecoration(
                  //       shape: BoxShape.circle,
                  //       color: Colors.black,
                  //     ),
                  //     child:
                  //         const Icon(Icons.edit, color: Colors.white, size: 16),
                  //   ),
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Name Field
            _buildTextField(nameController, "Full Name"),

            // DOB Field
            _buildDatePick(dobController, "Date of Birth"),

            // Gender Dropdown
            _buildDropdown(
                "Gender",
                gender,
                ["Male", "Female", "Non-binary", "Other"],
                (newValue) => setState(() => gender = newValue!)),

            // Location Field
            _buildLocationDropdown(),

            const SizedBox(height: 16),

            // Toggle Preferences Button
            Center(
              child: TextButton(
                onPressed: () =>
                    setState(() => showPreferences = !showPreferences),
                child: Text(
                  showPreferences ? "Hide Preferences" : "Change Preferences",
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            if (showPreferences) ...[
              const SizedBox(height: 24),

              // Interests (Chips)
              const Text("Interests",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),

              const SizedBox(
                height: 5,
              ),

              // Learning Style Dropdown
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _interests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  return FilterChip(
                    label: Text(interest),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedInterests.add(interest);
                        } else {
                          _selectedInterests.remove(interest);
                        }
                      });
                    },
                    selectedColor: const Color.fromARGB(255, 181, 102, 206),
                    checkmarkColor: Colors.white,
                    backgroundColor: const Color(0xFFF5F5F5),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              const Text("Learning Time",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),

              const SizedBox(height: 10),

              // Daily Commitment Slider
              _buildTimeCommitmentSlider()
            ],

            const SizedBox(height: 32),

            // Update Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Update Profile",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          fillColor: const Color.fromARGB(255, 219, 219, 219),
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(color: Colors.black)));
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          fillColor: const Color.fromARGB(255, 219, 219, 219),
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildLocationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country Dropdown
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Country',
            labelStyle: const TextStyle(color: Colors.black),
            fillColor: const Color.fromARGB(255, 219, 219, 219),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          value: _selectedCountry, // Ensures value is in the list
          items: countryCities.keys.map((String country) {
            return DropdownMenuItem<String>(
              value: country,
              child: Text(country, style: const TextStyle(color: Colors.black)),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              _selectedCountry = value;
              _selectedCity = null; // Reset city selection
            });
          },
        ),
        SizedBox(height: 10),

        // City Dropdown (only if a valid country is selected)
        if (_selectedCountry != null &&
            countryCities.containsKey(_selectedCountry))
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'City',
              labelStyle: const TextStyle(color: Colors.black),
              fillColor: const Color.fromARGB(255, 219, 219, 219),
              filled: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            value: _selectedCity, // Ensures value is in the list
            items: (countryCities[_selectedCountry] ?? []).map((String city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city, style: const TextStyle(color: Colors.black)),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _selectedCity = value;
              });
            },
          ),
      ],
    );
  }

  Widget _buildTimeCommitmentSlider() {
    final commitments = ['5 min', '10 min', '30 min', '1 hour', '2 hours'];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: commitments
              .map((time) => Text(
                    time,
                    style: const TextStyle(color: Color(0xFF4A4A4A)),
                  ))
              .toList(),
        ),
        Slider(
          value: _timeCommitment == null
              ? 0
              : commitments.indexOf(_timeCommitment!).toDouble(),
          min: 0,
          max: commitments.length - 1.0,
          divisions: commitments.length - 1,
          activeColor: const Color.fromARGB(255, 0, 0, 0),
          onChanged: (value) {
            setState(() {
              _timeCommitment = commitments[value.round()];
            });
          },
        ),
        Text(
          _timeCommitment ?? 'Select time',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4A4A),
          ),
        ),
      ],
    );
  }

  //build date
  Widget _buildDatePick(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        onTap: _selectDate,
        controller: controller,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          fillColor: const Color.fromARGB(255, 219, 219, 219),
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
