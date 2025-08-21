import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../constants/app_constants.dart';
import '../services/api_service.dart';
import '../utils/app_utils.dart';
import '../widgets/custom_app_bar.dart';

class BirthdayWishScreen extends StatefulWidget {
  const BirthdayWishScreen({super.key});

  @override
  State<BirthdayWishScreen> createState() => _BirthdayWishScreenState();
}

class _BirthdayWishScreenState extends State<BirthdayWishScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  DateTime? _selectedDate;
  bool _isSubmitting = false;

  File? _selectedImage; // <-- for uploaded image
  final ImagePicker _picker = ImagePicker();
  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }



  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _messageController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppConstants.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppConstants.textColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppConstants.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // ✅ Keep format consistent
        DateTime birthDate =
        DateFormat('yyyy-MM-dd').parse(_birthDateController.text);

        final success = await _apiService.submitBirthdayWish(
          name: _nameController.text,
          birthDate: birthDate,
          message: _messageController.text,
          imageFile: _selectedImage, // optional
        );

        print("Submitting birthday wish:\n"
            "Name: ${_nameController.text},\n"
            "DOB: $birthDate,\n"
            "Message: ${_messageController.text},\n"
            "Image: ${_selectedImage?.path}\n");

        if (success) {
          AppUtils.showToast('Birthday wish submitted successfully!');
          _resetForm();
        } else {
          AppUtils.showToast('Failed to submit birthday wish. Please try again.');
        }
      } catch (e) {
        AppUtils.showToast('Error: $e');
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }



  // Future<void> _submitForm() async {
  //   if (_formKey.currentState!.validate()) {
  //     setState(() {
  //       _isSubmitting = true;
  //     });
  //
  //     try {
  //       // Parse the birth date string to DateTime
  //       DateTime birthDate = DateFormat('dd-MM-yyyy').parse(_birthDateController.text);
  //
  //       final success = await _apiService.submitBirthdayWish(
  //         name: _nameController.text,
  //         birthDate: birthDate,
  //         message: _messageController.text,
  //       );
  //
  //       if (success) {
  //         AppUtils.showToast('Birthday wish submitted successfully!');
  //         _resetForm();
  //       } else {
  //         AppUtils.showToast('Failed to submit birthday wish. Please try again.');
  //       }
  //     } catch (e) {
  //       AppUtils.showToast('Error: $e');
  //     } finally {
  //       setState(() {
  //         _isSubmitting = false;
  //       });
  //     }
  //   }
  // }

  void _resetForm() {
    _nameController.clear();
    _birthDateController.clear();
    _messageController.clear();
    setState(() {
      _selectedDate = null;
      _selectedImage = null;
    });
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Birthday Wishes',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Request a Birthday Wish',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fill out the form below to request a birthday wish from us!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            _buildBirthdayWishForm(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBirthdayWishForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Birth Date Field
          TextFormField(
            controller: _birthDateController,
            decoration: const InputDecoration(
              labelText: 'Birth Date',
              hintText: 'Select your birth date',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            readOnly: true,
            onTap: () => _selectDate(context),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your birth date';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Image Upload
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Upload Image (Optional)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                      : const Center(
                    child: Icon(Icons.add_a_photo,
                        size: 40, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),


          // Message Field
          TextFormField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Message (Optional)',
              hintText: 'Enter a special message',
              prefixIcon: Icon(Icons.message),
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                ),
              ),
              child: _isSubmitting
                  ? LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.white,
                      size: 30,
                    )
                  : const Text(
                      'Submit Request',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Reset Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: _isSubmitting ? null : _resetForm,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConstants.primaryColor,
                side: const BorderSide(color: AppConstants.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                ),
              ),
              child: const Text(
                'Reset Form',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Note:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your birthday wish request will be reviewed by our team. If approved, it will be displayed on our home page on your birthday!',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}