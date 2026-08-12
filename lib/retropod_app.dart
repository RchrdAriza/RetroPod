import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retropod/core/extensions/build_context_extensions.dart';
import 'package:retropod/core/navigation/routes.dart';
import 'package:retropod/features/settings/controller/settings_preferences_controller.dart';
import 'package:retropod/l10n/generated/app_localizations.dart';

class RetropodApp extends ConsumerWidget {
  const RetropodApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageLocaleCode = ref.watch(
      settingsPreferencesControllerProvider.select(
        (value) => value.languageLocaleCode,
      ),
    );
    final appTheme = ref.watch(
      settingsPreferencesControllerProvider.select((value) => value.appTheme),
    );
    final router = ref.watch(routerProvider);
    return CupertinoApp.router(
      onGenerateTitle: (context) => context.localization.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: Locale(languageLocaleCode),
      theme: appTheme.toCupertinoTheme(),
    );
  }
}
