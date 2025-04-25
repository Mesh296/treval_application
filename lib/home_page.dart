import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treval_application/services/user.dart';
import 'package:treval_application/services/reviews.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserApi _userApi = UserApi();
  List<dynamic> _recommendedLocations = [];
  List<dynamic> _filteredLocations = []; // Danh sách địa điểm sau khi lọc
  List<dynamic> _offers = [];
  Map<String, String> _locationIdToNameMap = {};
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController(); // Controller cho ô tìm kiếm

  @override
  void initState() {
    super.initState();
    _fetchRecommendedLocations();
    // Lắng nghe thay đổi trong ô tìm kiếm
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _fetchRecommendedLocations() async {
    try {
      final response = await _userApi.getRecommendedLocationsAndOffers();
      if (mounted) {
        setState(() {
          _recommendedLocations = response['locations'] ?? [];
          _filteredLocations = _recommendedLocations; // Khởi tạo danh sách lọc
          _offers = response['offers'] ?? [];
          _locationIdToNameMap = {
            for (var location in _recommendedLocations)
              location['location_id'] as String: location['name'] as String,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load recommendations: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    String query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredLocations = _recommendedLocations; // Hiển thị tất cả nếu ô tìm kiếm trống
      } else {
        _filteredLocations = _recommendedLocations.where((location) {
          String locationName = (location['name'] ?? '').toLowerCase();
          return locationName.contains(query);
        }).toList();
      }
    });
  }

  String _getImagePath(String locationName) {
    final Map<String, String> locationImageMap = {
      "Tokyo, Japan": "tokyo.jpg",
      "Florence, Italy": "florence.jpg",
      "Banff National Park, Canada": "banff_national_park.jpg",
      "Paris, France": "paris.jpg",
      "Lake Tahoe, USA": "lake_tahoe.jpg",
      "Cape Town, South Africa": "cape_town.jpg",
      "New York City, NY, USA": "newyork.jpg",
      "Great Barrier Reef, Australia": "great_barrier_reef.jpg",
      "Yellowstone National Park, USA": "yellowstone.jpg",
      "Scottish Highlands, Scotland": "scottish.jpg",
    };

    String? imageFileName = locationImageMap[locationName];
    return 'assets/images/${imageFileName ?? "mount_fuji.jpg"}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/mount_fuji.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search locations (e.g., Canada)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "For You",
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      "See All",
                      style: TextStyle(
                        color: Color(0xFF0037CF),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(child: Text(_errorMessage!))
                        : _filteredLocations.isEmpty
                            ? Center(child: Text("No locations found"))
                            : GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                children: _filteredLocations.map((location) {
                                  String locationName = location['name'] ?? 'Unknown';
                                  String imagePath = _getImagePath(locationName);
                                  return _buildRecommendationCard(location, locationName, imagePath);
                                }).toList(),
                              ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Offers",
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      "See All",
                      style: TextStyle(
                        color: Color(0xFF0037CF),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(child: Text(_errorMessage!))
                        : _offers.isEmpty
                            ? Center(child: Text("No offers available"))
                            : SizedBox(
                                height: 240,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _offers.length,
                                  itemBuilder: (context, index) {
                                    final offer = _offers[index];
                                    String offerName = offer['name'] ?? 'Unknown Offer';
                                    String description = offer['description'] ?? '';
                                    String locationId = offer['location_id'] ?? '';
                                    String locationName = _locationIdToNameMap[locationId] ?? 'Unknown Location';
                                    String imagePath = _getImagePath(locationName);
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 10.0),
                                      child: SizedBox(
                                        width: 160,
                                        child: _buildOfferCard(offerName, description, locationName, imagePath),
                                      ),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(dynamic location, String locationName, String imagePath) {
    return GestureDetector(
      onTap: () {
        List<dynamic> locationOffers = _offers.where((offer) {
          return offer['location_id'] == location['location_id'];
        }).toList();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationDetailPage(
              location: location,
              offers: locationOffers,
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(child: Text('Image not found'));
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                locationName,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(String offerName, String description, String locationName, String imagePath) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 100,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  color: Colors.grey[300],
                  child: Center(child: Text('Image not found')),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    offerName,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    locationName,
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class LocationDetailPage extends StatefulWidget {
  final dynamic location;
  final List<dynamic> offers;

  const LocationDetailPage({
    Key? key,
    required this.location,
    required this.offers,
  }) : super(key: key);

  @override
  _LocationDetailPageState createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends State<LocationDetailPage> {
  final ReviewApi _reviewApi = ReviewApi();
  final UserApi _userApi = UserApi();
  List<dynamic> _reviews = [];
  bool _isLoadingReviews = true;
  String? _reviewErrorMessage;
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  String? _currentUserId;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _fetchReviews();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final userData = await _userApi.getMe();
      if (mounted) {
        setState(() {
          _currentUserId = userData['id'];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: $e')),
        );
      }
    }
  }

  Future<void> _fetchReviews() async {
    try {
      final reviews = await _reviewApi.getReviewsByLocation(widget.location['location_id']);
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _reviewErrorMessage = 'Failed to load reviews: $e';
          _isLoadingReviews = false;
        });
      }
    }
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0 || _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a rating and enter a comment')),
      );
      return;
    }

    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _reviewApi.postReview(
        userId: _currentUserId!,
        locationId: widget.location['location_id'],
        rating: _selectedRating,
        content: _commentController.text.trim(),
      );

      setState(() {
        _selectedRating = 0;
        _commentController.clear();
      });

      await _fetchReviews();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review submitted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit review: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _deleteReview(String reviewId) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await _reviewApi.deleteReview(reviewId);
      await _fetchReviews();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete review: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  String _getImagePath(String locationName) {
    final Map<String, String> locationImageMap = {
      "Tokyo, Japan": "tokyo.jpg",
      "Florence, Italy": "florence.jpg",
      "Banff National Park, Canada": "banff_national_park.jpg",
      "Paris, France": "paris.jpg",
      "Lake Tahoe, USA": "lake_tahoe.jpg",
      "Cape Town, South Africa": "cape_town.jpg",
      "New York City, NY, USA": "newyork.jpg",
      "Great Barrier Reef, Australia": "great_barrier_reef.jpg",
      "Yellowstone National Park, USA": "yellowstone.jpg",
      "Scottish Highlands, Scotland": "scottish.jpg",
    };

    String? imageFileName = locationImageMap[locationName];
    return 'assets/images/${imageFileName ?? "mount_fuji.jpg"}';
  }

  @override
  Widget build(BuildContext context) {
    String locationName = widget.location['name'] ?? 'Unknown';
    String address = widget.location['address'] ?? 'No address available';
    double rating = (widget.location['rating'] ?? 0).toDouble();
    String imagePath = _getImagePath(locationName);

    return Scaffold(
      appBar: AppBar(
        title: Text(locationName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locationName,
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        '$rating/5',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Available Offers",
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  widget.offers.isEmpty
                      ? Text(
                          "No offers available for this location.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: widget.offers.length,
                          itemBuilder: (context, index) {
                            final offer = widget.offers[index];
                            String offerName = offer['name'] ?? 'Unknown Offer';
                            String description = offer['description'] ?? '';
                            double price = (offer['price'] ?? 0).toDouble();
                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      offerName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      description,
                                      style: TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Price: \$${price.toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 14, color: Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  SizedBox(height: 16),
                  Text(
                    "Reviews",
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  _isLoadingReviews
                      ? Center(child: CircularProgressIndicator())
                      : _reviewErrorMessage != null
                          ? Text(
                              _reviewErrorMessage!,
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            )
                          : _reviews.isEmpty
                              ? Text(
                                  "No reviews yet. Be the first to review this location!",
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _reviews.length,
                                  itemBuilder: (context, index) {
                                    final review = _reviews[index];
                                    String content = review['content'] ?? '';
                                    double reviewRating = (review['rating'] ?? 0).toDouble();
                                    String reviewId = review['comment_id'] ?? '';
                                    String reviewUserId = review['user_id'] ?? '';
                                    bool isCurrentUserReview = _currentUserId != null && reviewUserId == _currentUserId;

                                    return Card(
                                      elevation: 2,
                                      margin: EdgeInsets.symmetric(vertical: 4),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: List.generate(5, (starIndex) {
                                                      return Icon(
                                                        starIndex < reviewRating
                                                            ? Icons.star
                                                            : Icons.star_border,
                                                        size: 16,
                                                        color: Colors.amber,
                                                      );
                                                    }),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    content,
                                                    style: TextStyle(fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (isCurrentUserReview)
                                              _isDeleting
                                                  ? CircularProgressIndicator()
                                                  : IconButton(
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                        size: 20,
                                                      ),
                                                      onPressed: () {
                                                        _deleteReview(reviewId);
                                                      },
                                                    ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                  SizedBox(height: 16),
                  Text(
                    "Add Your Review",
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRating = index + 1;
                          });
                        },
                        child: Icon(
                          index < _selectedRating ? Icons.star : Icons.star_border,
                          size: 30,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Write your review here...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 8),
                  _isSubmitting
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _submitReview,
                          child: Text("Submit Review"),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}