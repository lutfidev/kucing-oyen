import 'package:flutter/widgets.dart';

import '../../app/game_audio.dart';
import '../../app/language.dart';
import '../../l10n/l10n.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../level/level_sheet.dart';

/// Bar atas Pengaturan: tombol kembali dan judul, seperti bar Lemari
/// Kostum tanpa chip koin.
class SettingsBar extends StatelessWidget {
  const SettingsBar({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        KoIconButton(
          icon: KoIcons.back,
          semanticLabel: context.l10n.backToHome,
          onPressed: onBack,
        ),
        SizedBox(width: context.koSpace.s10),
        Expanded(
          child: Semantics(
            header: true,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                context.l10n.settings,
                maxLines: 1,
                style: context.koType.headingLarge.copyWith(
                  color: context.koColors.ink,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Satu bagian Pengaturan: judul kecil kapital ("BAHASA") di atas kartunya.
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: space.s4),
          child: Semantics(
            header: true,
            child: Text(
              title.toUpperCase(),
              style: context.koType.overline.copyWith(
                color: context.koColors.inkSoft,
              ),
            ),
          ),
        ),
        SizedBox(height: space.s8),
        child,
      ],
    );
  }
}

/// Lima pilihan bahasa: ikuti HP lalu bahasa yang didukung, masing-masing
/// ditulis dalam bahasanya sendiri. Pilihan yang aktif bercentang hijau
/// seperti kartu petunjuk yang terbuka.
class LanguageCard extends StatelessWidget {
  const LanguageCard({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final AppLanguage selected;
  final ValueChanged<AppLanguage> onSelect;

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    return KoCard(
      padding: EdgeInsets.symmetric(horizontal: space.s12, vertical: space.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final language in AppLanguage.values)
            _LanguageRow(
              key: ValueKey('language-${language.name}'),
              name: language.nativeName ?? context.l10n.languageSystem,
              selected: language == selected,
              onTap: () => onSelect(language),
            ),
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    super.key,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final tap = tapSound(context, onTap);
    final s = context.koSize;
    final space = context.koSpace;
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: name,
      onTap: tap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: tap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: s.iconButton),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: space.s6),
            child: Row(
              children: [
                Container(
                  width: s.chipSmall,
                  height: s.chipSmall,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? c.success : c.surface,
                    shape: BoxShape.circle,
                    border: selected
                        ? null
                        : Border.all(color: c.line, width: s.border),
                  ),
                  child: selected
                      ? KoIcon(
                          KoIcons.check,
                          size: s.iconCompact,
                          color: c.onSuccess,
                        )
                      : null,
                ),
                SizedBox(width: space.s10),
                Expanded(
                  child: Text(
                    name,
                    style: context.koType.cardLabel.copyWith(color: c.ink),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu berisi penjelasan, tombol, dan pesan hijau sesudah tombol
/// ditekan ([message]).
class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.text,
    required this.button,
    this.message,
  });

  final String text;
  final Widget button;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final message = this.message;
    return KoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(text, style: t.bodySmall.copyWith(color: c.inkSoft)),
          SizedBox(height: space.s10),
          button,
          if (message != null) ...[
            SizedBox(height: space.s8),
            Semantics(
              liveRegion: true,
              child: Text(
                message,
                style: t.controlLabel.copyWith(color: c.successText),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tentang: nama game, versi, kredit font, dan tombol halaman lisensi.
class AboutCard extends StatelessWidget {
  const AboutCard({super.key, required this.version, required this.onLicenses});

  /// Null = belum atau tidak bisa dibaca; barisnya tidak ditampilkan.
  final String? version;
  final VoidCallback onLicenses;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final l = context.l10n;
    final version = this.version;
    return KoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(appName, style: t.cardTitle),
          if (version != null)
            Text(
              l.version(version),
              style: t.controlLabel.copyWith(color: c.inkSoft),
            ),
          SizedBox(height: space.s6),
          Text(l.fontCredits, style: t.bodySmall.copyWith(color: c.inkSoft)),
          SizedBox(height: space.s10),
          SheetButton(
            label: l.licenses,
            icon: KoIcon(
              KoIcons.rules,
              size: context.koSize.iconCompact,
              color: c.ink,
            ),
            color: c.surface,
            line: c.line,
            edge: c.lineDeep,
            onPressed: onLicenses,
          ),
        ],
      ),
    );
  }
}

/// Sheet konfirmasi reset progres (gaya sheet Petunjuk): judul, tombol
/// tutup, penjelasan apa yang dihapus, lalu Batal dan Hapus.
class ResetSheet extends StatelessWidget {
  const ResetSheet({super.key, required this.onClose, required this.onConfirm});

  final VoidCallback onClose;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    final l = context.l10n;
    return LevelSheet(
      label: l.resetConfirmTitle,
      onClose: onClose,
      header: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(l.resetConfirmTitle, style: t.title),
            ),
          ),
          SizedBox(width: space.s10),
          KoIconButton(
            icon: KoIcons.close,
            semanticLabel: l.close,
            tone: KoIconButtonTone.flat,
            iconSize: s.iconSmall,
            onPressed: onClose,
          ),
        ],
      ),
      children: [
        Text(l.resetConfirmBody, style: t.bodySmall.copyWith(color: c.inkSoft)),
        SizedBox(height: space.s16),
        Row(
          children: [
            Expanded(
              child: SheetButton(
                label: l.cancel,
                icon: KoIcon(KoIcons.close, size: s.iconCompact, color: c.ink),
                color: c.surface,
                line: c.line,
                edge: c.lineDeep,
                onPressed: onClose,
              ),
            ),
            SizedBox(width: space.s8),
            Expanded(
              child: SheetButton(
                label: l.resetConfirm,
                icon: KoIcon(
                  KoIcons.reset,
                  size: s.iconCompact,
                  color: c.onBrick,
                ),
                color: c.brick,
                line: c.brick,
                edge: c.brickEdge,
                labelColor: c.onBrick,
                onPressed: onConfirm,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
