CLASS zcl_background_process_wt_1100 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_serializable_object .
    INTERFACES if_bgmc_operation .
    INTERFACES if_bgmc_op_single_tx_uncontr .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_BACKGROUND_PROCESS_WT_1100 IMPLEMENTATION.


  METHOD if_bgmc_op_single_tx_uncontr~execute.
    DATA: lv_fname TYPE string,
          lv_tname TYPE string,
          lv_name  TYPE cl_print_queue_utils=>ty_doc_name.

    DATA: lr_time TYPE RANGE OF zdt_vehin_head-intime,
          lr_date TYPE RANGE OF zdt_vehin_head-indate.

    DATA: lr_timestamp TYPE RANGE OF zdt_vehin_head-created_at.

    CONSTANTS: lc_tzone TYPE cl_abap_context_info=>ty_time_zone VALUE 'INDIA'.

    GET TIME STAMP FIELD DATA(lv_timestamp).
    cl_abap_tstmp=>subtractsecs(
      EXPORTING
        tstmp   = lv_timestamp
        secs    = 30
       RECEIVING
         r_tstmp = DATA(lv_rtimestamp)
    ).

    CONVERT TIME STAMP lv_timestamp TIME ZONE lc_tzone INTO DATE DATA(lv_date) TIME DATA(lv_time).
    CONVERT TIME STAMP lv_rtimestamp TIME ZONE lc_tzone INTO DATE DATA(lv_rdate) TIME DATA(lv_rtime).

    lr_time = VALUE #( ( sign = 'I' option ='BT' low = lv_rtime high = lv_time ) ).

    SELECT SINGLE inward_uuid, plant, ticknum
          FROM zdt_vehin_head
          WHERE pwodate = @lv_date
          AND pwotime IN @lr_time
          and plant = '1100'
          INTO @DATA(ls_inward_uuid).
    IF sy-subrc = 0.
      DATA(lv_flag) = 'G'.
    ELSE.
      SELECT SINGLE inward_uuid, plant, ticknum
        FROM zdt_vehin_head
        WHERE pwidate = @lv_date
        AND pwitime IN @lr_time
        and plant = '1100'
        INTO @ls_inward_uuid.
      IF sy-subrc = 0.
        lv_flag = 'T'.
      ENDIF.
    ENDIF.

    CHECK lv_flag IS NOT INITIAL.
    DATA: lv_pname TYPE cl_fp_ads_util=>ty_pq_name.
    lv_pname = 'PRINT_KAKINADA_WEIGHBRIDGE'.

    TRY.
        "Initialize Template Store Client
        DATA(lo_store) = NEW zcl_fp_tmpl_store_client(

    "name of the destination (in destination service instance) pointing to Forms Service by Adobe API service instance
    iv_service_instance_name = 'Z_ADS_STORE'
    iv_use_destination_service = abap_false ).

        CASE lv_flag .
          WHEN 'T'.
            lv_fname = 'WeighbridgeIn'.
            lv_tname = 'WeighbridgeIn'.
            lv_name = 'WeighbridgeIn'.
          WHEN 'G'.
            lv_fname = 'WeighbridgeOut'.
            lv_tname = 'WeighbridgeOut'.
            lv_name = 'WeighbridgeOut'.
        ENDCASE.

        DATA(ls_template) = lo_store->get_template_by_name(
            iv_get_binary = abap_true
            iv_form_name = lv_fname    "'WeighbridgeOut' "<= form object in template store
            iv_template_name = lv_tname    "'WeighbridgeOut' "<= template (in form object) that should be used

            ).

        DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( 'ZUI_VEHIN_DATA' ).
        DATA(lt_keys)     = lo_fdp_util->get_keys( ).
        lt_keys[ name = 'INWARD_UUID' ]-value = ls_inward_uuid-inward_uuid. "'9940E2EF70DD1EEE90B237547DF09ECC'.
        DATA(lv_xml_final1) = lo_fdp_util->read_to_xml( lt_keys ).
        DATA(lv_schema) = lo_fdp_util->get_xsd(  ).

        cl_fp_ads_util=>render_4_pq(
          EXPORTING
          iv_locale = ''"'en_US'
          iv_pq_name = lv_pname "'PRINT_TICKET'           "'YO1CLNT100Q' "<= Name of the print queue where result should be stored
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
            iv_qname = lv_pname "'PRINT_TICKET'
            iv_print_data = lv_pdf
            iv_name_of_main_doc = |{ lv_name }_{ ls_inward_uuid-ticknum }|
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
