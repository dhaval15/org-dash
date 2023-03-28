
import 'scope.dart';

abstract class ScopeApi {
	Future<List<Scope>> fetch();
	Future insert(Scope scope);
	Future remove(String id);
	Future update(Scope scope);
}

