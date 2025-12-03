import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import '../search/property_search_screen.dart';

class MainNavigation extends StatefulWidget {
  final bool guestMode;
  
  const MainNavigation({super.key, this.guestMode = false});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PropertySearchScreen(),
    const FavoritesScreen(),
    const MessagesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              blurRadius: 25,
              offset: const Offset(0, -8),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              // Vérifier si mode invité et si l'action nécessite une connexion
              if (widget.guestMode && _requiresAuth(index)) {
                _showLoginRequiredDialog(index);
                return;
              }
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey[400],
            selectedFontSize: 12,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.home_outlined, 0),
                activeIcon: _buildNavIcon(Icons.home, 0, isActive: true),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.search_outlined, 1),
                activeIcon: _buildNavIcon(Icons.search, 1, isActive: true),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.favorite_border, 2),
                activeIcon: _buildNavIcon(Icons.favorite, 2, isActive: true),
                label: 'Favorites',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.message_outlined, 3),
                activeIcon: _buildNavIcon(Icons.message, 3, isActive: true),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.person_outline, 4),
                activeIcon: _buildNavIcon(Icons.person, 4, isActive: true),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, {bool isActive = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isActive ? 8 : 0),
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 24),
    );
  }

  // Vérifier si une fonctionnalité nécessite une authentification
  bool _requiresAuth(int index) {
    // Index 0 = Home (accessible), 1 = Search (accessible)
    // Index 2 = Favorites (nécessite login)
    // Index 3 = Messages (nécessite login)
    // Index 4 = Profile (nécessite login)
    return index >= 2;
  }

  // Afficher dialogue demandant de se connecter
  void _showLoginRequiredDialog(int index) {
    String feature = '';
    IconData icon = Icons.info_outline;
    
    switch (index) {
      case 2:
        feature = 'Favorites';
        icon = Icons.favorite;
        break;
      case 3:
        feature = 'Messages';
        icon = Icons.message;
        break;
      case 4:
        feature = 'Profile';
        icon = Icons.person;
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF6366F1)),
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Text('Login Required'),
            ),
          ],
        ),
        content: Text(
          'You need to sign in to access $feature. Create a free account or sign in to continue.',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Exploring'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}
