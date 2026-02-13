
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:project_route_p/app.constants.dart';
import 'package:project_route_p/ui/widgets/alertmanager/alert_manager.dart';
import 'package:project_route_p/ui/widgets/cl_media_viewer.widget.dart';
import 'package:project_route_p/utils/providers/authstate.util.provider.dart';
import 'package:project_route_p/utils/providers/errorstate.util.provider.dart';
import 'package:provider/provider.dart';

enum ApiCallType { GET, POST, DELETE, PUT, PATCH }

enum BodyType { NONE, JSON, TEXT, X_WWW_FORM_URL_ENCODED, MULTIPART }

class ApiCallRecord extends Equatable {
  const ApiCallRecord(this.callName, this.apiUrl, this.headers, this.params, this.body, this.bodyType);

  final String callName;
  final String apiUrl;
  final Map<String, dynamic> headers;
  final Map<String, dynamic> params;
  final String? body;
  final BodyType? bodyType;

  @override
  List<Object?> get props => [callName, apiUrl, headers, params, body, bodyType];
}

class ApiCallResponse {
  const ApiCallResponse(this.jsonBody, this.pagination, this.error, this.headers, this.statusCode, {this.response});

  final dynamic jsonBody;
  final Pagination? pagination;
  final Map<String, String> headers;
  final int statusCode;
  final ApiError? error;
  final http.Response? response;

  // Whether we received a 2xx status (which generally marks success).
  bool get succeeded => statusCode >= 200 && statusCode < 300;

  bool get unauthenticated => statusCode == 401;

  String getHeader(String headerName) => headers[headerName] ?? '';

  // Return the raw body from the response, or if this came from a cloud call
  // and the body is not a string, then the json encoded body.
  String get bodyText => response?.body ?? (jsonBody is String ? jsonBody as String : jsonEncode(jsonBody));

  static Future<ApiCallResponse> fromHttpResponse(http.Response response, bool returnBody, bool decodeUtf8) async {
    var jsonBody;
    Pagination? pagination;
    ApiError? error;
    try {
      final responseBody = decodeUtf8 && returnBody ? const Utf8Decoder().convert(response.bodyBytes) : response.body;
      jsonBody = returnBody ? json.decode(responseBody) : null;
      error = jsonBody["error"] != null ? ApiError.fromJson(jsonObject: jsonBody["error"]) : null;
      pagination = jsonBody["meta"] != null ? Pagination.fromJson(jsonObject: jsonBody["meta"]) : null;
    } catch (_) {}
    return ApiCallResponse(jsonBody["data"], pagination, error, response.headers, response.statusCode, response: response);
  }
}

class ApiError {
  int? statusCode;
  String? message;
  String? error;

  ApiError({this.statusCode, this.message, this.error});

  factory ApiError.fromJson({required dynamic jsonObject}) {
    final error = ApiError();
    error.statusCode = jsonObject["statusCode"];
    error.message = jsonObject["message"];
    final rawError = jsonObject["error"];
    if (rawError is List) {
      error.error = rawError.map((e) => e.toString()).join(', ');
    } else if (rawError is Map) {
      error.error = rawError.values.expand((v) => v is List ? v : [v]).map((e) => e.toString()).join(', ');
    } else {
      error.error = rawError?.toString() ?? '';
    }
    return error;
  }
}

class ApiManager {
  ApiManager._();

  static ApiManager? _instance;

  static ApiManager get instance => _instance ??= ApiManager._();

  static Map<String, String> toStringMap(Map map) => map.map((key, value) => MapEntry(key.toString(), value.toString()));

  static String asQueryParams(Map<String, dynamic> map) =>
      map.entries.map((e) => "${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}").join('&');

  static Future<ApiCallResponse> urlRequest(
      ApiCallType callType,
      String apiUrl,
      Map<String, dynamic> headers,
      Map<String, dynamic> params,
      bool returnBody,
      bool decodeUtf8,
      ) async {
    if (params.isNotEmpty) {
      final specifier = Uri.parse(apiUrl).queryParameters.isNotEmpty ? '&' : '?';
      apiUrl = '$apiUrl$specifier${asQueryParams(params)}';
    }
    final makeRequest = callType == ApiCallType.GET ? http.get : http.delete;
    final response = await makeRequest(Uri.parse(apiUrl), headers: toStringMap(headers));
    return ApiCallResponse.fromHttpResponse(response, returnBody, decodeUtf8);
  }

  static Future<ApiCallResponse> requestWithBody(
      ApiCallType type,
      String apiUrl,
      Map<String, dynamic> headers,
      Map<String, dynamic> params,
      String? body,
      BodyType? bodyType,
      bool returnBody,
      bool encodeBodyUtf8,
      bool decodeUtf8,
      ) async {
    assert({ApiCallType.POST, ApiCallType.PUT, ApiCallType.PATCH}.contains(type), 'Invalid ApiCallType $type for request with body');
    final postBody = createBody(headers, params, body, bodyType, encodeBodyUtf8);

    if (bodyType == BodyType.MULTIPART) {
      return multipartRequest(type, apiUrl, headers, params, returnBody, decodeUtf8);
    }

    final requestFn = {ApiCallType.POST: http.post, ApiCallType.PUT: http.put, ApiCallType.PATCH: http.patch}[type]!;
    final response = await requestFn(Uri.parse(apiUrl), headers: toStringMap(headers), body: postBody);
    return ApiCallResponse.fromHttpResponse(response, returnBody, decodeUtf8);
  }

  static Future<ApiCallResponse> multipartRequest(
      ApiCallType? type,
      String apiUrl,
      Map<String, dynamic> headers,
      Map<String, dynamic> params,
      bool returnBody,
      bool decodeUtf8,
      ) async {
    assert({ApiCallType.POST, ApiCallType.PUT, ApiCallType.PATCH}.contains(type), 'Invalid ApiCallType $type for request with body');
    isFile(e) => e is CLMedia || e is PlatformFile || e is List<CLMedia> || (e is List && e.firstOrNull is CLMedia);
    final nonFileParams = Map.fromEntries(params.entries.where((e) => !isFile(e.value)));
    List<http.MultipartFile> files = [];
    params.entries.where((e) => isFile(e.value)).forEach((e) {
      final param = e.value;
      final uploadedFiles = param is List ? param as List<CLMedia> : [param as CLMedia];
      for (var uploadedFile in uploadedFiles) {
        files.add(
          http.MultipartFile.fromBytes(
            e.key,
            uploadedFile.file?.bytes ?? Uint8List.fromList([]),
            filename: uploadedFile.file?.name,
            contentType: _getMediaType(uploadedFile.file?.name),
          ),
        );
      }
    });
    final request =
    http.MultipartRequest(type.toString().split('.').last, Uri.parse(apiUrl))
      ..headers.addAll(toStringMap(headers))
      ..files.addAll(files);
    nonFileParams.forEach((key, value) => request.fields[key] = value.toString());

    final response = await http.Response.fromStream(await request.send());
    return ApiCallResponse.fromHttpResponse(response, returnBody, decodeUtf8);
  }

  static MediaType? _getMediaType(String? filename) {
    if (filename == null) return null;
    final contentType = lookupMimeType(filename);
    if (contentType == null) {
      return null;
    }
    final parts = contentType.split('/');
    if (parts.length != 2) {
      return null;
    }
    return MediaType(parts.first, parts.last);
  }

  static dynamic createBody(Map<String, dynamic> headers, Map<String, dynamic>? params, String? body, BodyType? bodyType, bool encodeBodyUtf8) {
    String? contentType;
    dynamic postBody;
    switch (bodyType) {
      case BodyType.JSON:
        contentType = 'application/json';
        postBody = body ?? json.encode(params ?? {});
        break;
      case BodyType.TEXT:
        contentType = 'text/plain';
        postBody = body ?? json.encode(params ?? {});
        break;
      case BodyType.X_WWW_FORM_URL_ENCODED:
        contentType = 'application/x-www-form-urlencoded';
        postBody = toStringMap(params ?? {});
        break;
      case BodyType.MULTIPART:
        contentType = 'multipart/form-data';
        postBody = params;
        break;
      case BodyType.NONE:
      case null:
        break;
    }
    // Set "Content-Type" header if it was previously unset.
    if (contentType != null && !headers.keys.any((h) => h.toLowerCase() == 'content-type')) {
      headers['Content-Type'] = contentType;
    }
    return encodeBodyUtf8 && postBody is String ? utf8.encode(postBody) : postBody;
  }

  Future<Map<String, dynamic>> initHeader(Map<String, dynamic> headers, needAuth, needTenant, BuildContext context) async {
    Map<String, dynamic> allHeaders = {};
    allHeaders.addAll(headers);
    allHeaders.addAll({HttpHeaders.acceptHeader: "application/json"});
    if (needAuth && getAuthBearerToken(context) != null) {
      allHeaders.addAll({HttpHeaders.authorizationHeader: 'Bearer ${getAuthBearerToken(context)}'});
    }
    print(getCurrentTenantId(context));
    if (needTenant && getCurrentTenantId(context) != null) {
      allHeaders.addAll({"x-tenant-id": getCurrentTenantId(context)});
    }
    return allHeaders;
  }

  String? getAuthBearerToken(BuildContext context) {
    final authState = Provider.of<AuthState>(context, listen: false);
    return authState.currentUser?.idToken;
  }

  String? getCurrentTenantId(BuildContext context) {
    final authState = Provider.of<AuthState>(context, listen: false);
    return authState.currentTenant?.id;
  }

  Map<String, dynamic> convertSearchBy(Map<String, dynamic> body) {
    Map<String, dynamic> searchBy = {};


    body.forEach((key, value) {
      // Remove spaces if key is 'fullname'
      if (key == 'employee:fullname' && value is String || key == 'fullname' && value is String) {
        value = value.replaceAll(' ', '');
      }

      // Divide key based on ':'
      List<String> parts = key.split(':');
      Map<String, dynamic> currentLevel = searchBy;

      for (int i = 0; i < parts.length; i++) {
        // Handle boolean values
        if (value is bool) {
          if (i == parts.length - 1) {
            currentLevel[parts[i]] = value;
          }
        }
        // Handle DateTimeRange values
        else if (value is DateTimeRange) {
          if (i == parts.length - 1) {
            currentLevel[parts[i]] = {
              'gte': "${value.start..toUtc().toIso8601String()}",
              'lte': value.end.add(const Duration(hours: 23, minutes: 59, seconds: 59)).toUtc().toIso8601String(),
            };
          }
        }
        // Handle other types of values
        else {
          if (i == parts.length - 1) {
            // Se il valore è un Map con gte/lte (range di date già processato), usalo direttamente
            if (value is Map<String, dynamic> && (value.containsKey('gte') || value.containsKey('lte'))) {
              currentLevel[parts[i]] = value;
            }
            else if (value is Map && (value.containsKey('gte') || value.containsKey('lte'))) {
              currentLevel[parts[i]] = value;
            }
            // If the final key is 'id', use direct search, otherwise use 'contains'
            else if (parts[i].contains("Id")) {
              if (parts[i].contains("Ids")) {
                currentLevel[parts[i]] = {'has': value};
              } else {
                currentLevel[parts[i]] = value;
              }
            } else {
              currentLevel[parts[i]] = {'contains': value, 'mode': 'insensitive'};
            }
          } else {
            // Create a new nesting level if it does not already exist
            if (currentLevel[parts[i]] == null) {
              currentLevel[parts[i]] = <String, dynamic>{};
            }
            currentLevel = currentLevel[parts[i]] as Map<String, dynamic>;
          }
        }
      }
    });

    return searchBy;
  }

  Map<String, dynamic> convertOrderBy(Map<String, dynamic> input) {
    // Estrai columnId e mode
    String columnId = input['columnId']!;
    String mode = input['mode'] == 'DESC' ? 'desc' : 'asc';

    // Dividi columnId in base ai ':'
    List<String> parts = columnId.split(':');
    Map<String, dynamic> orderBy = {};

    if (parts.length == 1) {
      // Campo diretto del modello
      orderBy[columnId] = mode;
    } else {
      // Nidificazione delle relazioni
      Map<String, dynamic> currentLevel = orderBy;

      for (int i = 0; i < parts.length; i++) {
        if (i == parts.length - 1) {
          // Ultimo elemento, aggiungi mode
          currentLevel[parts[i]] = mode;
        } else {
          // Crea un nuovo livello di nidificazione
          currentLevel[parts[i]] = <String, dynamic>{};
          currentLevel = currentLevel[parts[i]] as Map<String, dynamic>;
        }
      }
    }

    return orderBy;
  }

  void _handleResponse(ApiCallResponse response, BuildContext? context) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      final errorState = context?.read<ErrorState>();
      final currentRoute = GoRouter.of(context!).routerDelegate.currentConfiguration.uri.toString();
      errorState?.setError(code: response.statusCode, detail: currentRoute);
    }
  }

  Future<ApiCallResponse> makeApiCall({
    required String apiUrl,
    required BuildContext context,
    required ApiCallType callType,
    Map<String, dynamic> headers = const {},
    Map<String, dynamic> params = const {},
    String? body,
    BodyType? bodyType = BodyType.JSON,
    bool returnBody = true,
    bool encodeBodyUtf8 = false,
    bool decodeUtf8 = false,
    bool needAuth = false,
    bool needTenant = false,
    bool showSuccessMessage = false,
    bool showErrorMessage = true,
    String? successMessage,
    bool replaceApiUrl = false,
    String? completeApiUrl,
  }) async {
    headers = await initHeader(headers, needAuth, needTenant, context);

    // Se replaceApiUrl è true e c'è completeApiUrl, usa quello
    if (replaceApiUrl && completeApiUrl != null && completeApiUrl.isNotEmpty) {
      apiUrl = completeApiUrl;
    } else {
      apiUrl = AppConstants.baseUrl + apiUrl;
      if (!apiUrl.startsWith('http')) {
        apiUrl = 'https://$apiUrl';
      }
    }
    ApiCallResponse result;
    switch (callType) {
      case ApiCallType.GET:
      case ApiCallType.DELETE:
        result = await urlRequest(callType, apiUrl, headers, params, returnBody, decodeUtf8);
        break;
      case ApiCallType.POST:
      case ApiCallType.PUT:
      case ApiCallType.PATCH:
        result = await requestWithBody(callType, apiUrl, headers, params, body, bodyType, returnBody, encodeBodyUtf8, decodeUtf8);
        break;
    }

    if (result.succeeded) {
      if (showSuccessMessage) {
        AlertManager.showSuccess("Successo", successMessage ?? "Operazione completata con successo", alertPosition: AlertPosition.bottom);
      }
    } else {
      // Gestisci 401 e 403 tramite ErrorState e redirect
      _handleResponse(result, context);

      // Non mostrare alert per 401 e 403, vengono gestiti dalla pagina di errore
      if (result.statusCode != 401 && result.statusCode != 403 && showErrorMessage) {
        AlertManager.showDanger(
          "${result.error?.statusCode ?? 'N/A'}:${result.error?.error ?? 'Errore'}",
          result.error?.message ?? "Errore Generico",
          alertPosition: AlertPosition.bottom,
        );
      }
    }
    return result;
  }
}

class Pagination {
  int? total;
  int? lastPage;
  int? currentPage;
  int? perPage;
  int? prev;
  int? next;

  Pagination();

  factory Pagination.fromJson({required dynamic jsonObject}) {
    final pagination = Pagination();
    pagination.total = jsonObject['total'];
    pagination.lastPage = jsonObject['lastPage'];
    pagination.currentPage = jsonObject['currentPage'];
    pagination.perPage = jsonObject['perPage'];
    pagination.prev = jsonObject['prev'];
    pagination.next = jsonObject['next'];
    return pagination;
  }
}
