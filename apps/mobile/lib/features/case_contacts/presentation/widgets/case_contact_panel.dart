import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/international_phone_field.dart';
import '../../../../core/presentation/widgets/case_public_cards.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/glass_navigation_button.dart';
import '../../../../core/presentation/widgets/glass_surface.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/shake_field.dart';
import '../../domain/entities/case_contact.dart';
import '../state/case_contact_state.dart';
import '../view_models/case_contact_view_model.dart';

class CaseContactPanel extends ConsumerWidget {
  const CaseContactPanel({required this.target, super.key});
  final CaseContactTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(caseContactViewModelProvider(target));
    final model = ref.read(caseContactViewModelProvider(target).notifier);
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: LoadingShimmer(
          isLoading: true,
          isAction: false,
          loadingLabel: 'Consultando contacto',
          child: ColoredBox(
            color: Color(0xFFDCE1E7),
            child: SizedBox(height: 68),
          ),
        ),
      );
    }
    if (state.hasError) {
      return ConfirmationToastHost(
        confirmed: true,
        isError: true,
        noticeId: state.error,
        message: 'No pudimos consultar el contacto del reportante.',
        child: TextButton(
          onPressed: model.retry,
          child: const Text('Reintentar contacto'),
        ),
      );
    }
    final v = state.requireValue;
    final contact = v.access.contact;
    if (contact == null && !v.access.canEdit && v.issue == null) {
      return const SizedBox.shrink();
    }
    return ConfirmationToastHost(
      confirmed: v.issue != null || v.confirmed,
      noticeId: (v.owner, v.notice),
      isError: !v.confirmed,
      message: v.confirmed
          ? (contact == null
                ? 'Contacto retirado de la ficha'
                : 'Contacto compartido')
          : switch (v.issue) {
              CaseContactFailureKind.invalid =>
                'Indica un nombre de 2 a 80 caracteres y un teléfono con código de país, por ejemplo +51.',
              CaseContactFailureKind.conflict =>
                'El contacto cambió. Consulta de nuevo antes de continuar.',
              CaseContactFailureKind.forbidden =>
                'Ya no puedes modificar este contacto.',
              _ => 'No pudimos completar la operación. Reintenta.',
            },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: CasePublicGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (contact != null)
                _ContactRow(
                  contact: contact,
                  busy: v.busy,
                  onMessage: () => model.open(message: true),
                  onCall: () => model.open(message: false),
                ),
              if (v.access.canEdit)
                _ContactEditor(
                  key: ValueKey((v.owner, v.access.version)),
                  value: v,
                  onSave: model.save,
                  onReload: model.retry,
                ),
              if (!v.access.canEdit && v.issue != null)
                TextButton(
                  onPressed: model.retry,
                  child: const Text('Consultar contacto'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.contact,
    required this.busy,
    required this.onMessage,
    required this.onCall,
  });
  final CaseContact contact;
  final bool busy;
  final VoidCallback onMessage, onCall;

  @override
  Widget build(BuildContext context) {
    final avatar = ClipOval(
      child: SizedBox.square(
        dimension: 44,
        child: contact.avatarUri == null
            ? _initials()
            : Image.network(
                contact.avatarUri.toString(),
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) => _initials(),
              ),
      ),
    );
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          contact.phone,
          style: const TextStyle(fontSize: 13, color: Color(0xFF626975)),
        ),
        const SizedBox(height: 3),
        Text(
          contact.name,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassNavigationButton(
          tooltip: 'Enviar SMS al reportante',
          finish: GlassSurfaceFinish.frosted,
          iconSize: 22,
          foregroundColor: const Color(0xFF2887EF),
          icon: Icons.chat_bubble_outline_rounded,
          onPressed: busy ? null : onMessage,
        ),
        const SizedBox(width: 4),
        GlassNavigationButton(
          tooltip: 'Llamar al reportante',
          finish: GlassSurfaceFinish.frosted,
          iconSize: 22,
          foregroundColor: const Color(0xFF2887EF),
          icon: Icons.phone_outlined,
          onPressed: busy ? null : onCall,
        ),
      ],
    );
    final small =
        MediaQuery.textScalerOf(context).scale(16) > 22 ||
        MediaQuery.sizeOf(context).width < 360;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            avatar,
            const SizedBox(width: 10),
            Expanded(child: text),
            if (!small) ...[const SizedBox(width: 6), actions],
          ],
        ),
        if (small) Align(alignment: Alignment.centerRight, child: actions),
      ],
    );
  }

  Widget _initials() => ColoredBox(
    color: const Color(0xFFD8E4F0),
    child: Center(
      child: Text(
        contact.name.characters.first,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );
}

class _ContactEditor extends StatefulWidget {
  const _ContactEditor({
    required this.value,
    required this.onSave,
    required this.onReload,
    super.key,
  });
  final CaseContactState value;
  final ValueChanged<CaseContactDraft> onSave;
  final VoidCallback onReload;
  @override
  State<_ContactEditor> createState() => _ContactEditorState();
}

class _ContactEditorState extends State<_ContactEditor> {
  bool _editing = false;
  late bool _enabled = widget.value.access.contact != null;
  late bool _photo = widget.value.access.contact?.sharePhoto ?? false;
  late final _name = TextEditingController(
    text:
        widget.value.access.contact?.name ?? widget.value.access.suggestedName,
  );
  late final _phone = TextEditingController(
    text:
        widget.value.access.contact?.phone ??
        widget.value.access.suggestedPhone,
  );
  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.value;
    final locked = v.busy || v.pending != null;
    if (!_editing) {
      return TextButton.icon(
        onPressed: v.busy ? null : () => setState(() => _editing = true),
        icon: const Icon(Icons.contact_phone_outlined),
        label: Text(
          v.access.contact == null
              ? 'Compartir mi contacto'
              : 'Editar mi contacto',
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Compartir contacto en esta ficha'),
          value: _enabled,
          onChanged: locked
              ? null
              : (value) => setState(() => _enabled = value),
        ),
        const Text(
          'Tu nombre y teléfono serán visibles para las personas que consulten este caso en la app. Puedes retirarlos desde aquí. La foto de perfil solo se comparte si la autorizas.',
          style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF626975)),
        ),
        if (_enabled) ...[
          const SizedBox(height: 12),
          ShakeField(
            errorId: v.notice,
            hasError: v.issue == CaseContactFailureKind.invalid,
            child: AppTextField(
              label: 'Nombre público',
              controller: _name,
              enabled: !locked,
              invalid: v.issue == CaseContactFailureKind.invalid,
            ),
          ),
          const SizedBox(height: 12),
          ShakeField(
            errorId: v.notice,
            hasError: v.issue == CaseContactFailureKind.invalid,
            child: InternationalPhoneField(
              label: 'Teléfono de contacto',
              controller: _phone,
              enabled: !locked,
              invalid: v.issue == CaseContactFailureKind.invalid,
            ),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Compartir mi foto de perfil'),
            value: _photo,
            onChanged: locked
                ? null
                : (value) => setState(() => _photo = value),
          ),
        ],
        const SizedBox(height: 12),
        if (v.issue == CaseContactFailureKind.conflict ||
            v.issue == CaseContactFailureKind.forbidden)
          TextButton(
            onPressed: widget.onReload,
            child: const Text('Consultar contacto'),
          )
        else
          LoadingShimmer(
            isLoading: v.busy,
            loadingLabel: 'Guardando contacto',
            child: FilledButton(
              onPressed: v.busy
                  ? null
                  : () => widget.onSave(
                      CaseContactDraft(
                        enabled: _enabled,
                        name: _name.text,
                        phone: _phone.text,
                        sharePhoto: _photo,
                        version: v.access.version,
                      ),
                    ),
              child: Text(
                v.pending != null ? 'Reintentar guardado' : 'Guardar contacto',
              ),
            ),
          ),
        if (!locked)
          TextButton(
            onPressed: () => setState(() => _editing = false),
            child: const Text('Cancelar'),
          ),
      ],
    );
  }
}
