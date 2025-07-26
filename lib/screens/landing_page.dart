import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildHeroSection(),
              _buildFeaturesSection(),
              _buildAboutSection(),
              _buildContactSection(),
              _buildFooter(),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.eco, color: Color(0xFF2E7D32), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'BioMarket TN',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                PopupMenuButton<String>(
                  icon: Icon(Icons.menu, color: Color(0xFF2E7D32)),
                  onSelected: (value) {
                    switch (value) {
                      case 'about':
                        _scrollToSection(_aboutKey);
                        break;
                      case 'contact':
                        _scrollToSection(_contactKey);
                        break;
                      case 'login':
                        Navigator.pushNamed(context, '/login');
                        break;
                      case 'signup':
                        Navigator.pushNamed(context, '/signup');
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(value: 'about', child: Text('About Us')),
                    PopupMenuItem(value: 'contact', child: Text('Contact')),
                    PopupMenuDivider(),
                    PopupMenuItem(value: 'login', child: Text('Login')),
                    PopupMenuItem(value: 'signup', child: Text('Sign Up')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E8),
              Color(0xFFF1F8E9),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '🌱 Fresh & Local',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Discover Tunisia\'s\nBest Bio Products',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
                height: 1.2,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Connect with local farmers and markets across Tunisia. Find fresh, organic products delivered right to your door.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: 30),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  icon: Icon(Icons.login, color: Color(0xFF4CAF50)),
                  label: Text(
                    'Already have an account? Login',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF66BB6A),
                        Color(0xFF4CAF50),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.agriculture,
                          size: 80,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Organic Marketplace',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'Why Choose BioMarket TN?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Connecting you with Tunisia\'s finest organic products',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 30),
          Column(
            children: [
              _buildFeatureCard(
                Icons.eco,
                'Organic & Fresh',
                'Premium quality bio products sourced directly from local farmers',
                Color(0xFF4CAF50),
              ),
              SizedBox(height: 20),
              _buildFeatureCard(
                Icons.location_on,
                'Local Markets',
                'Discover and support local markets across all regions of Tunisia',
                Color(0xFF66BB6A),
              ),
              SizedBox(height: 20),
              _buildFeatureCard(
                Icons.delivery_dining,
                'Fast Delivery',
                'Quick and reliable delivery service to your doorstep',
                Color(0xFF81C784),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              icon,
              size: 32,
              color: color,
            ),
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      key: _aboutKey,
      padding: EdgeInsets.all(24),
      color: Color(0xFFF8FDF8),
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF81C784),
                      Color(0xFF66BB6A),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.groups,
                        size: 80,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Our Community',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
          Text(
            'About Us',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'We are passionate about connecting Tunisian consumers with local farmers and organic producers. Our mission is to promote sustainable agriculture while making fresh, healthy bio products accessible to everyone.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Founded in Tunisia, we believe in supporting our local economy while providing you with the freshest, most nutritious products available.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('500+', 'Products'),
              _buildStatItem('150+', 'Farmers'),
              _buildStatItem('24/7', 'Support'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4CAF50),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Container(
      key: _contactKey,
      padding: EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'Get in Touch',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'We\'d love to hear from you. Send us a message and we\'ll respond as soon as possible.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 30),
          Column(
            children: [
              _buildContactInfo(
                Icons.location_on,
                'Address',
                'Tunis, Tunisia\nAvenue Habib Bourguiba',
              ),
              SizedBox(height: 24),
              _buildContactInfo(
                Icons.phone,
                'Phone',
                '+216 XX XXX XXX',
              ),
              SizedBox(height: 24),
              _buildContactInfo(
                Icons.email,
                'Email',
                'info@biomarket-tn.com',
              ),
            ],
          ),
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFFF8FDF8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Your Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFF4CAF50)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Your Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFF4CAF50)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Your Message',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFF4CAF50)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Send Message',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String title, String info) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            icon,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              SizedBox(height: 4),
              Text(
                info,
                style: TextStyle(
                  color: Colors.grey[600],
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(24),
      color: Color(0xFF1B5E20),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.eco, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'BioMarket TN',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Connecting Tunisia with fresh, organic, and local products.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.facebook, color: Colors.white, size: 28),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.telegram, color: Colors.white, size: 28),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.alternate_email, color: Colors.white, size: 28),
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(color: Colors.white30),
          SizedBox(height: 12),
          Text(
            '© 2025 BioMarket TN. All rights reserved.\nMade with 💚 in Tunisia',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}