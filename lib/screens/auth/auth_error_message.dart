import '../../services/auth/auth_api_client.dart';
import '../../services/localization_service.dart';

String authErrorMessage(AuthException error) {
  return appLocalizations.translate('auth.errors.${error.type.name}');
}
