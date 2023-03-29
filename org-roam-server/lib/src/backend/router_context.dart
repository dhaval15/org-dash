import 'dart:convert';

import '../models/models.dart';
import '../scopes/scopes.dart';
import '../sql/sql.dart';

abstract class RouterContext {
	NeuronSqlApi get neuronApi;
  NeuronOptions get options;
  set options(NeuronOptions value);
  JsonEncoder get encoder;
  String transformPath(String path);
  ScopeApi get scopeApi;
}
