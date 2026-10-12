CLASS zcl_fp_generate_form DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FP_GENERATE_FORM IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    TYPES: BEGIN OF ty_return,
             message TYPE string,
           END OF ty_return,

           tt_return TYPE STANDARD TABLE OF ty_return WITH DEFAULT KEY.

    DATA: lv_fname TYPE string,
          lv_tname TYPE string,
          lv_name  TYPE cl_print_queue_utils=>ty_doc_name.

    DATA(lo_current_tenant) = xco_cp=>current->tenant( ).

    " UI URL of the current tenant.
    DATA(lo_ui_url) = lo_current_tenant->get_url( xco_cp_tenant=>url_type->ui ).
    DATA(lv_ui_url_host) = lo_ui_url->get_host( ).

    IF lv_ui_url_host+0(8) = 'my403054'.
      DATA(lv_url) =  'PRD'.
    ELSEIF lv_ui_url_host+0(8) = 'my402930'.
      lv_url = 'QAS'.
    ELSEIF lv_ui_url_host+0(8) = 'my402932' OR lv_ui_url_host+0(8) = 'my403040'.
      lv_url = 'CUS'.
    ENDIF.

    TRY.
        "Initialize Template Store Client
        DATA(lo_store) = NEW zcl_fp_tmpl_store_client(

    "name of the destination (in destination service instance) pointing to Forms Service by Adobe API service instance
    iv_service_instance_name = 'Z_ADS_STORE'
    iv_use_destination_service = abap_false ).

      CATCH zcx_fp_tmpl_store_error INTO DATA(lo_error1).
        DATA(message) =  lo_error1->get_longtext(  ).
        out->write( message ).
    ENDTRY.
    DO 4 TIMES.
      IF sy-index = 1.
        lv_fname = 'Inward'.
        lv_tname = 'Inward'.
        lv_name = 'Inward'.
      ELSEIF sy-index = 2.
        lv_fname = 'Outward'.
        lv_tname = 'Outward'.
        lv_name = 'Outward'.
      ELSEIF sy-index = 3.
        lv_fname = 'WeighbridgeIn'.
        lv_tname = 'WeighbridgeIn'.
        lv_name = 'WeighbridgeIn'.
      ELSE.
        lv_fname = 'WeighbridgeOut'.
        lv_tname = 'WeighbridgeOut'.
        lv_name = 'WeighbridgeOut'.
      ENDIF.
      TRY.

          DATA(ls_template) = lo_store->get_template_by_name(
     iv_get_binary = abap_true
     iv_form_name = lv_fname    "'WeighbridgeOut' "<= form object in template store
     iv_template_name = lv_tname    "'WeighbridgeOut' "<= template (in form object) that should be used

     ).

          DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( 'ZUI_VEHIN_DATA' ).
          DATA(lt_keys)     = lo_fdp_util->get_keys( ).
          lt_keys[ name = 'INWARD_UUID' ]-value = '9940E2EF70DD1EEE90B237547DF09ECC'. "'672FFC9B10EA1EDEA7F9D61E24E8221B'.
          DATA(lv_xml_final1) = lo_fdp_util->read_to_xml( lt_keys ).
          DATA(lv_schema) = lo_fdp_util->get_xsd(  ).

          		
          cl_fp_ads_util=>render_4_pq(
            EXPORTING
            iv_locale = ''"'en_US'
            iv_pq_name = 'PRINT_TICKET'           "'YO1CLNT100Q' "<= Name of the print queue where result should be stored
            iv_xml_data = lv_xml_final1
            iv_xdp_layout = ls_template-xdp_template
            is_options = VALUE #(
            trace_level = 4 "Use 0 in production environment
            )
            IMPORTING
            ev_trace_string = DATA(lv_trace)
            ev_pdl = DATA(lv_pdf)
            ).

          cl_print_queue_utils=>create_queue_item_by_data(
              iv_qname = 'PRINT_TICKET'           "'YO1CLNT100Q'
              iv_print_data = lv_pdf
              iv_name_of_main_doc = lv_name "'Inward Ticket'
      ).

        CATCH cx_fp_fdp_error INTO DATA(lo_fdp).
          message =  lo_fdp->get_longtext(  ).
          out->write( message ).
        CATCH zcx_fp_tmpl_store_error INTO DATA(lo_error).
          message =  lo_error->get_longtext(  ).
          out->write( message ).
        CATCH cx_fp_ads_util INTO DATA(lo_util).
          message =  lo_util->get_longtext(  ).
          out->write( message ).
      ENDTRY.

    ENDDO.
  ENDMETHOD.
ENDCLASS.
