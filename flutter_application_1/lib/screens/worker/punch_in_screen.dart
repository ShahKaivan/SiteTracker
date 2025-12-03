import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/sites_service.dart';
import '../../utils/constants.dart';
import '../../utils/date_time_utils.dart';

// Punch in screen
class PunchInScreen extends StatefulWidget {
  const PunchInScreen({super.key});

  @override
  State<PunchInScreen> createState() => _PunchInScreenState();
}

class _PunchInScreenState extends State<PunchInScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  File? _capturedImage;
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _isUploading = false;
  String? _errorMessage;
  String? _siteId;
  List<Map<String, dynamic>> _assignedSites = [];
  bool _isLoadingSites = false;
  final SitesService _sitesService = SitesService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _getCurrentLocation();
    _loadAssignedSites();
  }

  Future<void> _loadAssignedSites() async {
    setState(() {
      _isLoadingSites = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      final userRole = authProvider.user?.role;

      if (token == null) return;

      // Skip loading sites for admin users
      if (userRole == 'admin') {
        setState(() {
          _assignedSites = [];
          _siteId = 'admin-no-site'; // Special ID for admin
          _isLoadingSites = false;
        });
        return;
      }

      final result = await _sitesService.getMySites(token: token);

      if (result['success'] == true) {
        final sitesData = result['data']['sites'] as List<dynamic>;
        final fetchedSites = sitesData.map((site) => {
          'id': site['id'] as String,
          'name': site['name'] as String,
          'code': site['code'] as String? ?? '',
        }).toList();

        setState(() {
          _assignedSites = fetchedSites;
          // If user has only one site, auto-select it
          if (_assignedSites.length == 1) {
            _siteId = _assignedSites.first['id'];
          }
          _isLoadingSites = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load sites: $e';
        _isLoadingSites = false;
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        setState(() {
          _errorMessage = 'Camera permission is required to take a selfie';
        });
        return;
      }

      // Get available cameras
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available';
        });
        return;
      }

      // Use front camera for selfie
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      // Request location permission
      final locationStatus = await Permission.location.request();
      if (!locationStatus.isGranted) {
        setState(() {
          _errorMessage = 'Location permission is required';
          _isLoadingLocation = false;
        });
        return;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled. Please enable them.';
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: $e';
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _captureSelfie() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final image = await _cameraController!.takePicture();
      
      // Use application documents directory instead of temporary directory
      // This prevents Android from deleting the file before upload
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'punch_in_$timestamp.jpg';
      final filePath = path.join(directory.path, fileName);
      
      // Copy image to application documents directory
      final savedImage = await File(image.path).copy(filePath);
      
      setState(() {
        _capturedImage = savedImage;
        _isCapturing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to capture image: $e';
        _isCapturing = false;
      });
    }
  }

  Future<void> _retakePhoto() async {
    setState(() {
      _capturedImage = null;
    });
  }

  Future<void> _submitPunchIn() async {
    if (_capturedImage == null) {
      setState(() {
        _errorMessage = 'Please capture a selfie first';
      });
      return;
    }

    if (_currentPosition == null) {
      setState(() {
        _errorMessage = 'Location not available. Please try again.';
      });
      await _getCurrentLocation();
      return;
    }

    // Check if site ID is required (skip for admin)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    final userRole = authProvider.user?.role;
    
    if (userRole != 'admin' && (_siteId == null || _siteId!.isEmpty)) {
      setState(() {
        _errorMessage = 'Site ID is required';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    final userId = authProvider.user?.id;
    final token = authProvider.token;

    if (userId == null || token == null) {
      setState(() {
        _errorMessage = 'Authentication required. Please login again.';
        _isUploading = false;
      });
      return;
    }

    final success = await attendanceProvider.punchIn(
      userId: userId,
      siteId: userRole == 'admin' ? null : _siteId!,  // null for admin, actual siteId for others
      selfieFile: _capturedImage!,
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      token: token,
    );

    setState(() {
      _isUploading = false;
    });

    if (success && mounted) {
      // Navigate to success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => _PunchInSuccessScreen(
            attendanceData: attendanceProvider.lastPunchInData,
            latitude: _currentPosition!.latitude,
            longitude: _currentPosition!.longitude,
          ),
        ),
      );
    } else if (mounted) {
      setState(() {
        _errorMessage = attendanceProvider.errorMessage ?? 'Failed to punch in';
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Punch In'),
        leading: _isUploading
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: _isUploading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Uploading punch in data...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            color: Colors.red.shade700,
                            onPressed: () {
                              setState(() {
                                _errorMessage = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  // Camera Preview or Captured Image
                  if (_capturedImage == null)
                    _buildCameraPreview()
                  else
                    _buildCapturedImage(),
                  const SizedBox(height: 24),
                  // Site Selection
                  _buildSiteSelection(),
                  const SizedBox(height: 24),
                  // Location Info
                  _buildLocationInfo(),
                  const SizedBox(height: 24),
                  // Action Buttons
                  if (_capturedImage == null)
                    ElevatedButton.icon(
                      onPressed: _isCameraInitialized && !_isCapturing
                          ? _captureSelfie
                          : null,
                      icon: _isCapturing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.camera_alt),
                      label: Text(_isCapturing ? 'Capturing...' : 'Capture Selfie'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    )
                  else
                    Column(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _retakePhoto,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retake Photo'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _currentPosition != null ? _submitPunchIn : null,
                          icon: const Icon(Icons.check),
                          label: const Text('Submit Punch In'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Initializing camera...',
                style: const TextStyle(color: Colors.white),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _initializeCamera,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          SizedBox(
            height: 400,
            child: CameraPreview(_cameraController!),
          ),
          // Overlay guide
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // Instruction text
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Position your face in the frame',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapturedImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Image.file(
            _capturedImage!,
            height: 400,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          // Success overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                border: Border.all(
                  color: Colors.green,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // Checkmark
          const Positioned(
            top: 16,
            right: 16,
            child: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: _currentPosition != null ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Location',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_isLoadingLocation)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _getCurrentLocation,
                    tooltip: 'Refresh Location',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_currentPosition != null) ...[
              _buildInfoRow('Latitude', _currentPosition!.latitude.toStringAsFixed(6)),
              const SizedBox(height: 8),
              _buildInfoRow('Longitude', _currentPosition!.longitude.toStringAsFixed(6)),
            ] else ...[
              Text(
                _errorMessage?.contains('Location') == true
                    ? _errorMessage!
                    : 'Location not available',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSiteSelection() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.user?.role;

    // Skip site selection for admin users
    if (userRole == 'admin') {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.admin_panel_settings, color: Colors.blue),
          title: const Text('Admin Punch In'),
          subtitle: const Text('No site assignment required'),
          trailing: const Icon(Icons.check_circle, color: Colors.green),
        ),
      );
    }

    if (_isLoadingSites) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_assignedSites.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No sites assigned. Please contact admin.',
                style: TextStyle(color: Colors.orange.shade700),
              ),
            ),
          ],
        ),
      );
    }

    // If only one site, show it as read-only info
    if (_assignedSites.length == 1) {
      final site = _assignedSites.first;
      return Card(
        child: ListTile(
          leading: const Icon(Icons.business, color: Colors.blue),
          title: const Text('Site'),
          subtitle: Text(site['name']),
          trailing: const Icon(Icons.check_circle, color: Colors.green),
        ),
      );
    }

    // Dropdown for multiple sites
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DropdownButtonFormField<String>(
          value: _siteId,
          decoration: const InputDecoration(
            labelText: 'Select Site',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.business),
          ),
          hint: const Text('Choose current site'),
          items: _assignedSites.map((site) {
            return DropdownMenuItem<String>(
              value: site['id'],
              child: Text(
                site['name'],
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _siteId = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// Success Screen
class _PunchInSuccessScreen extends StatelessWidget {
  final Map<String, dynamic>? attendanceData;
  final double latitude;
  final double longitude;

  const _PunchInSuccessScreen({
    required this.attendanceData,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    // Parse UTC time from server and convert to IST
    final punchInTimeUtc = attendanceData?['attendance']?['punch_in_time'] != null
        ? DateTime.parse(attendanceData!['attendance']['punch_in_time'])
        : DateTime.now();
    final punchInTime = DateTimeUtils.convertUtcToIst(punchInTimeUtc);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Punch In Successful'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Punch In Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSuccessRow(
                        'Time',
                        '${punchInTime.hour.toString().padLeft(2, '0')}:${punchInTime.minute.toString().padLeft(2, '0')}',
                        Icons.access_time,
                      ),
                      const Divider(),
                      _buildSuccessRow(
                        'Date',
                        '${punchInTime.day}/${punchInTime.month}/${punchInTime.year}',
                        Icons.calendar_today,
                      ),
                      const Divider(),
                      _buildSuccessRow(
                        'Location',
                        '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                        Icons.location_on,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
