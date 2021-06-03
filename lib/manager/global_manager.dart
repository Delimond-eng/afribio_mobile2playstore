import 'package:afribio/models/user_commande_model.dart';
import 'package:afribio/services/http_service.dart';

class GlobalManager {
  Stream<UserCommands> get userCommandsView async* {
    yield await HttpService.getUserCommandes();
  }
}
