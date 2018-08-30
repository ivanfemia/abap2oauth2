class ZCX_OAUTH2_ERROR definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

public section.

  constants ZCX_OAUTH2_ERROR type SOTR_CONC value '0800273352511EE8AAEB533DECB415B4' ##NO_TEXT.
  constants TOKEN_EXPIRED type SOTR_CONC value '0800273352511EE8AAEB533DECB3F5B4' ##NO_TEXT.
  data RESPONSE type ZOAUTH2_API_RESPONSE .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !RESPONSE type ZOAUTH2_API_RESPONSE optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_OAUTH2_ERROR IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
TEXTID = TEXTID
PREVIOUS = PREVIOUS
.
 IF textid IS INITIAL.
   me->textid = ZCX_OAUTH2_ERROR .
 ENDIF.
me->RESPONSE = RESPONSE .
  endmethod.
ENDCLASS.
