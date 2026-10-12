CLASS zcl_fp_generate_form_time DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FP_GENERATE_FORM_TIME IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA: lv_fname TYPE string,
          lv_tname TYPE string.

    DATA: lr_timestamp TYPE RANGE OF zdt_vehin_head-created_at.
    CONSTANTS: lc_tzone TYPE cl_abap_context_info=>ty_time_zone VALUE 'UTC'.


    GET TIME STAMP FIELD DATA(lv_timestamp).
    cl_abap_tstmp=>subtractsecs(
      EXPORTING
        tstmp   = lv_timestamp
        secs    = 200
       RECEIVING
         r_tstmp = DATA(lv_rtimestamp)
    ).

    lr_timestamp = VALUE #( ( sign = 'I' option ='BT' low = lv_rtimestamp high = lv_timestamp ) ).

    SELECT SINGLE inward_uuid
          FROM zdt_vehin_head
          WHERE last_changed_at IN @lr_timestamp
          INTO @DATA(lv_inward_uuid).


    TRY.
        "Initialize Template Store Client
        DATA(lo_store) = NEW zcl_fp_tmpl_store_client(

    "name of the destination (in destination service instance) pointing to Forms Service by Adobe API service instance
    iv_service_instance_name = 'Z_ADS_STORE'
    iv_use_destination_service = abap_false ).


        lv_fname = 'Inward'.
        lv_tname = 'Inward'.

        DATA(ls_template) = lo_store->get_template_by_name(
            iv_get_binary = abap_true
            iv_form_name = lv_fname    "'WeighbridgeOut' "<= form object in template store
            iv_template_name = lv_tname    "'WeighbridgeOut' "<= template (in form object) that should be used

            ).

        DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( 'ZUI_VEHIN_DATA' ).
        DATA(lt_keys)     = lo_fdp_util->get_keys( ).
        lt_keys[ name = 'INWARD_UUID' ]-value = lv_inward_uuid. "'9940E2EF70DD1EEE90B237547DF09ECC'.
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
            iv_qname = 'PRINT_TICKET'
            iv_print_data = lv_pdf
            iv_name_of_main_doc = 'Inward'
    ).

      CATCH cx_fp_fdp_error INTO DATA(lo_fdp).
        DATA(message) =  lo_fdp->get_longtext(  ).

      CATCH zcx_fp_tmpl_store_error INTO DATA(lo_error).
        message =  lo_error->get_longtext(  ).

      CATCH cx_fp_ads_util INTO DATA(lo_util).
        message =  lo_error->get_longtext(  ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
