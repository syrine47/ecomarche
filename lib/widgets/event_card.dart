import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const EventCard({
    Key? key,
    required this.event,
    this.onEdit,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'marché bio':
        return Colors.green;
      case 'dégustation':
        return Colors.orange;
      case 'atelier cuisine':
        return Colors.purple;
      case 'conférence':
        return Colors.blue;
      case 'festival':
        return Colors.red;
      case 'vente directe':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'marché bio':
        return Icons.store;
      case 'dégustation':
        return Icons.restaurant;
      case 'atelier cuisine':
        return Icons.kitchen;
      case 'conférence':
        return Icons.school;
      case 'festival':
        return Icons.celebration;
      case 'vente directe':
        return Icons.shopping_bag;
      default:
        return Icons.event;
    }
  }

  bool _isEventPassed() {
    return event.date.isBefore(DateTime.now());
  }

  String _getTimeUntilEvent() {
    final now = DateTime.now();
    final difference = event.date.difference(now);
    
    if (difference.isNegative) {
      return 'Terminé';
    } else if (difference.inDays > 0) {
      return 'Dans ${difference.inDays} jour(s)';
    } else if (difference.inHours > 0) {
      return 'Dans ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'Dans ${difference.inMinutes}min';
    } else {
      return 'Maintenant';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPassed = _isEventPassed();
    final categoryColor = _getCategoryColor(event.category);
    final categoryIcon = _getCategoryIcon(event.category);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec image ou placeholder
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: Colors.grey[200],
              ),
              child: Stack(
                children: [
                  // Image de l'événement
                  if (event.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        event.imageUrl,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage(categoryColor, categoryIcon);
                        },
                      ),
                    )
                  else
                    _buildPlaceholderImage(categoryColor, categoryIcon),
                  
                  // Overlay gradient
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                  
                  // Badge de catégorie
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(categoryIcon, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            event.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Actions (Edit/Delete)
                  if (onEdit != null || onDelete != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (onEdit != null)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                                onPressed: onEdit,
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          if (onEdit != null && onDelete != null) const SizedBox(width: 4),
                          if (onDelete != null)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                                onPressed: onDelete,
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                        ],
                      ),
                    ),
                  
                  // Statut de l'événement
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPassed ? Colors.grey : Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getTimeUntilEvent(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isPassed ? Colors.grey[600] : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isPassed ? Colors.grey[500] : Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // Informations date/lieu
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: isPassed ? Colors.grey[400] : Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd/MM/yyyy à HH:mm').format(event.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: isPassed ? Colors.grey[500] : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: isPassed ? Colors.grey[400] : Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: isPassed ? Colors.grey[500] : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  // Tags
                  if (event.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: event.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPassed ? Colors.grey[200] : Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isPassed ? Colors.grey[300]! : Colors.green[200]!,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              color: isPassed ? Colors.grey[600] : Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  
                  // Organisateur
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 14,
                        color: isPassed ? Colors.grey[400] : Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Par ${event.organizerName}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isPassed ? Colors.grey[400] : Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(Color categoryColor, IconData categoryIcon) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            categoryColor.withOpacity(0.3),
            categoryColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Icon(
        categoryIcon,
        size: 48,
        color: categoryColor.withOpacity(0.7),
      ),
    );
  }
}