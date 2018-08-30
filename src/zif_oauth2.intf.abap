interface ZIF_OAUTH2
  public .


  constants CO_REQUEST_METHOD_GET type STRING value 'GET' ##NO_TEXT.
  constants CO_REQUEST_METHOD_POST type STRING value 'POST' ##NO_TEXT.
  constants CO_REQUEST_METHOD_PUT type STRING value 'PUT' ##NO_TEXT.
  constants CO_REQUEST_METHOD_DELETE type STRING value 'DEL' ##NO_TEXT.
  data PROXY_HOST type STRING .
  data PROXY_SERVICE type STRING .
  data SSL_ID type SSFAPPLSSL .

  methods AUTHORIZATION_REQUEST
    importing
      !I_AUTH_HOST type ZOAUTH2_HOST .
  methods GET_ACCESS_TOKEN
    returning
      value(TOKEN) type ZOAUTH2_TOKEN .
  methods REFRESH_ACCESS_TOKEN
    returning
      value(O_TOKEN) type ZOAUTH2_TOKEN .
endinterface.
