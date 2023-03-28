import 'dart:convert';

import '../models/models.dart';
import '../scopes/scopes.dart';

abstract class RouterContext {
  Neuron get neuron;
  NeuronOptions get options;
  set options(NeuronOptions value);
  JsonEncoder get encoder;
  String transformPath(String path);
  ScopeApi get scopeApi;
}
