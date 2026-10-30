import '../features/case_matching/domain/repositories/case_matching_repository.dart';
import '../features/case_matching/data/repositories/case_matching_repository_impl.dart';
import '../features/case_matching/data/repositories/unavailable_case_matching_repository.dart';
import '../features/case_matching/data/data_sources/matching_source.dart';
import '../features/onboarding/data/data_sources/offline_onboarding_data_source.dart';
import '../features/onboarding/data/data_sources/onboarding_completion_cache.dart';
import '../features/case_posters/domain/repositories/case_share_repository.dart';
import '../features/case_posters/data/repositories/case_share_repository_impl.dart';
import '../features/case_posters/data/data_sources/supabase_case_share_source.dart';
import '../features/case_posters/data/data_sources/native_case_share_action_source.dart';
import '../features/case_contacts/domain/repositories/case_contact_repository.dart';
import '../features/case_contacts/data/repositories/case_contact_repository_impl.dart';
import '../features/case_contacts/data/data_sources/case_contact_source.dart';
import '../features/content_reports/domain/repositories/content_report_repository.dart';
import '../features/moderation_appeals/domain/repositories/appeals_repository.dart';
import '../features/moderation_appeals/data/repositories/appeals_repository_impl.dart';
import '../features/moderation_appeals/data/data_sources/appeals_source.dart';
import '../features/content_reports/data/repositories/content_report_repository_impl.dart';
import '../features/content_reports/data/data_sources/content_report_source.dart';
import '../features/case_closure/domain/repositories/case_closure_repository.dart';
import '../features/case_closure/data/repositories/case_closure_repository_impl.dart';
import '../features/case_closure/data/data_sources/case_closure_source.dart';
import '../features/notifications/domain/repositories/notification_repository.dart';
import '../features/notifications/domain/repositories/push_repository.dart';
import '../features/notifications/data/repositories/unavailable_push_repository.dart';
import '../features/notifications/data/repositories/unavailable_notification_repository.dart';
import '../features/notifications/data/repositories/notification_repository_impl.dart';
import '../features/notifications/data/data_sources/supabase_notification_source.dart';
import 'package:http/http.dart' as http;
import '../features/case_timeline/domain/repositories/case_timeline_repository.dart';
import '../features/case_timeline/data/repositories/case_timeline_repository_impl.dart';
import '../features/case_timeline/data/data_sources/case_timeline_source.dart';
import '../features/sightings/domain/repositories/sighting_repository.dart';
import '../features/sightings/data/repositories/unavailable_sighting_repository.dart';
import '../features/sightings/data/repositories/sighting_repository_impl.dart';
import '../features/sightings/data/data_sources/sighting_source.dart';
import 'package:flutter/services.dart'
    show rootBundle, Clipboard, ClipboardData;
import '../features/case_posters/domain/repositories/case_poster_repository.dart';
import '../features/case_posters/data/repositories/unavailable_case_poster_repository.dart';
import '../features/case_posters/data/repositories/case_poster_repository_impl.dart';
import '../features/case_posters/data/data_sources/supabase_poster_case_source.dart';
import '../features/case_posters/data/data_sources/pdf_poster_document_source.dart';
import '../features/case_posters/data/data_sources/native_poster_export_source.dart';
import '../features/saved_cases/domain/repositories/saved_cases_repository.dart';
import '../features/saved_cases/data/data_sources/supabase_saved_cases_data_source.dart';
import '../features/saved_cases/data/repositories/saved_cases_repository_impl.dart';
import '../features/saved_cases/data/repositories/unavailable_saved_cases_repository.dart';
import '../features/explore/domain/repositories/current_location_repository.dart';
import '../features/explore/data/data_sources/device_location_source.dart';
import '../features/explore/data/repositories/current_location_repository_impl.dart';
import '../features/places/domain/repositories/place_search_repository.dart';
import '../features/places/data/data_sources/photon_place_data_source.dart';
import '../features/places/data/repositories/place_search_repository_impl.dart';
import '../features/places/data/repositories/unavailable_place_search_repository.dart';
import '../features/explore/domain/repositories/explore_repository.dart';
import '../features/explore/data/data_sources/supabase_explore_data_source.dart';
import '../features/explore/data/repositories/explore_repository_impl.dart';
import '../features/explore/data/repositories/unavailable_explore_repository.dart';
import '../features/found_cases/domain/repositories/found_case_repository.dart';
import '../features/found_cases/data/data_sources/supabase_found_case_data_source.dart';
import '../features/found_cases/data/repositories/found_case_repository_impl.dart';
import '../features/found_cases/data/repositories/unavailable_found_case_repository.dart';
import '../features/lost_cases/domain/repositories/lost_case_repository.dart';
import '../features/lost_cases/data/data_sources/supabase_lost_case_data_source.dart';
import '../features/lost_cases/data/repositories/lost_case_repository_impl.dart';
import '../features/lost_cases/data/repositories/unavailable_lost_case_repository.dart';
import '../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../features/onboarding/data/data_sources/supabase_onboarding_data_source.dart';
import '../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../features/onboarding/data/repositories/unavailable_onboarding_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/profile/data/data_sources/supabase_profile_data_source.dart';
import '../features/profile/data/repositories/profile_repository_impl.dart';
import '../features/profile/data/repositories/unavailable_profile_repository.dart';
import 'package:image_picker/image_picker.dart';
import '../features/profile/domain/repositories/profile_photo_repository.dart';
import '../features/profile/data/repositories/profile_photo_repository_impl.dart';
import '../features/profile/data/repositories/unavailable_profile_photo_repository.dart';
import '../features/profile/data/data_sources/gallery_profile_photo_source.dart';
import '../features/pets/domain/repositories/pet_repository.dart';
import '../features/pets/data/data_sources/supabase_pet_data_source.dart';
import '../features/pets/data/repositories/pet_repository_impl.dart';
import '../features/pets/data/repositories/unavailable_pet_repository.dart';
import '../features/pets/domain/repositories/pet_photo_repository.dart';
import '../features/pets/data/data_sources/pet_gallery_source.dart';
import '../features/pets/data/data_sources/supabase_pet_photo_source.dart';
import '../features/pets/data/repositories/pet_photo_repository_impl.dart';
import '../features/pets/data/repositories/unavailable_pet_photo_repository.dart';
import '../features/interest_zones/domain/repositories/interest_zone_repository.dart';
import '../features/alert_preferences/domain/repositories/alert_preference_repository.dart';
import '../features/alert_preferences/data/data_sources/supabase_alert_preference_data_source.dart';
import '../features/alert_preferences/data/repositories/alert_preference_repository_impl.dart';
import '../features/alert_preferences/data/repositories/unavailable_alert_preference_repository.dart';
import '../features/interest_zones/data/data_sources/supabase_interest_zone_data_source.dart';
import '../features/interest_zones/data/repositories/interest_zone_repository_impl.dart';
import '../features/interest_zones/data/repositories/unavailable_interest_zone_repository.dart';

import '../core/config/app_config.dart';
import '../core/config/startup_state.dart';
import '../features/auth/data/data_sources/supabase_auth_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/data/repositories/unavailable_auth_repository.dart';
import '../features/user_blocks/domain/repositories/user_block_repository.dart';
import '../features/user_blocks/data/repositories/user_block_repository_impl.dart';
import '../features/user_blocks/data/data_sources/user_block_source.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/repositories/access_repository.dart';
import '../features/auth/data/repositories/access_repository_impl.dart';
import '../features/auth/data/repositories/unavailable_access_repository.dart';
import '../features/auth/domain/repositories/registration_repository.dart';
import '../features/auth/data/data_sources/supabase_registration_data_source.dart';
import '../features/auth/data/repositories/registration_repository_impl.dart';
import '../features/auth/data/repositories/unavailable_registration_repository.dart';
import '../features/auth/domain/repositories/password_recovery_repository.dart';
import '../features/auth/data/data_sources/supabase_password_recovery_data_source.dart';
import '../features/auth/data/repositories/password_recovery_repository_impl.dart';
import '../features/auth/data/repositories/unavailable_password_recovery_repository.dart';

class AppBootstrap {
  const AppBootstrap({
    this.caseMatchingRepository = const UnavailableCaseMatchingRepository(),
    this.userBlockRepository = const UnavailableUserBlockRepository(),
    this.caseShareRepository = const UnavailableCaseShareRepository(),
    this.caseContactRepository = const UnavailableCaseContactRepository(),
    this.contentReportRepository = const UnavailableContentReportRepository(),
    this.appealsRepository = const UnavailableAppealsRepository(),
    this.caseClosureRepository = const UnavailableCaseClosureRepository(),
    this.notificationRepository = const UnavailableNotificationRepository(),
    this.pushRepository = const UnavailablePushRepository(),
    this.caseTimelineRepository = const UnavailableCaseTimelineRepository(),
    this.sightingRepository = const UnavailableSightingRepository(),
    this.casePosterRepository = const UnavailableCasePosterRepository(),
    required this.state,
    required this.authRepository,
    required this.accessRepository,
    required this.onboardingRepository,
    required this.registrationRepository,
    required this.passwordRecoveryRepository,
    required this.profileRepository,
    required this.profilePhotoRepository,
    required this.petRepository,
    required this.petPhotoRepository,
    required this.interestZoneRepository,
    required this.alertPreferenceRepository,
    required this.lostCaseRepository,
    this.placeSearchRepository = const UnavailablePlaceSearchRepository(),
    this.currentLocationRepository =
        const UnavailableCurrentLocationRepository(),
    this.exploreRepository = const UnavailableExploreRepository(),
    this.savedCasesRepository = const UnavailableSavedCasesRepository(),
    this.foundCaseRepository = const UnavailableFoundCaseRepository(),
  });

  final CaseMatchingRepository caseMatchingRepository;
  final CaseClosureRepository caseClosureRepository;
  final UserBlockRepository userBlockRepository;
  final CaseContactRepository caseContactRepository;
  final ContentReportRepository contentReportRepository;
  final AppealsRepository appealsRepository;
  final StartupState state;
  final NotificationRepository notificationRepository;
  final PushRepository pushRepository;
  final CaseTimelineRepository caseTimelineRepository;
  final SightingRepository sightingRepository;
  final CasePosterRepository casePosterRepository;
  final CaseShareRepository caseShareRepository;
  final AuthRepository authRepository;
  final AccessRepository accessRepository;
  final OnboardingRepository onboardingRepository;
  final RegistrationRepository registrationRepository;
  final PasswordRecoveryRepository passwordRecoveryRepository;
  final ProfileRepository profileRepository;
  final ProfilePhotoRepository profilePhotoRepository;
  final PetRepository petRepository;
  final PetPhotoRepository petPhotoRepository;
  final InterestZoneRepository interestZoneRepository;
  final AlertPreferenceRepository alertPreferenceRepository;
  final LostCaseRepository lostCaseRepository;
  final FoundCaseRepository foundCaseRepository;
  final ExploreRepository exploreRepository;
  final SavedCasesRepository savedCasesRepository;
  final PlaceSearchRepository placeSearchRepository;
  final CurrentLocationRepository currentLocationRepository;
}

/// Initializes the SDK once, before the provider tree and router are mounted.
Future<AppBootstrap> bootstrapApp(AppConfig config) async {
  switch (config.status) {
    case ConfigurationStatus.missing:
      return _unavailable(StartupStatus.missingConfiguration);
    case ConfigurationStatus.invalid:
      return _unavailable(StartupStatus.invalidConfiguration);
    case ConfigurationStatus.ready:
      try {
        final supabase = await Supabase.initialize(
          url: config.supabaseUrl,
          publishableKey: config.supabaseKey,
          debug: false,
          authOptions: const FlutterAuthClientOptions(
            authFlowType: AuthFlowType.pkce,
          ),
        );
        final source = SupabaseAuthDataSource(
          supabase.client,
          redirectUri: kIsWeb ? null : AppConfig.authRedirectUri,
        );
        return AppBootstrap(
          caseMatchingRepository: CaseMatchingRepositoryImpl(
            MatchingSource(
              supabase.client,
              http.Client(),
              const String.fromEnvironment(
                'PUBLIC_CASE_WEB_URL',
                defaultValue: 'https://entrehuellas.app',
              ),
            ),
          ),
          userBlockRepository: UserBlockRepositoryImpl(
            SupabaseUserBlockSource(supabase.client),
          ),
          contentReportRepository: ContentReportRepositoryImpl(
            SupabaseContentReportSource(supabase.client),
          ),
          appealsRepository: AppealsRepositoryImpl(
            SupabaseAppealsSource(supabase.client),
          ),
          caseClosureRepository: CaseClosureRepositoryImpl(
            SupabaseCaseClosureSource(supabase.client),
          ),
          caseTimelineRepository: CaseTimelineRepositoryImpl(
            SupabaseCaseTimelineSource(supabase.client),
          ),
          sightingRepository: SightingRepositoryImpl(
            NativeSightingSource(
              supabase.client,
              http.Client(),
              ImagePicker(),
              const String.fromEnvironment(
                'PUBLIC_CASE_WEB_URL',
                defaultValue: 'https://entrehuellas.app',
              ),
            ),
          ),
          casePosterRepository: CasePosterRepositoryImpl(
            SupabasePosterCaseSource(supabase.client),
            PdfPosterDocumentSource(
              regularFont: () =>
                  rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
              boldFont: () => rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
            ),
            const NativePosterExportSource(),
            webBaseUrl: const String.fromEnvironment(
              'PUBLIC_CASE_WEB_URL',
              defaultValue: 'https://entrehuellas.app',
            ),
            publicWebReady: const bool.fromEnvironment('PUBLIC_CASE_WEB_READY'),
          ),
          notificationRepository: NotificationRepositoryImpl(
            SupabaseNotificationSource(supabase.client),
          ),
          caseShareRepository: CaseShareRepositoryImpl(
            SupabaseCaseShareSource(supabase.client),
            PdfPosterDocumentSource(
              regularFont: () =>
                  rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
              boldFont: () => rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
            ),
            NativeCaseShareActionSource(
              const NativePosterExportSource(),
              copyText: (text) => Clipboard.setData(ClipboardData(text: text)),
            ),
            webBaseUrl: const String.fromEnvironment(
              'PUBLIC_CASE_WEB_URL',
              defaultValue: 'https://entrehuellas.app',
            ),
            publicWebReady: const bool.fromEnvironment('PUBLIC_CASE_WEB_READY'),
          ),
          savedCasesRepository: SavedCasesRepositoryImpl(
            SupabaseSavedCasesDataSource(supabase.client),
          ),
          caseContactRepository: CaseContactRepositoryImpl(
            CaseContactSource(supabase.client),
          ),
          currentLocationRepository: const CurrentLocationRepositoryImpl(
            DeviceLocationSource(),
          ),
          placeSearchRepository: PlaceSearchRepositoryImpl(
            PhotonPlaceDataSource(
              http.Client(),
              endpoint: const String.fromEnvironment(
                'PLACE_SEARCH_URL',
                defaultValue: 'https://photon.komoot.io/api/',
              ),
            ),
          ),
          exploreRepository: ExploreRepositoryImpl(
            SupabaseExploreDataSource(supabase.client),
          ),
          foundCaseRepository: FoundCaseRepositoryImpl(
            SupabaseFoundCaseDataSource(supabase.client),
            NativePhotoGallerySource(
              ImagePicker(),
              pendingMarker: 'found_photo_pending',
            ),
          ),
          lostCaseRepository: LostCaseRepositoryImpl(
            SupabaseLostCaseDataSource(supabase.client),
          ),
          alertPreferenceRepository: AlertPreferenceRepositoryImpl(
            SupabaseAlertPreferenceDataSource(supabase.client),
          ),
          interestZoneRepository: InterestZoneRepositoryImpl(
            SupabaseInterestZoneDataSource(supabase.client),
          ),
          petPhotoRepository: PetPhotoRepositoryImpl(
            NativePetGallerySource(ImagePicker()),
            SupabasePetPhotoSource(supabase.client),
          ),
          petRepository: PetRepositoryImpl(
            SupabasePetDataSource(supabase.client),
          ),
          state: const StartupState(StartupStatus.ready),
          profilePhotoRepository: ProfilePhotoRepositoryImpl(
            GalleryProfilePhotoSource(ImagePicker()),
            SupabaseProfileDataSource(supabase.client),
          ),
          authRepository: AuthRepositoryImpl(source),
          accessRepository: AccessRepositoryImpl(source),
          profileRepository: ProfileRepositoryImpl(
            SupabaseProfileDataSource(supabase.client),
          ),
          passwordRecoveryRepository: PasswordRecoveryRepositoryImpl(
            SupabasePasswordRecoveryDataSource(
              supabase.client,
              redirectUri: kIsWeb ? null : AppConfig.authRedirectUri,
            ),
          ),
          registrationRepository: RegistrationRepositoryImpl(
            SupabaseRegistrationDataSource(
              supabase.client,
              redirectUri: kIsWeb ? null : AppConfig.authRedirectUri,
            ),
          ),
          onboardingRepository: OnboardingRepositoryImpl(
            OfflineOnboardingDataSource(
              SupabaseOnboardingDataSource(supabase.client),
              PreferencesOnboardingCompletionCache(),
              currentOwner: () => supabase.client.auth.currentUser?.id,
            ),
          ),
        );
      } catch (_) {
        // Do not expose configuration or tokens through startup errors.
        return _unavailable(StartupStatus.failed);
      }
  }
}

AppBootstrap _unavailable(StartupStatus status) => AppBootstrap(
  lostCaseRepository: const UnavailableLostCaseRepository(),
  alertPreferenceRepository: const UnavailableAlertPreferenceRepository(),
  interestZoneRepository: const UnavailableInterestZoneRepository(),
  petPhotoRepository: const UnavailablePetPhotoRepository(),
  petRepository: const UnavailablePetRepository(),
  state: StartupState(status),
  authRepository: const UnavailableAuthRepository(),
  accessRepository: const UnavailableAccessRepository(),
  registrationRepository: const UnavailableRegistrationRepository(),
  passwordRecoveryRepository: const UnavailablePasswordRecoveryRepository(),
  onboardingRepository: const UnavailableOnboardingRepository(),
  profileRepository: const UnavailableProfileRepository(),
  profilePhotoRepository: const UnavailableProfilePhotoRepository(),
);
