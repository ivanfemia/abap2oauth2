FUNCTION ZOAUTH2_CALL_SCREEN_AUTH.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     REFERENCE(O_USER_NAME) TYPE  ZOAUTH2_USER_NAME
*"     REFERENCE(O_VERIFICATION_CODE) TYPE  ZOAUTH2_TOKEN
*"--------------------------------------------------------------------
call screen 9000.

  move VERIFICATION_CODE to O_VERIFICATION_CODE	.





ENDFUNCTION.
