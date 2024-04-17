// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageInfo _$PageInfoFromJson(Map<String, dynamic> json) => PageInfo(
      pageId: json['pageId'] as String?,
      applicationId: json['applicationId'] as String?,
      pageName: json['pageName'] as String?,
      description: json['description'] as String?,
      themeId: json['themeId'],
      pageConfig: json['pageConfig'] == null
          ? null
          : PageConfig.fromJson(json['pageConfig'] as Map<String, dynamic>),
      icon: json['icon'] as String?,
      isActive: json['isActive'] as bool?,
      createdBy: json['createdBy'] as String?,
      createdDate: json['createdDate'] as String?,
      lastModifiedBy: json['lastModifiedBy'] as String?,
      lastModifiedDate: json['lastModifiedDate'] as String?,
      pageVersion: json['pageVersion'] as int?,
      pageType: json['pageType'] as String?,
      isPublished: json['is_published'] as bool?,
      forms: (json['forms'] as List<dynamic>)
          .map((e) => PageForm.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PageInfoToJson(PageInfo instance) => <String, dynamic>{
      'pageId': instance.pageId,
      'applicationId': instance.applicationId,
      'pageName': instance.pageName,
      'description': instance.description,
      'themeId': instance.themeId,
      'pageConfig': instance.pageConfig,
      'icon': instance.icon,
      'isActive': instance.isActive,
      'createdBy': instance.createdBy,
      'createdDate': instance.createdDate,
      'lastModifiedBy': instance.lastModifiedBy,
      'lastModifiedDate': instance.lastModifiedDate,
      'pageVersion': instance.pageVersion,
      'pageType': instance.pageType,
      'is_published': instance.isPublished,
      'forms': instance.forms,
    };

PageForm _$PageFormFromJson(Map<String, dynamic> json) => PageForm(
      formId: json['formId'] as String,
      applicationId: json['applicationId'] as String,
      pageId: json['pageId'] as String,
      formLabel: json['formLabel'] as String,
      formKey: json['formKey'] as String,
      formVersion: json['formVersion'] as int?,
      entityKey: json['entityKey'] as String?,
      parentEntityKey: json['parentEntityKey'] as String?,
      formConfig: json['formConfig'] == null
          ? null
          : FormConfig.fromJson(json['formConfig'] as Map<String, dynamic>),
      createdByUuid: json['createdByUUID'] as String?,
      createdDate: json['createdDate'] as String?,
      lastModifiedByUuid: json['lastModifiedByUUID'] as String?,
      lastModifiedDate: json['lastModifiedDate'] as String?,
      isActive: json['isActive'] as bool?,
      isPublished: json['is_published'] as bool?,
      widgets: (json['widgets'] as List<dynamic>)
          .map((e) => WidgetInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PageFormToJson(PageForm instance) => <String, dynamic>{
      'formId': instance.formId,
      'applicationId': instance.applicationId,
      'pageId': instance.pageId,
      'formLabel': instance.formLabel,
      'formKey': instance.formKey,
      'formVersion': instance.formVersion,
      'entityKey': instance.entityKey,
      'parentEntityKey': instance.parentEntityKey,
      'formConfig': instance.formConfig,
      'createdByUUID': instance.createdByUuid,
      'createdDate': instance.createdDate,
      'lastModifiedByUUID': instance.lastModifiedByUuid,
      'lastModifiedDate': instance.lastModifiedDate,
      'isActive': instance.isActive,
      'is_published': instance.isPublished,
      'widgets': instance.widgets,
    };

FormConfig _$FormConfigFromJson(Map<String, dynamic> json) => FormConfig(
      style: json['style'] == null
          ? null
          : FormConfigStyle.fromJson(json['style'] as Map<String, dynamic>),
      actions: json['actions'],
      formType: json['formType'] as String?,
      formsWidgets: (json['formsWidgets'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      customStyleApplied: json['customStyleApplied'] as bool?,
      enable: json['enable'] as bool?,
    );

Map<String, dynamic> _$FormConfigToJson(FormConfig instance) =>
    <String, dynamic>{
      'style': instance.style,
      'actions': instance.actions,
      'formType': instance.formType,
      'formsWidgets': instance.formsWidgets,
      'customStyleApplied': instance.customStyleApplied,
      'enable': instance.enable,
    };

ActionsClass _$ActionsClassFromJson(Map<String, dynamic> json) =>
    ActionsClass();

Map<String, dynamic> _$ActionsClassToJson(ActionsClass instance) =>
    <String, dynamic>{};

FormConfigStyle _$FormConfigStyleFromJson(Map<String, dynamic> json) =>
    FormConfigStyle(
      backgroundColor: json['backgroundColor'] as String?,
    );

Map<String, dynamic> _$FormConfigStyleToJson(FormConfigStyle instance) =>
    <String, dynamic>{
      'backgroundColor': instance.backgroundColor,
    };

WidgetInfo _$WidgetInfoFromJson(Map<String, dynamic> json) => WidgetInfo(
      widgetId: json['widgetId'] as String,
      masterWidgetId: json['masterWidgetId'] as String,
      formId: json['formId'] as String,
      applicationId: json['applicationId'] as String,
      widgetLabel: json['widgetLabel'] as String,
      widgetKey: json['widgetKey'] as String,
      widgetType: json['widgetType'] as String,
      widgetConfig:
          WidgetConfig.fromJson(json['widgetConfig'] as Map<String, dynamic>),
      widgetDataSource: WidgetDataSource.fromJson(
          json['widgetDataSource'] as Map<String, dynamic>),
      isActive: json['isActive'] as bool?,
      createdByUuid: json['createdByUUID'] as String?,
      createdDate: json['createdDate'] as String?,
      lastModifiedByUuid: json['lastModifiedByUUID'] as String?,
      lastModifiedDate: json['lastModifiedDate'] as String?,
      isPublished: json['is_published'] as bool?,
    );

Map<String, dynamic> _$WidgetInfoToJson(WidgetInfo instance) =>
    <String, dynamic>{
      'widgetId': instance.widgetId,
      'masterWidgetId': instance.masterWidgetId,
      'formId': instance.formId,
      'applicationId': instance.applicationId,
      'widgetLabel': instance.widgetLabel,
      'widgetKey': instance.widgetKey,
      'widgetType': instance.widgetType,
      'widgetConfig': instance.widgetConfig,
      'widgetDataSource': instance.widgetDataSource,
      'isActive': instance.isActive,
      'createdByUUID': instance.createdByUuid,
      'createdDate': instance.createdDate,
      'lastModifiedByUUID': instance.lastModifiedByUuid,
      'lastModifiedDate': instance.lastModifiedDate,
      'is_published': instance.isPublished,
    };

WidgetConfig _$WidgetConfigFromJson(Map<String, dynamic> json) => WidgetConfig(
      image: json['image'] as String?,
      label: json['label'] as String?,
      style: WidgetConfigStyle.fromJson(json['style'] as Map<String, dynamic>),
      enable: json['enable'] as bool?,
      actions: json['actions'],
      element: json['element'] == null
          ? null
          : ActionsClass.fromJson(json['element'] as Map<String, dynamic>),
      additionalConfig: json['additionalConfig'] == null
          ? null
          : AdditionalConfig.fromJson(
              json['additionalConfig'] as Map<String, dynamic>),
      showDeletebutton: json['showDeletebutton'] as bool?,
      customStyleApplied: json['customStyleApplied'] as bool?,
      matUiType: json['matUiType'] as String?,
      type: json['type'],
      showlabel: json['showlabel'] as bool?,
      validations: (json['validations'] as List<dynamic>?)
          ?.map((e) => Validations.fromJson(e as Map<String, dynamic>))
          .toList(),
      placeholderText: json['placeholderText'] as String?,
      enabled: json['enabled'] as bool?,
      widgetConfigDefault: json['default'] as String?,
      referencedWidgets: (json['referencedWidgets'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      defaultWidgetType: json['default_widget_type'] as String?,
      previewPageId: json['previewPageId'] as String?,
      dataListViewPageId: json['dataListViewPageId'] as String?,
      dataListWidgetConfig: json['dataListWidgetConfig'] == null
          ? null
          : DataListWidgetConfig.fromJson(
              json['dataListWidgetConfig'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WidgetConfigToJson(WidgetConfig instance) =>
    <String, dynamic>{
      'image': instance.image,
      'label': instance.label,
      'style': instance.style,
      'enable': instance.enable,
      'actions': instance.actions,
      'element': instance.element,
      'additionalConfig': instance.additionalConfig,
      'showDeletebutton': instance.showDeletebutton,
      'customStyleApplied': instance.customStyleApplied,
      'matUiType': instance.matUiType,
      'type': instance.type,
      'showlabel': instance.showlabel,
      'validations': instance.validations,
      'placeholderText': instance.placeholderText,
      'enabled': instance.enabled,
      'default': instance.widgetConfigDefault,
      'referencedWidgets': instance.referencedWidgets,
      'default_widget_type': instance.defaultWidgetType,
      'previewPageId': instance.previewPageId,
      'dataListViewPageId': instance.dataListViewPageId,
      'dataListWidgetConfig': instance.dataListWidgetConfig,
    };

Action _$ActionFromJson(Map<String, dynamic> json) => Action(
      actionType: json['action_type'] as String?,
      conditionalClause: (json['conditional_clause'] as List<dynamic>?)
          ?.map((e) => ConditionalClause.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ActionToJson(Action instance) => <String, dynamic>{
      'action_type': instance.actionType,
      'conditional_clause': instance.conditionalClause,
    };

ConditionalClause _$ConditionalClauseFromJson(Map<String, dynamic> json) =>
    ConditionalClause(
      action: json['action'] as String?,
      la2From1Sa2: (json['La2-from1-Sa2'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      parameters: json['parameters'] as List<dynamic>?,
      la2From1Dr3: (json['La2-from1-Dr3'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      la2From1Sa3: (json['La2-from1-Sa3'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      addUser10Form0Na1: (json['add user 10-form0-Na1'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      ad3From1Sa7: (json['ad3-from1-Sa7'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      addUser20Form0Na1: (json['add user 20-form0-Na1'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      ad4From1Sa6: (json['ad4-from1-Sa6'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      viewUser0Form0Na1: (json['view user0-form0-Na1'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      viewUser10Form0Na1: (json['view user 10-form0-Na1'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      d8Form1Na1: (json['D8-form1-Na1'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ConditionalClauseToJson(ConditionalClause instance) =>
    <String, dynamic>{
      'action': instance.action,
      'La2-from1-Sa2': instance.la2From1Sa2,
      'parameters': instance.parameters,
      'La2-from1-Dr3': instance.la2From1Dr3,
      'La2-from1-Sa3': instance.la2From1Sa3,
      'add user 10-form0-Na1': instance.addUser10Form0Na1,
      'ad3-from1-Sa7': instance.ad3From1Sa7,
      'add user 20-form0-Na1': instance.addUser20Form0Na1,
      'ad4-from1-Sa6': instance.ad4From1Sa6,
      'view user0-form0-Na1': instance.viewUser0Form0Na1,
      'view user 10-form0-Na1': instance.viewUser10Form0Na1,
      'D8-form1-Na1': instance.d8Form1Na1,
    };

Validations _$ValidationsFromJson(Map<String, dynamic> json) => Validations(
      errorMessage: json['error_message'] as String?,
      validationKey: json['validation_key'] as String?,
      validationType: json['validation_type'] as String?,
      validationValue: json['validation_value'] as String?,
    );

Map<String, dynamic> _$ValidationsToJson(Validations instance) =>
    <String, dynamic>{
      'error_message': instance.errorMessage,
      'validation_key': instance.validationKey,
      'validation_type': instance.validationType,
      'validation_value': instance.validationValue,
    };

AdditionalConfig _$AdditionalConfigFromJson(Map<String, dynamic> json) =>
    AdditionalConfig(
      maxSize: json['maxSize'] as int?,
      uploadType: json['uploadType'] as String?,
      maxImageSize: json['maxImageSize'] as int?,
      imageCompression: json['imageCompression'] as bool?,
      allowedImageTypes: (json['allowedImageTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      dateFormat: json['dateFormat'] as String?,
      futureDays: json['futureDays'] as int?,
      historicalDays: json['historicalDays'] as int?,
      dateRangeEnable: json['dateRangeEnable'] as bool?,
      compression: json['Compression'] as bool?,
      gpsAccuracy: json['gpsAccuracy'],
      geoReference: json['GeoReference'] as bool?,
      allowedTypes: (json['allowedTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      baringToggle: json['baringToggle'] as bool?,
      galleryUpload: json['GalleryUpload'] as bool?,
      fileType: (json['fileType'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      fileCompression: json['fileCompression'] as bool?,
    );

Map<String, dynamic> _$AdditionalConfigToJson(AdditionalConfig instance) =>
    <String, dynamic>{
      'maxSize': instance.maxSize,
      'uploadType': instance.uploadType,
      'maxImageSize': instance.maxImageSize,
      'imageCompression': instance.imageCompression,
      'allowedImageTypes': instance.allowedImageTypes,
      'dateFormat': instance.dateFormat,
      'futureDays': instance.futureDays,
      'historicalDays': instance.historicalDays,
      'dateRangeEnable': instance.dateRangeEnable,
      'Compression': instance.compression,
      'gpsAccuracy': instance.gpsAccuracy,
      'GeoReference': instance.geoReference,
      'allowedTypes': instance.allowedTypes,
      'baringToggle': instance.baringToggle,
      'GalleryUpload': instance.galleryUpload,
      'fileType': instance.fileType,
      'fileCompression': instance.fileCompression,
    };

DataListWidgetConfig _$DataListWidgetConfigFromJson(
        Map<String, dynamic> json) =>
    DataListWidgetConfig(
      type: json['type'] as String?,
      entityId: json['entityId'] as String?,
      lhsItems: (json['lhsItems'] as List<dynamic>?)
          ?.map((e) => HsItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      rhsItems: (json['rhsItems'] as List<dynamic>?)
          ?.map((e) => HsItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      listOfWidgetsOfEntity: (json['listOfWidgetsOfEntity'] as List<dynamic>?)
          ?.map(
              (e) => ListOfWidgetsOfEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DataListWidgetConfigToJson(
        DataListWidgetConfig instance) =>
    <String, dynamic>{
      'type': instance.type,
      'entityId': instance.entityId,
      'lhsItems': instance.lhsItems,
      'rhsItems': instance.rhsItems,
      'listOfWidgetsOfEntity': instance.listOfWidgetsOfEntity,
    };

HsItem _$HsItemFromJson(Map<String, dynamic> json) => HsItem(
      widgetId: json['widgetId'] as String?,
      widgetLabel: json['widgetLabel'] as String?,
      widgetType: json['widget_type'] as String?,
    );

Map<String, dynamic> _$HsItemToJson(HsItem instance) => <String, dynamic>{
      'widgetId': instance.widgetId,
      'widgetLabel': instance.widgetLabel,
      'widget_type': instance.widgetType,
    };

ListOfWidgetsOfEntity _$ListOfWidgetsOfEntityFromJson(
        Map<String, dynamic> json) =>
    ListOfWidgetsOfEntity(
      show: json['show'] as bool?,
      widgetId: json['widgetId'] as String?,
      widgetType: json['widgetType'] as String?,
      widgetLabel: json['widgetLabel'] as String?,
    );

Map<String, dynamic> _$ListOfWidgetsOfEntityToJson(
        ListOfWidgetsOfEntity instance) =>
    <String, dynamic>{
      'show': instance.show,
      'widgetId': instance.widgetId,
      'widgetType': instance.widgetType,
      'widgetLabel': instance.widgetLabel,
    };

WidgetConfigStyle _$WidgetConfigStyleFromJson(Map<String, dynamic> json) =>
    WidgetConfigStyle(
      marginTop: json['margin-top'] as String?,
      fontSize: json['font-size'] as String?,
      fontStyle: json['font-style'] as String?,
      textAlign: json['text-align'] as String?,
      fontWeight: json['font-weight'] as String?,
      textDecoration: json['text-decoration'] as String?,
      color: json['color'] as String?,
      width: json['width'] as String?,
      marginLeft: json['margin-left'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
      size: json['size'] as String?,
    );

Map<String, dynamic> _$WidgetConfigStyleToJson(WidgetConfigStyle instance) =>
    <String, dynamic>{
      'margin-top': instance.marginTop,
      'font-size': instance.fontSize,
      'font-style': instance.fontStyle,
      'text-align': instance.textAlign,
      'font-weight': instance.fontWeight,
      'text-decoration': instance.textDecoration,
      'color': instance.color,
      'width': instance.width,
      'margin-left': instance.marginLeft,
      'backgroundColor': instance.backgroundColor,
      'size': instance.size,
    };

WidgetDataSource _$WidgetDataSourceFromJson(Map<String, dynamic> json) =>
    WidgetDataSource(
      method: json['method'] as String?,
      preview: json['preview'] as bool?,
      datasource: json['datasource'],
      authorization: json['Authorization'] == null
          ? null
          : Authorization.fromJson(
              json['Authorization'] as Map<String, dynamic>),
      datasourceType: json['datasourceType'] as String?,
      requestParameter: json['request-parameter'] as List<dynamic>?,
      responseParameter: json['response-parameter'],
    );

Map<String, dynamic> _$WidgetDataSourceToJson(WidgetDataSource instance) =>
    <String, dynamic>{
      'method': instance.method,
      'preview': instance.preview,
      'datasource': instance.datasource,
      'Authorization': instance.authorization,
      'datasourceType': instance.datasourceType,
      'request-parameter': instance.requestParameter,
      'response-parameter': instance.responseParameter,
    };

Authorization _$AuthorizationFromJson(Map<String, dynamic> json) =>
    Authorization(
      auth: json['auth'] as String?,
      apiKey: json['api-key'] as String?,
      authApiUrl: json['auth-api-url'] as String?,
    );

Map<String, dynamic> _$AuthorizationToJson(Authorization instance) =>
    <String, dynamic>{
      'auth': instance.auth,
      'api-key': instance.apiKey,
      'auth-api-url': instance.authApiUrl,
    };

DatasourceElement _$DatasourceElementFromJson(Map<String, dynamic> json) =>
    DatasourceElement(
      key: json['key'] as String?,
      label: json['label'] as String?,
    );

Map<String, dynamic> _$DatasourceElementToJson(DatasourceElement instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
    };

PageConfig _$PageConfigFromJson(Map<String, dynamic> json) => PageConfig(
      forms: json['forms'] as List<dynamic>?,
      style: json['style'] == null
          ? null
          : FormConfigStyle.fromJson(json['style'] as Map<String, dynamic>),
      actions: json['actions'],
      pageForms: (json['pageForms'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      additionalConfig: json['additionalConfig'] == null
          ? null
          : ActionsClass.fromJson(
              json['additionalConfig'] as Map<String, dynamic>),
      previewPageId: json['previewPageId'] as String?,
      pageIdsList: (json['pageIdsList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PageConfigToJson(PageConfig instance) =>
    <String, dynamic>{
      'forms': instance.forms,
      'style': instance.style,
      'actions': instance.actions,
      'pageForms': instance.pageForms,
      'additionalConfig': instance.additionalConfig,
      'previewPageId': instance.previewPageId,
      'pageIdsList': instance.pageIdsList,
    };