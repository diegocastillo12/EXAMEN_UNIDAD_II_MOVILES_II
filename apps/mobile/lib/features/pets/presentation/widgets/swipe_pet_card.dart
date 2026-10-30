import '../../../../core/presentation/widgets/swipe_action_card.dart';

class SwipePetCard extends SwipeActionCard {
  const SwipePetCard({
    required super.contentBuilder,
    required super.onOpen,
    required super.onDelete,
    super.busy,
    super.disabled,
    super.key,
  }) : super(loadingLabel: 'Eliminando mascota');
}
