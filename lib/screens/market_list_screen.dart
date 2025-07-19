import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/market_provider.dart';
import '../models/market.dart';
import '../widgets/eco_marche_drawer.dart';

class MarketListScreen extends StatefulWidget {
  const MarketListScreen({super.key});

  @override
  State<MarketListScreen> createState() => _MarketListScreenState();
}

class _MarketListScreenState extends State<MarketListScreen>
    with TickerProviderStateMixin {
  bool _isInit = true;
  bool _isLoading = false;
  String _searchQuery = '';
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isLoading = true;
      Provider.of<MarketProvider>(context).fetchMarkets().then((_) {
        setState(() {
          _isLoading = false;
        });
        _fadeController.forward();
        _slideController.forward();
      });
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  List<Market> _getFilteredMarkets(List<Market> markets) {
    if (_searchQuery.isEmpty) return markets;

    return markets.where((market) {
      return market.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (market.cityName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          market.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _openGoogleMaps(double latitude, double longitude, String marketName) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    final Uri uri = Uri.parse(googleMapsUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Impossible d\'ouvrir Google Maps'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ouverture de Google Maps: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context);
    final allMarkets = marketProvider.markets;
    final filteredMarkets = _getFilteredMarkets(allMarkets);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        title: const Text(
          "Marchés Bio Locaux",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2E7D32),
                const Color(0xFF388E3C),
                const Color(0xFF4CAF50),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/market-form');
              },
            ),
          ),
        ],
      ),
      drawer: const EcoMarcheDrawer(),
      body: Column(
        children: [
          // Search Bar avec design moderne
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2E7D32),
                  const Color(0xFF388E3C),
                  const Color(0xFF4CAF50),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher un marché, une ville...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.search_rounded,
                      color: const Color(0xFF4CAF50),
                      size: 22,
                    ),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
          ),

          // Statistiques avec design amélioré
          if (!_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${filteredMarkets.length} marché${filteredMarkets.length > 1 ? 's' : ''} trouvé${filteredMarkets.length > 1 ? 's' : ''}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "\"$_searchQuery\"",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Contenu principal
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : filteredMarkets.isEmpty
                    ? _buildEmptyState()
                    : _buildMarketList(filteredMarkets),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF4CAF50)),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            "Chargement des marchés...",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty 
                ? "Aucun marché disponible" 
                : "Aucun marché trouvé",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty 
                ? "Les marchés apparaîtront ici une fois ajoutés" 
                : "Essayez avec d'autres mots-clés",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketList(List<Market> markets) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: markets.length,
          itemBuilder: (context, index) {
            return _buildMarketCard(markets[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildMarketCard(Market market, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image avec placeholder amélioré
          _buildMarketImage(market),
          
          // Contenu de la carte
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom du marché
                Text(
                  market.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Informations avec icônes
                _buildInfoRow(
                  Icons.location_on_rounded,
                  market.cityName ?? "Ville inconnue",
                  Colors.red.shade400,
                ),
                const SizedBox(height: 8),
                
                _buildInfoRow(
                  Icons.description_rounded,
                  market.description,
                  Colors.blue.shade400,
                ),
                const SizedBox(height: 20),
                
                // Bouton Maps moderne
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openGoogleMaps(
                      market.latitude,
                      market.longitude,
                      market.name,
                    ),
                    icon: const Icon(
                      Icons.map_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Voir sur Google Maps",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
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

  Widget _buildMarketImage(Market market) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.1),
            const Color(0xFF81C784).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: market.image != null && market.image!.isNotEmpty
            ? Image.network(
                market.image!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildImagePlaceholder(isLoading: true);
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder(isError: true);
                },
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder({bool isLoading = false, bool isError = false}) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.1),
            const Color(0xFF81C784).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF4CAF50)),
                strokeWidth: 3,
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isError ? Icons.error_outline_rounded : Icons.storefront_rounded,
                  size: 48,
                  color: isError ? Colors.red.shade400 : const Color(0xFF4CAF50),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              isLoading 
                  ? "Chargement..." 
                  : isError 
                      ? "Image non disponible" 
                      : "Marché Bio",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF424242),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}