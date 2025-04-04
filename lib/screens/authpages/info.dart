import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_own_project/auth-service/auth.dart';
import 'package:our_own_project/screens/authpages/moreinfo.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    String username = await getUsername();
    setState(() {
      _nameController.text = username;
    });
  }

  Future<String> getUsername() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>?; // Ensure it's a map
        var profile =
            data?['profile'] as Map<String, dynamic>?; // Profile extraction

        if (profile != null && profile.containsKey('fullName')) {
          return profile['fullName'];
        }
      }
    }

    return 'User Name';
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  Color backcolor = const Color.fromARGB(255, 199, 139, 220);
  Color textcolor = const Color.fromARGB(255, 102, 102, 102);
  String? _selectedGender;
  String? _selectedCountry;
  String? _selectedCity;
  Map<String, List<String>> countryCities = {
    'United States': ['New York', 'Los Angeles', 'Chicago', 'San Francisco'],
    'Canada': ['Toronto', 'Vancouver', 'Montreal'],
    'United Kingdom': ['London', 'Manchester', 'Birmingham'],
    'Australia': ['Sydney', 'Melbourne', 'Brisbane'],
    'India': ['Mumbai', 'Bangalore', 'Delhi', 'Kochi'],
    'Other': []
  };

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
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // Profile Image Setting
  String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
  String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET']!;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  late String profileImageUrl = '';

  // Function to Pick Image
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });

        // Upload to Cloudinary
        //show loading dialog and pop off the bottom sheet
        showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        await uploadProfilePicture(_image!);
        _loadProfilePicture();
        Navigator.pop(context); // Close loading dialog
      }

      Navigator.pop(context); // Close bottom sheet after selecting
    } catch (e) {
      //show dialog about the error
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('An error occurred: $e'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'))
              ],
            );
          });
    } // Close bottom sheet after selecting
  }

  // Your function to upload/set profile picture
  Future<void> uploadProfilePicture(File image) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Convert image to bytes & encode it
      List<int> imageBytes = await image.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // Upload to Cloudinary
      var response = await http.post(
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload"),
        body: {
          "file": "data:image/png;base64,$base64Image",
          "upload_preset": uploadPreset,
          "folder": "profile_pictures"
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String imageUrl = data["secure_url"];

        // Save URL in Firestore inside 'profile'
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'profile.profilePicture': imageUrl,
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Profile Picture set!'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error Uploading Picture :$e'),
      ));
    }
  }

  // Function to show bottom sheet with options
  void _showImagePicker() {
    showModalBottomSheet(
      backgroundColor: const Color.fromARGB(230, 186, 130, 206),
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Choose from Gallery"),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text("Take a Photo"),
              onTap: () => _pickImage(ImageSource.camera),
            ),
          ],
        );
      },
    );
  }

  //load picture
  Future<void> _loadProfilePicture() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      var data = userDoc.data() as Map<String, dynamic>?;
      var profile = data?['profile'] as Map<String, dynamic>?;

      if (profile != null && profile.containsKey('profilePicture')) {
        setState(() {
          profileImageUrl = profile['profilePicture'];
        });
      }
    }
  }

  // Profile completion function placeholder
  Auth auth = Auth();
  void _completeProfile() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Name can't be empty"),
      ));
      return;
    } else if (_dobController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Plase Select Valid Date of Birth"),
      ));
      return;
    } else if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Select a Gender'),
      ));
      return;
    } else if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Select a Country'),
      ));
      return;
    }else if (_selectedCity== null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Select a City'),
      ));
      return;
    }
    try {
      auth.saveUserInfo(
        FirebaseAuth.instance.currentUser!.uid,
        {
          'fullName': _nameController.text,
          'dob': _dobController.text,
          'gender': _selectedGender,
          'location': {
            "country": _selectedCountry,
            "city": _selectedCity
          }
        },
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LearningPreferencesScreen(),
        ),
      );
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text(
                  "Error Saving Profile",
                  style: TextStyle(color: Color.fromARGB(255, 191, 177, 206)),
                ),
                content: Text(e.toString()),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"))
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backcolor,
      appBar: AppBar(
        backgroundColor: backcolor,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 15, top: 20),
          child: Icon(
            Icons.lock_outline,
            size: 30,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Info',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Don\'t worry, only you can see your personal\ndata. No one else will be able to see it.',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 45, 45, 45),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                    ),
                    child: profileImageUrl.isNotEmpty
                        ? CircleAvatar(
                            radius: 80,
                            backgroundImage: NetworkImage(profileImageUrl),
                          )
                        : CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.grey[200],
                            child: const Icon(Icons.person,
                                size: 80, color: Colors.black87),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImagePicker,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 122, 53, 161),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildInputField('Full Name', _nameController, 'User Name'),
            _buildInputField('Date of Birth', _dobController, 'DD / MM / YYYY',
                onTap: _selectDate, readOnly: true),
            _buildDropdownField('Gender', _selectedGender, [
              'Male',
              'Female',
              'Other',
              'Prefer not to say'
            ], (String? value) {
              setState(() => _selectedGender = value);
            }),
            _buildLocationDropdown(),
            const Center(
              child: Icon(
                Icons.arrow_drop_down,
                size: 35,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _completeProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 116, 75, 128),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Complete Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
      String label, TextEditingController controller, String hint,
      {VoidCallback? onTap, bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: textcolor),
            fillColor: const Color(0xFFF5F5F5),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(color: textcolor),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(
                'Select',
                style: TextStyle(color: textcolor),
              ),
              value: value,
              items: items
                  .map((String item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: TextStyle(color: textcolor),
                        ),
                      ))
                  .toList(),
              onChanged: onChanged,
              borderRadius: BorderRadius.circular(15),
              dropdownColor: const Color.fromARGB(255, 244, 210, 255),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLocationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownField(
            'Country', _selectedCountry, countryCities.keys.toList(),
            (String? value) {
          setState(() {
            _selectedCountry = value;
            _selectedCity = null; // Reset city when country changes
          });
        }),
        if (_selectedCountry != null &&
            countryCities[_selectedCountry!]!.isNotEmpty)
          _buildDropdownField(
              'City', _selectedCity, countryCities[_selectedCountry!]!,
              (String? value) {
            setState(() => _selectedCity = value);
          }),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
