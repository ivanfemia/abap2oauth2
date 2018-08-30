class ZCL_OAUTH2_NATIVE_APP definition
  public
  create public .

*"* public components of class ZCL_OAUTH2_NATIVE_APP
*"* do not include other source files here!!!
public section.

  interfaces ZIF_OAUTH2
      data values SSL_ID = 'ANONYM' .

  data CONSUMER_NAME type ZOAUTH2_CONSUMER_NAME .
  data USER_NAME type ZOAUTH2_USER_NAME .
  data SCOPE type ZOAUTH2_API_HOST .

  methods CONSTRUCTOR
    importing
      !I_USER_NAME type ZOAUTH2_USER_NAME
      !I_CONSUMER_NAME type ZOAUTH2_CONSUMER_NAME
      !I_AUTH_HOST type ZOAUTH2_HOST
      !I_RET_REFRESH_TOKEN_HOST type ZOAUTH2_HOST
      !I_RET_REFRESH_TOKEN_REQU_URI type ZOAUTH2_HOST
      !I_RET_REFRESH_TOKEN_URL type ZOAUTH2_HOST
      !I_PROXY_HOST type STRING
      !I_PROXY_SERVICE type STRING
      !I_SSL_ID type SSFAPPLSSL .
protected section.
*"* protected components of class ZCL_OAUTH2_NATIVE_APP
*"* do not include other source files here!!!

  class-data RET_REFRESH_TOKEN_URL type ZOAUTH2_HOST .
  class-data RET_REFRESH_TOKEN_HOST type ZOAUTH2_HOST .
  class-data RET_REFRESH_TOKEN_REQUEST_URI type ZOAUTH2_HOST .
private section.
*"* private components of class ZCL_OAUTH2_NATIVE_APP
*"* do not include other source files here!!!

  data RESPONSE_TYPE type STRING .

  methods GET_REFRESH_TOKEN
    importing
      value(I_VERIFICATION_CODE) type ZOAUTH2_TOKEN .
ENDCLASS.



CLASS ZCL_OAUTH2_NATIVE_APP IMPLEMENTATION.


METHOD constructor.
  DATA: lv_count TYPE i.

  me->consumer_name             = i_consumer_name.
  me->user_name                 = i_user_name.
  ret_refresh_token_host        = i_ret_refresh_token_host.
  ret_refresh_token_request_uri = i_ret_refresh_token_requ_uri.
  ret_refresh_token_url         = i_ret_refresh_token_url.
  me->zif_oauth2~proxy_host     = i_proxy_host.
  me->zif_oauth2~proxy_service  = i_proxy_service.
  me->zif_oauth2~ssl_id         = i_ssl_id.


  SELECT COUNT(*) INTO lv_count FROM zoauth2_user WHERE consumer_name = i_consumer_name AND user_name = i_user_name.

  IF lv_count EQ 0.
    me->zif_oauth2~authorization_request( i_auth_host = i_auth_host ).

  ELSE.

  ENDIF.


ENDMETHOD.


method GET_REFRESH_TOKEN.

  DATA: client TYPE REF TO if_http_client,
        lv_cdata TYPE string,
        wa_consumer TYPE zoauth2_consumer,
        lv_json_doc TYPE REF TO zcl_json_document,
        lv_access_token TYPE zoauth2_token,
        lv_refresh_token TYPE zoauth2_token,
        wa_user TYPE zoauth2_user,
        lv_rc type i.


  CALL METHOD cl_http_client=>create
    EXPORTING
      HOST               =  ret_refresh_token_host
      scheme             = cl_http_client=>SCHEMETYPE_HTTPS
      proxy_host         = me->zif_oauth2~proxy_host
      proxy_service      = me->zif_oauth2~proxy_service
      ssl_id             = me->zif_oauth2~ssl_id
*    SAP_USERNAME       =
*    SAP_CLIENT         =
    IMPORTING
      client             = client
*  EXCEPTIONS
*    ARGUMENT_NOT_FOUND = 1
*    PLUGIN_NOT_ACTIVE  = 2
*    INTERNAL_ERROR     = 3
*    others             = 4
          .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



  client->request->set_header_field(
    name = 'Host'
    value = ret_refresh_token_host
    ).

  client->request->set_header_field(
      name = 'Content-Type'
      value = 'application/x-www-form-urlencoded'
      ).

  CALL METHOD client->request->set_method
    EXPORTING
      method = 'POST'.

  CALL METHOD client->request->set_version
    EXPORTING
      version = '1001'.

  CALL METHOD cl_http_utility=>if_http_utility~set_request_uri
    EXPORTING
      request = client->request
      uri     = ret_refresh_token_request_uri.

  SELECT SINGLE * FROM zoauth2_consumer INTO wa_consumer WHERE consumer_name = consumer_name.

  CONCATENATE 'client_id=' wa_consumer-client_id '&client_secret=' wa_consumer-client_secret '&code=' i_verification_code '&redirect_uri=' wa_consumer-redirect_uris '&grant_type=authorization_code' INTO lv_cdata.

  client->request->set_cdata( lv_cdata ).


  CALL METHOD  client->send
*  EXPORTING
*    TIMEOUT                    = CO_TIMEOUT_DEFAULT
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      http_invalid_timeout       = 4
      OTHERS                     = 5
          .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL METHOD client->receive
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      OTHERS                     = 4.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  DATA: response TYPE string.

  client->response->get_status( IMPORTING code = lv_rc ).

  IF lv_rc EQ 200.

    CALL METHOD client->response->get_cdata
      RECEIVING
        data = response.
    .

    lv_json_doc = zcl_json_document=>create_with_json( response ).
    lv_access_token = lv_json_doc->get_value( 'access_token' ).
    lv_refresh_token = lv_json_doc->get_value( 'refresh_token' ).


    wa_user-consumer_name = consumer_name.
    wa_user-user_name = user_name.
*wa_user-PASSWORD_HASH =
    wa_user-access_token = lv_access_token.
    wa_user-refresh_token = lv_refresh_token.

    INSERT INTO zoauth2_user VALUES wa_user.

  ENDIF.

endmethod.


method ZIF_OAUTH2~AUTHORIZATION_REQUEST.

  DATA: wa_zoauth2_consumer TYPE zoauth2_consumer,
       lv_auth_url TYPE string,
       lv_user_name TYPE zoauth2_user_name,
       lv_verification_code TYPE zoauth2_token.

  SELECT SINGLE * FROM zoauth2_consumer INTO wa_zoauth2_consumer WHERE consumer_name = consumer_name.

  CONCATENATE i_auth_host '?scope=' wa_zoauth2_consumer-api_host '&response_type=code&redirect_uri=' wa_zoauth2_consumer-redirect_uris '&client_id=' wa_zoauth2_consumer-client_id INTO lv_auth_url.

  CALL METHOD cl_gui_frontend_services=>execute
  EXPORTING
    document               =  lv_auth_url
*  EXCEPTIONS
*    CNTL_ERROR             = 1
*    ERROR_NO_GUI           = 2
*    BAD_PARAMETER          = 3
*    FILE_NOT_FOUND         = 4
*    PATH_NOT_FOUND         = 5
*    FILE_EXTENSION_UNKNOWN = 6
*    ERROR_EXECUTE_FAILED   = 7
*    SYNCHRONOUS_FAILED     = 8
*    NOT_SUPPORTED_BY_GUI   = 9
*    others                 = 10
        .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL FUNCTION 'ZOAUTH2_CALL_SCREEN_AUTH'
    IMPORTING
      o_verification_code = lv_verification_code.

call method me->get_refresh_token
  exporting
    i_verification_code = lv_verification_code
    .


endmethod.


method ZIF_OAUTH2~GET_ACCESS_TOKEN.
   SELECT SINGLE access_token INTO token
    FROM zoauth2_user WHERE consumer_name = me->consumer_name AND user_name = me->user_name.
endmethod.


method ZIF_OAUTH2~REFRESH_ACCESS_TOKEN.
  DATA:  client TYPE REF TO if_http_client,
      lv_auth_header TYPE zoauth2_token,
      lv_token        TYPE zoauth2_token,
      lv_rc TYPE i,
      lt_form_values TYPE     tihttpnvp,
      wa_form_values TYPE     ihttpnvp,
      lv_json_doc TYPE REF TO zcl_json_document,
      wa_oauth2_user TYPE zoauth2_user,
      wa_oauth2_consumer TYPE  zoauth2_consumer,
      lv_response TYPE string,
      lv_cdata type string.



  CALL METHOD cl_http_client=>create_by_url
    EXPORTING
      url                = ret_refresh_token_url
      proxy_host         = 'lucifer.techedge.mi'
      proxy_service      = '3128'
      ssl_id             = 'ANONYM'
*    SAP_USERNAME       =
*    SAP_CLIENT         =
    IMPORTING
      client             = client
*  EXCEPTIONS
*    ARGUMENT_NOT_FOUND = 1
*    PLUGIN_NOT_ACTIVE  = 2
*    INTERNAL_ERROR     = 3
*    others             = 4
          .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


  client->request->set_header_field(
    name = 'Host'
    value = 'accounts.google.com'
    ).

  client->request->set_content_type( 'application/x-www-form-urlencoded' ).



  CALL METHOD client->request->set_method
    EXPORTING
      method = 'POST'.

  CALL METHOD client->request->set_version
    EXPORTING
      version = '1001'.

  CALL METHOD cl_http_utility=>if_http_utility~set_request_uri
    EXPORTING
      request = client->request
      uri     = '/o/oauth2/token'.

  SELECT SINGLE * INTO wa_oauth2_user
      FROM zoauth2_user WHERE consumer_name = me->consumer_name AND user_name = me->user_name.

  SELECT SINGLE * INTO wa_oauth2_consumer
      FROM zoauth2_consumer WHERE consumer_name = me->consumer_name .

*  MOVE: 'client_id' TO wa_form_values-name ,
*       wa_oauth2_consumer-client_id TO wa_form_values-value.
*  APPEND wa_form_values TO lt_form_values.
*
*  MOVE: 'client_secret' TO wa_form_values-name ,
*        wa_oauth2_consumer-client_secret TO wa_form_values-value.
*  APPEND wa_form_values TO lt_form_values.
*
*  MOVE: 'refresh_token' TO wa_form_values-name ,
*        wa_oauth2_user-refresh_token TO wa_form_values-value.
*  APPEND wa_form_values TO lt_form_values.
*
*  MOVE: 'grant_type' TO wa_form_values-name ,
*        'refresh_token' TO wa_form_values-value.
*  APPEND wa_form_values TO lt_form_values.
*
*
*  CALL METHOD client->response->if_http_entity~set_form_fields
*    EXPORTING
*      fields = lt_form_values.


CONCATENATE 'client_id=' wa_oauth2_consumer-client_id '&client_secret=' wa_oauth2_consumer-client_secret '&refresh_token=' wa_oauth2_user-refresh_token '&grant_type=refresh_token' into lv_cdata.

client->request->set_cdata( lv_cdata ).



  CALL METHOD  client->send
*  EXPORTING
*    TIMEOUT                    = CO_TIMEOUT_DEFAULT
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      http_invalid_timeout       = 4
      OTHERS                     = 5
          .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL METHOD client->receive
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      OTHERS                     = 4.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  client->response->get_status( IMPORTING code = lv_rc ).

  IF lv_rc EQ 200.

    CALL METHOD client->response->get_cdata
      RECEIVING
        data = lv_response.

    lv_json_doc = zcl_json_document=>create_with_json( lv_response ).
    lv_token = lv_json_doc->get_value( 'access_token' ).

    wa_oauth2_user-access_token = lv_token.
    o_token = lv_token.

    UPDATE   zoauth2_user FROM wa_oauth2_user.

  ENDIF.
endmethod.
ENDCLASS.
