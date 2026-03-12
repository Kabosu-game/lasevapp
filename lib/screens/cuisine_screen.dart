import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/cuisine_service.dart';
import '../widgets/video_background.dart';

class CuisineScreen extends StatefulWidget {
  const CuisineScreen({super.key});

  @override
  State<CuisineScreen> createState() => _CuisineScreenState();
}

class _CuisineScreenState extends State<CuisineScreen> {
  static const Color primaryColor = Color(0xFF265533);
  final CuisineService _cuisineService = CuisineService();
  List<Dish> _dishes = [];
  List<Chef> _chefs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dishes = await _cuisineService.getDishes();
      final chefs = await _cuisineService.getChefs();
      if (mounted) {
        setState(() {
          _dishes = dishes;
          _chefs = chefs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VideoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Cuisine'),
          backgroundColor: primaryColor.withOpacity(0.8),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _loadData,
              tooltip: 'Actualiser',
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
          ),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: primaryColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: AnimationLimiter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_error != null) ...[
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          // Section Plats avec animation d'entrée
                          AnimationConfiguration.staggeredList(
                            position: 0,
                            duration: const Duration(milliseconds: 450),
                            delay: const Duration(milliseconds: 100),
                            child: SlideAnimation(
                              verticalOffset: -50.0,
                              child: FadeInAnimation(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nos plats',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    if (_dishes.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 24),
                                        child: Center(
                                          child: Text(
                                            'Aucun plat pour le moment.',
                                            style: TextStyle(color: Colors.grey.shade600),
                                          ),
                                        ),
                                      )
                                    else
                                      GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 0.72,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: _dishes.length,
                                itemBuilder: (context, index) {
                                  final dish = _dishes[index];
                                  return AnimationConfiguration.staggeredGrid(
                                    position: index,
                                    duration: const Duration(milliseconds: 400),
                                    delay: const Duration(milliseconds: 80),
                                    columnCount: 3,
                                    child: ScaleAnimation(
                                      child: _buildDishCard(dish),
                                    ),
                                  );
                                },
                              ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Section Chefs
                        Text(
                          'Nos chefs cuisiniers',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_chefs.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'Aucun chef pour le moment.',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _chefs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final chef = _chefs[index];
                              return _buildChefCard(chef);
                            },
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                  ),
        ),
      ),
    );
  }

  Widget _buildDishCard(Dish dish) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        border: Border.all(color: primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: dish.imageUrl != null && dish.imageUrl!.isNotEmpty
                  ? Image.network(
                      dish.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: primaryColor.withOpacity(0.1),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => _placeholderImage(),
                    )
                  : _placeholderImage(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              dish.name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: primaryColor.withOpacity(0.15),
      child: Icon(
        Icons.restaurant,
        size: 28,
        color: primaryColor.withOpacity(0.5),
      ),
    );
  }

  Widget _buildChefCard(Chef chef) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: chef.imageUrl != null && chef.imageUrl!.isNotEmpty
                ? Image.network(
                    chef.imageUrl!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _chefPlaceholder(),
                  )
                : _chefPlaceholder(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chef.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                if (chef.role != null && chef.role!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    chef.role!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chefPlaceholder() {
    return Container(
      width: 72,
      height: 72,
      color: primaryColor.withOpacity(0.15),
      child: Icon(
        Icons.person,
        size: 36,
        color: primaryColor.withOpacity(0.5),
      ),
    );
  }
}
