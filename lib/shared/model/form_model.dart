// To parse this JSON data, do
//
//     final formPage = formPageFromJson(jsonString);

import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'form_model.g.dart';

List<PageInfo> formPageFromJson(String str) => List<PageInfo>.from(json.decode(str).map((x) => PageInfo.fromJson(x)));

String formPageToJson(List<PageInfo> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@JsonSerializable()
class PageInfo {
  @JsonKey(name: "pageId")
  String? pageId;
  @JsonKey(name: "applicationId")
  String? applicationId;
  @JsonKey(name: "pageName")
  String? pageName;
  @JsonKey(name: "description")
  String? description;
  @JsonKey(name: "themeId")
  dynamic themeId;
  @JsonKey(name: "pageConfig")
  PageConfig? pageConfig;
  @JsonKey(name: "icon")
  String? icon;
  @JsonKey(name: "isActive")
  bool? isActive;
  @JsonKey(name: "createdBy")
  String? createdBy;
  @JsonKey(name: "createdDate")
  String? createdDate;
  @JsonKey(name: "lastModifiedBy")
  String? lastModifiedBy;
  @JsonKey(name: "lastModifiedDate")
  String? lastModifiedDate;
  @JsonKey(name: "pageVersion")
  int? pageVersion;
  @JsonKey(name: "pageType")
  String? pageType;
  @JsonKey(name: "is_published")
  bool? isPublished;
  @JsonKey(name: "forms")
  List<PageForm> forms;

  PageInfo({
    this.pageId,
    this.applicationId,
    this.pageName,
    this.description,
    this.themeId,
    this.pageConfig,
    this.icon,
    this.isActive,
    this.createdBy,
    this.createdDate,
    this.lastModifiedBy,
    this.lastModifiedDate,
    this.pageVersion,
    this.pageType,
    this.isPublished,
    required this.forms,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) => _$PageInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PageInfoToJson(this);
}

@JsonSerializable()
class PageForm {
  @JsonKey(name: "formId")
  String formId;
  @JsonKey(name: "applicationId")
  String applicationId;
  @JsonKey(name: "pageId")
  String pageId;
  @JsonKey(name: "formLabel")
  String formLabel;
  @JsonKey(name: "formKey")
  String formKey;
  @JsonKey(name: "formVersion")
  int? formVersion;
  @JsonKey(name: "entityKey")
  String? entityKey;
  @JsonKey(name: "parentEntityKey")
  String? parentEntityKey;
  @JsonKey(name: "formConfig")
  FormConfig? formConfig;
  @JsonKey(name: "createdByUUID")
  String? createdByUuid;
  @JsonKey(name: "createdDate")
  String? createdDate;
  @JsonKey(name: "lastModifiedByUUID")
  String? lastModifiedByUuid;
  @JsonKey(name: "lastModifiedDate")
  String? lastModifiedDate;
  @JsonKey(name: "isActive")
  bool? isActive;
  @JsonKey(name: "is_published")
  bool? isPublished;
  @JsonKey(name: "widgets")
  List<WidgetInfo> widgets;

  PageForm({
    required this.formId,
    required this.applicationId,
    required this.pageId,
    required this.formLabel,
    required this.formKey,
    required this.formVersion,
    required this.entityKey,
    required this.parentEntityKey,
    this.formConfig,
    this.createdByUuid,
    this.createdDate,
    this.lastModifiedByUuid,
    this.lastModifiedDate,
    this.isActive,
    this.isPublished,
    required this.widgets,
  });

  factory PageForm.fromJson(Map<String, dynamic> json) => _$PageFormFromJson(json);

  Map<String, dynamic> toJson() => _$PageFormToJson(this);
}

@JsonSerializable()
class FormConfig {
  @JsonKey(name: "style")
  FormConfigStyle? style;
  @JsonKey(name: "actions")
  dynamic actions;
  @JsonKey(name: "formType")
  String? formType;
  @JsonKey(name: "formsWidgets")
  List<String>? formsWidgets;
  @JsonKey(name: "customStyleApplied")
  bool? customStyleApplied;
  @JsonKey(name: "enable")
  bool? enable;

  FormConfig({
    this.style,
    this.actions,
    this.formType,
    this.formsWidgets,
    this.customStyleApplied,
    this.enable,
  });

  factory FormConfig.fromJson(Map<String, dynamic> json) => _$FormConfigFromJson(json);

  Map<String, dynamic> toJson() => _$FormConfigToJson(this);
}

@JsonSerializable()
class ActionsClass {
  ActionsClass();

  factory ActionsClass.fromJson(Map<String, dynamic> json) => _$ActionsClassFromJson(json);

  Map<String, dynamic> toJson() => _$ActionsClassToJson(this);
}

@JsonSerializable()
class FormConfigStyle {
  @JsonKey(name: "backgroundColor")
  String? backgroundColor;

  FormConfigStyle({
    this.backgroundColor,
  });

  factory FormConfigStyle.fromJson(Map<String, dynamic> json) => _$FormConfigStyleFromJson(json);

  Map<String, dynamic> toJson() => _$FormConfigStyleToJson(this);
}

@JsonSerializable()
class WidgetInfo {
  @JsonKey(name: "widgetId")
  String widgetId;
  @JsonKey(name: "masterWidgetId")
  String masterWidgetId;
  @JsonKey(name: "formId")
  String formId;
  @JsonKey(name: "applicationId")
  String applicationId;
  @JsonKey(name: "widgetLabel")
  String widgetLabel;
  @JsonKey(name: "widgetKey")
  String widgetKey;
  @JsonKey(name: "widgetType")
  String widgetType;
  @JsonKey(name: "widgetConfig")
  WidgetConfig widgetConfig;
  @JsonKey(name: "widgetDataSource")
  WidgetDataSource widgetDataSource;
  @JsonKey(name: "isActive")
  bool? isActive;
  @JsonKey(name: "createdByUUID")
  String? createdByUuid;
  @JsonKey(name: "createdDate")
  String? createdDate;
  @JsonKey(name: "lastModifiedByUUID")
  String? lastModifiedByUuid;
  @JsonKey(name: "lastModifiedDate")
  String? lastModifiedDate;
  @JsonKey(name: "is_published")
  bool? isPublished;

  WidgetInfo({
    required this.widgetId,
    required this.masterWidgetId,
    required this.formId,
    required this.applicationId,
    required this.widgetLabel,
    required this.widgetKey,
    required this.widgetType,
    required this.widgetConfig,
    required this.widgetDataSource,
    required this.isActive,
    this.createdByUuid,
    this.createdDate,
    this.lastModifiedByUuid,
    this.lastModifiedDate,
    this.isPublished,
  });

  factory WidgetInfo.fromJson(Map<String, dynamic> json) => _$WidgetInfoFromJson(json);

  Map<String, dynamic> toJson() => _$WidgetInfoToJson(this);
}

@JsonSerializable()
class WidgetConfig {
  @JsonKey(name: "image")
  String? image;
  @JsonKey(name: "label")
  String? label;
  @JsonKey(name: "style")
  WidgetConfigStyle style;
  @JsonKey(name: "enable")
  bool? enable;
  @JsonKey(name: "actions")
  dynamic actions;
  @JsonKey(name: "element")
  ActionsClass? element;
  @JsonKey(name: "additionalConfig")
  AdditionalConfig? additionalConfig;
  @JsonKey(name: "showDeletebutton")
  bool? showDeletebutton;
  @JsonKey(name: "customStyleApplied")
  bool? customStyleApplied;
  @JsonKey(name: "matUiType")
  String? matUiType;
  @JsonKey(name: "type")
  dynamic type;
  @JsonKey(name: "showlabel")
  bool? showlabel;
  @JsonKey(name: "validations")
  List<Validations>? validations;
  @JsonKey(name: "placeholderText")
  String? placeholderText;
  @JsonKey(name: "enabled")
  bool? enabled;
  @JsonKey(name: "default")
  String? widgetConfigDefault;
  @JsonKey(name: "referencedWidgets")
  List<String>? referencedWidgets;
  @JsonKey(name: "default_widget_type")
  String? defaultWidgetType;
  @JsonKey(name: "previewPageId")
  String? previewPageId;
  @JsonKey(name: "dataListViewPageId")
  String? dataListViewPageId;
  @JsonKey(name: "dataListWidgetConfig")
  DataListWidgetConfig? dataListWidgetConfig;

  WidgetConfig({
    this.image,
    this.label,
    required this.style,
    this.enable,
    this.actions,
    this.element,
    this.additionalConfig,
    this.showDeletebutton,
    this.customStyleApplied,
    this.matUiType,
    this.type,
    this.showlabel,
    required this.validations,
    this.placeholderText,
    this.enabled,
    this.widgetConfigDefault,
    this.referencedWidgets,
    this.defaultWidgetType,
    this.previewPageId,
    this.dataListViewPageId,
    this.dataListWidgetConfig,
  });

  factory WidgetConfig.fromJson(Map<String, dynamic> json) => _$WidgetConfigFromJson(json);

  Map<String, dynamic> toJson() => _$WidgetConfigToJson(this);
}

@JsonSerializable()
class Action {
  @JsonKey(name: "action_type")
  String? actionType;
  @JsonKey(name: "conditional_clause")
  List<ConditionalClause>? conditionalClause;

  Action({
    this.actionType,
    this.conditionalClause,
  });

  factory Action.fromJson(Map<String, dynamic> json) => _$ActionFromJson(json);

  Map<String, dynamic> toJson() => _$ActionToJson(this);
}

@JsonSerializable()
class ConditionalClause {
  @JsonKey(name: "action")
  String? action;
  @JsonKey(name: "La2-from1-Sa2")
  List<String>? la2From1Sa2;
  @JsonKey(name: "parameters")
  List<dynamic>? parameters;
  @JsonKey(name: "La2-from1-Dr3")
  List<String>? la2From1Dr3;
  @JsonKey(name: "La2-from1-Sa3")
  List<String>? la2From1Sa3;
  @JsonKey(name: "add user 10-form0-Na1")
  List<String>? addUser10Form0Na1;
  @JsonKey(name: "ad3-from1-Sa7")
  List<String>? ad3From1Sa7;
  @JsonKey(name: "add user 20-form0-Na1")
  List<String>? addUser20Form0Na1;
  @JsonKey(name: "ad4-from1-Sa6")
  List<String>? ad4From1Sa6;
  @JsonKey(name: "view user0-form0-Na1")
  List<String>? viewUser0Form0Na1;
  @JsonKey(name: "view user 10-form0-Na1")
  List<String>? viewUser10Form0Na1;
  @JsonKey(name: "D8-form1-Na1")
  List<String>? d8Form1Na1;

  ConditionalClause({
    this.action,
    this.la2From1Sa2,
    this.parameters,
    this.la2From1Dr3,
    this.la2From1Sa3,
    this.addUser10Form0Na1,
    this.ad3From1Sa7,
    this.addUser20Form0Na1,
    this.ad4From1Sa6,
    this.viewUser0Form0Na1,
    this.viewUser10Form0Na1,
    this.d8Form1Na1,
  });

  factory ConditionalClause.fromJson(Map<String, dynamic> json) => _$ConditionalClauseFromJson(json);

  Map<String, dynamic> toJson() => _$ConditionalClauseToJson(this);
}

@JsonSerializable()
class Validations {
  @JsonKey(name: "error_message")
  String? errorMessage;
  @JsonKey(name: "validation_key")
  String? validationKey;
  @JsonKey(name: "validation_type")
  String? validationType;
  @JsonKey(name: "validation_value")
  String? validationValue;

  Validations({
    this.errorMessage,
    this.validationKey,
    this.validationType,
    this.validationValue,
  });

  factory Validations.fromJson(Map<String, dynamic> json) => _$ValidationsFromJson(json);

  Map<String, dynamic> toJson() => _$ValidationsToJson(this);
}

@JsonSerializable()
class AdditionalConfig {
  @JsonKey(name: "maxSize")
  int? maxSize;
  @JsonKey(name: "uploadType")
  String? uploadType;
  @JsonKey(name: "maxImageSize")
  int? maxImageSize;
  @JsonKey(name: "imageCompression")
  bool? imageCompression;
  @JsonKey(name: "allowedImageTypes")
  List<String>? allowedImageTypes;
  @JsonKey(name: "dateFormat")
  String? dateFormat;
  @JsonKey(name: "futureDays")
  int? futureDays;
  @JsonKey(name: "historicalDays")
  int? historicalDays;
  @JsonKey(name: "dateRangeEnable")
  bool? dateRangeEnable;
  @JsonKey(name: "Compression")
  bool? compression;
  @JsonKey(name: "gpsAccuracy")
  dynamic gpsAccuracy;
  @JsonKey(name: "GeoReference")
  bool? geoReference;
  @JsonKey(name: "allowedTypes")
  List<String>? allowedTypes;
  @JsonKey(name: "baringToggle")
  bool? baringToggle;
  @JsonKey(name: "GalleryUpload")
  bool? galleryUpload;
  @JsonKey(name: "fileType")
  List<String>? fileType;
  @JsonKey(name: "fileCompression")
  bool? fileCompression;

  AdditionalConfig({
    this.maxSize,
    this.uploadType,
    this.maxImageSize,
    this.imageCompression,
    this.allowedImageTypes,
    this.dateFormat,
    this.futureDays,
    this.historicalDays,
    this.dateRangeEnable,
    this.compression,
    this.gpsAccuracy,
    this.geoReference,
    this.allowedTypes,
    this.baringToggle,
    this.galleryUpload,
    this.fileType,
    this.fileCompression,
  });

  factory AdditionalConfig.fromJson(Map<String, dynamic> json) => _$AdditionalConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AdditionalConfigToJson(this);
}

@JsonSerializable()
class DataListWidgetConfig {
  @JsonKey(name: "type")
  String? type;
  @JsonKey(name: "entityId")
  String? entityId;
  @JsonKey(name: "lhsItems")
  List<HsItem>? lhsItems;
  @JsonKey(name: "rhsItems")
  List<HsItem>? rhsItems;
  @JsonKey(name: "listOfWidgetsOfEntity")
  List<ListOfWidgetsOfEntity>? listOfWidgetsOfEntity;

  DataListWidgetConfig({
    this.type,
    this.entityId,
    this.lhsItems,
    this.rhsItems,
    this.listOfWidgetsOfEntity,
  });

  factory DataListWidgetConfig.fromJson(Map<String, dynamic> json) => _$DataListWidgetConfigFromJson(json);

  Map<String, dynamic> toJson() => _$DataListWidgetConfigToJson(this);
}

@JsonSerializable()
class HsItem {
  @JsonKey(name: "widgetId")
  String? widgetId;
  @JsonKey(name: "widgetLabel")
  String? widgetLabel;
  @JsonKey(name: "widget_type")
  String? widgetType;

  HsItem({
    this.widgetId,
    this.widgetLabel,
    this.widgetType,
  });

  factory HsItem.fromJson(Map<String, dynamic> json) => _$HsItemFromJson(json);

  Map<String, dynamic> toJson() => _$HsItemToJson(this);
}

@JsonSerializable()
class ListOfWidgetsOfEntity {
  @JsonKey(name: "show")
  bool? show;
  @JsonKey(name: "widgetId")
  String? widgetId;
  @JsonKey(name: "widgetType")
  String? widgetType;
  @JsonKey(name: "widgetLabel")
  String? widgetLabel;

  ListOfWidgetsOfEntity({
    this.show,
    this.widgetId,
    this.widgetType,
    this.widgetLabel,
  });

  factory ListOfWidgetsOfEntity.fromJson(Map<String, dynamic> json) => _$ListOfWidgetsOfEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ListOfWidgetsOfEntityToJson(this);
}

@JsonSerializable()
class WidgetConfigStyle {
  @JsonKey(name: "margin-top")
  String? marginTop;
  @JsonKey(name: "font-size")
  String? fontSize;
  @JsonKey(name: "font-style")
  String? fontStyle;
  @JsonKey(name: "text-align")
  String? textAlign;
  @JsonKey(name: "font-weight")
  String? fontWeight;
  @JsonKey(name: "text-decoration")
  String? textDecoration;
  @JsonKey(name: "color")
  String? color;
  @JsonKey(name: "width")
  String? width;
  @JsonKey(name: "margin-left")
  String? marginLeft;
  @JsonKey(name: "backgroundColor")
  String? backgroundColor;
  @JsonKey(name: "size")
  String? size;

  WidgetConfigStyle({
    this.marginTop,
    this.fontSize,
    this.fontStyle,
    this.textAlign,
    this.fontWeight,
    this.textDecoration,
    this.color,
    this.width,
    this.marginLeft,
    this.backgroundColor,
    this.size,
  });

  factory WidgetConfigStyle.fromJson(Map<String, dynamic> json) => _$WidgetConfigStyleFromJson(json);

  Map<String, dynamic> toJson() => _$WidgetConfigStyleToJson(this);
}

@JsonSerializable()
class WidgetDataSource {
  @JsonKey(name: "method")
  String? method;
  @JsonKey(name: "preview")
  bool? preview;
  @JsonKey(name: "datasource")
  dynamic datasource;
  @JsonKey(name: "Authorization")
  Authorization? authorization;
  @JsonKey(name: "datasourceType")
  String? datasourceType;
  @JsonKey(name: "request-parameter")
  List<dynamic>? requestParameter;
  @JsonKey(name: "response-parameter")
  dynamic responseParameter;

  WidgetDataSource({
    this.method,
    this.preview,
    this.datasource,
    this.authorization,
    this.datasourceType,
    this.requestParameter,
    this.responseParameter,
  });

  factory WidgetDataSource.fromJson(Map<String, dynamic> json) => _$WidgetDataSourceFromJson(json);

  Map<String, dynamic> toJson() => _$WidgetDataSourceToJson(this);
}

@JsonSerializable()
class Authorization {
  @JsonKey(name: "auth")
  String? auth;
  @JsonKey(name: "api-key")
  String? apiKey;
  @JsonKey(name: "auth-api-url")
  String? authApiUrl;

  Authorization({
    this.auth,
    this.apiKey,
    this.authApiUrl,
  });

  factory Authorization.fromJson(Map<String, dynamic> json) => _$AuthorizationFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorizationToJson(this);
}

@JsonSerializable()
class DatasourceElement {
  @JsonKey(name: "key")
  String? key;
  @JsonKey(name: "label")
  String? label;

  DatasourceElement({
    this.key,
    this.label,
  });

  factory DatasourceElement.fromJson(Map<String, dynamic> json) => _$DatasourceElementFromJson(json);

  Map<String, dynamic> toJson() => _$DatasourceElementToJson(this);
}

@JsonSerializable()
class PageConfig {
  @JsonKey(name: "forms")
  List<dynamic>? forms;
  @JsonKey(name: "style")
  FormConfigStyle? style;
  @JsonKey(name: "actions")
  dynamic actions;
  @JsonKey(name: "pageForms")
  List<String>? pageForms;
  @JsonKey(name: "additionalConfig")
  ActionsClass? additionalConfig;
  @JsonKey(name: "previewPageId")
  String? previewPageId;
  @JsonKey(name: "pageIdsList")
  List<String>? pageIdsList;

  PageConfig({
    this.forms,
    this.style,
    this.actions,
    this.pageForms,
    this.additionalConfig,
    this.previewPageId,
    this.pageIdsList,
  });

  factory PageConfig.fromJson(Map<String, dynamic> json) => _$PageConfigFromJson(json);

  Map<String, dynamic> toJson() => _$PageConfigToJson(this);
}
