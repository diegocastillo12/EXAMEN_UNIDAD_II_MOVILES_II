import 'features/case_matching/providers/case_matching_providers.dart';
import 'features/saved_cases/data/data_sources/saved_list_file_source.dart';
import 'features/saved_cases/data/repositories/saved_list_file_repository_impl.dart';
import 'features/offline_cases/data/data_sources/open_case_cache_database_stub.dart'
    if (dart.library.io) 'features/offline_cases/data/data_sources/open_case_cache_database.dart';
import 'features/offline_cases/data/repositories/case_cache_repository_impl.dart';
import 'features/offline_cases/providers/case_cache_providers.dart';
import 'features/offline_drafts/data/repositories/local_draft_repository_impl.dart';
import 'features/offline_drafts/data/data_sources/open_local_draft_database_stub.dart'
    if (dart.library.io) 'features/offline_drafts/data/data_sources/open_local_draft_database.dart';
import 'features/offline_drafts/providers/local_draft_providers.dart';
import 'features/user_blocks/providers/user_block_providers.dart';
import 'features/case_contacts/providers/case_contact_providers.dart';
import 'features/content_reports/providers/content_report_providers.dart';
import 'features/moderation_appeals/providers/appeals_providers.dart';
import 'features/case_closure/providers/case_closure_providers.dart';
import 'features/notifications/providers/notification_providers.dart';
import 'features/explore/providers/explore_providers.dart';
import 'features/case_timeline/providers/case_timeline_providers.dart';
import 'features/sightings/providers/sighting_providers.dart';
import 'features/case_posters/providers/case_poster_providers.dart';
import 'features/places/providers/places_providers.dart';
import 'features/saved_cases/providers/saved_cases_providers.dart';
import 'features/found_cases/providers/found_case_providers.dart';
import 'features/lost_cases/providers/lost_case_providers.dart';
import 'features/onboarding/providers/onboarding_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/bootstrap.dart';
import 'app/android_saved_list_cipher.dart';
import 'app/entre_huellas_app.dart';
import 'core/config/app_config.dart';
import 'core/config/startup_state_provider.dart';
import 'features/auth/providers/auth_providers.dart';
import 'features/auth/providers/registration_providers.dart';
import 'features/auth/providers/password_recovery_providers.dart';
import 'features/profile/providers/profile_providers.dart';
import 'features/pets/providers/pet_providers.dart';
import 'features/interest_zones/providers/interest_zone_providers.dart';
import 'features/alert_preferences/providers/alert_preference_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bootstrap = await bootstrapApp(const AppConfig.fromEnvironment());
  runApp(
    ProviderScope(
      overrides: [
        caseCacheRepositoryProvider.overrideWithValue(
          CaseCacheRepositoryImpl(openCaseCacheDatabase()),
        ),
        localDraftRepositoryProvider.overrideWithValue(
          LocalDraftRepositoryImpl(openLocalDraftDatabase()),
        ),
        caseMatchingRepositoryProvider.overrideWithValue(
          bootstrap.caseMatchingRepository,
        ),
        userBlockRepositoryProvider.overrideWithValue(
          bootstrap.userBlockRepository,
        ),
        contentReportRepositoryProvider.overrideWithValue(
          bootstrap.contentReportRepository,
        ),
        appealsRepositoryProvider.overrideWithValue(
          bootstrap.appealsRepository,
        ),
        caseClosureRepositoryProvider.overrideWithValue(
          bootstrap.caseClosureRepository,
        ),
        notificationRepositoryProvider.overrideWithValue(
          bootstrap.notificationRepository,
        ),
        pushRepositoryProvider.overrideWithValue(bootstrap.pushRepository),
        caseTimelineRepositoryProvider.overrideWithValue(
          bootstrap.caseTimelineRepository,
        ),
        sightingRepositoryProvider.overrideWithValue(
          bootstrap.sightingRepository,
        ),
        caseShareRepositoryProvider.overrideWithValue(
          bootstrap.caseShareRepository,
        ),
        casePosterRepositoryProvider.overrideWithValue(
          bootstrap.casePosterRepository,
        ),
        caseContactRepositoryProvider.overrideWithValue(
          bootstrap.caseContactRepository,
        ),
        savedCasesRepositoryProvider.overrideWithValue(
          bootstrap.savedCasesRepository,
        ),
        savedListFileRepositoryProvider.overrideWithValue(
          SavedListFileRepositoryImpl(
            SavedListFileSource(cipher: const AndroidSavedListCipher()),
          ),
        ),
        currentLocationRepositoryProvider.overrideWithValue(
          bootstrap.currentLocationRepository,
        ),
        placeSearchRepositoryProvider.overrideWithValue(
          bootstrap.placeSearchRepository,
        ),
        exploreRepositoryProvider.overrideWithValue(
          bootstrap.exploreRepository,
        ),
        foundCaseRepositoryProvider.overrideWithValue(
          bootstrap.foundCaseRepository,
        ),
        lostCaseRepositoryProvider.overrideWithValue(
          bootstrap.lostCaseRepository,
        ),
        alertPreferenceRepositoryProvider.overrideWithValue(
          bootstrap.alertPreferenceRepository,
        ),
        interestZoneRepositoryProvider.overrideWithValue(
          bootstrap.interestZoneRepository,
        ),
        petRepositoryProvider.overrideWithValue(bootstrap.petRepository),
        petPhotoRepositoryProvider.overrideWithValue(
          bootstrap.petPhotoRepository,
        ),
        profilePhotoRepositoryProvider.overrideWithValue(
          bootstrap.profilePhotoRepository,
        ),
        profileRepositoryProvider.overrideWithValue(
          bootstrap.profileRepository,
        ),
        startupStateProvider.overrideWithValue(bootstrap.state),
        authRepositoryProvider.overrideWithValue(bootstrap.authRepository),
        passwordRecoveryRepositoryProvider.overrideWithValue(
          bootstrap.passwordRecoveryRepository,
        ),
        accessRepositoryProvider.overrideWithValue(bootstrap.accessRepository),
        registrationRepositoryProvider.overrideWithValue(
          bootstrap.registrationRepository,
        ),
        onboardingRepositoryProvider.overrideWithValue(
          bootstrap.onboardingRepository,
        ),
      ],
      child: const EntreHuellasApp(observeQueue: true),
    ),
  );
}
