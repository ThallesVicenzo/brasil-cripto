import 'package:brasil_cripto/l10n/global_app_localizations.dart';
import 'package:brasil_cripto/model/repositories/home_repository.dart';
import 'package:brasil_cripto/model/service/client/client_http.dart';
import 'package:brasil_cripto/model/service/client/dio/dio_client.dart';
import 'package:brasil_cripto/view_model/services/favorites_service.dart';
import 'package:brasil_cripto/view_model/utils/secure_storage/secure_storage.dart';
import 'package:brasil_cripto/view_model/utils/secure_storage/secure_storage_impl.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerSingleton<SecureStorage>(SecureStorageImpl());

  sl.registerSingleton<ClientHttp>(DioClient());

  sl.registerSingleton<GlobalAppLocalizations>(GlobalAppLocalizationsImpl());

  sl.registerSingleton<FavoritesService>(FavoritesService());

  sl.registerFactory<HomeRepository>(
    () => HomeRepositoryImpl(client: sl(), secureStorage: sl()),
  );
}
