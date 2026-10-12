CLASS lhc_head DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR head RESULT result.
    METHODS calculateticknum FOR DETERMINE ON SAVE
      IMPORTING keys FOR head~calculateticknum.
    METHODS validateinward FOR VALIDATE ON SAVE
      IMPORTING keys FOR head~validateinward.
    METHODS defaultdata FOR DETERMINE ON MODIFY
      IMPORTING keys FOR head~defaultdata.
    METHODS print FOR MODIFY
      IMPORTING keys FOR ACTION head~print. "RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR head RESULT result.
    METHODS getorderdata FOR DETERMINE ON MODIFY
      IMPORTING keys FOR head~getorderdata.
    METHODS setitem FOR DETERMINE ON SAVE
      IMPORTING keys FOR head~setitem.
    METHODS calctotweight FOR MODIFY
      IMPORTING keys FOR ACTION head~calctotweight.
    METHODS setoutward FOR MODIFY
      IMPORTING keys FOR ACTION head~setoutward.

ENDCLASS.

CLASS lhc_head IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD calculateticknum.
    CONSTANTS: lc_tzone TYPE cl_abap_context_info=>ty_time_zone VALUE 'INDIA'.
    GET TIME STAMP FIELD DATA(lv_timestamp).
    CONVERT TIME STAMP lv_timestamp TIME ZONE lc_tzone INTO DATE DATA(lv_date) TIME DATA(lv_time).

    SELECT SINGLE fiscalyear
            FROM zi_fiscalcalendardate
                WHERE fiscalyearvariant = 'V3'
                AND calendardate = @lv_date
                        INTO @DATA(lv_fyear).

    READ ENTITIES OF zi_vehin_head IN LOCAL MODE
            ENTITY head
                ALL FIELDS WITH CORRESPONDING #( keys )
                    RESULT DATA(heads).
    TRY.
        DATA(ls_head) = heads[ 1 ].
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    SELECT SINGLE
            FROM zi_vehin_head
                FIELDS MAX( range ) AS ticknum
                    WHERE plant = @ls_head-plant
                    AND   fiscal = @lv_fyear
                      INTO @DATA(max_ticknum).
    IF max_ticknum IS INITIAL.
      max_ticknum = '0000000001'.
    ELSE.
      max_ticknum = max_ticknum + 1.
    ENDIF.

    IF ls_head-intype = 'S'.
      SELECT SINGLE     grossweight,
                        netweight
                       FROM zi_sorder_data
                             WHERE sorder = @ls_head-orderhead
                                 INTO @DATA(ls_weigh).
    ELSEIF ls_head-intype = 'P'.
      SELECT SINGLE grossweight,
                    netweight
                  FROM zi_porder_data
                        WHERE porder = @ls_head-orderhead
                            INTO @ls_weigh.

    ENDIF.
    ls_head-grossweight = ls_weigh-grossweight.
    ls_head-netweight   = ls_weigh-netweight.

    DATA(lv_ticknum) = |{ ls_head-plant }{ lv_fyear }{ max_ticknum }|.
    MODIFY ENTITIES OF zi_vehin_head IN LOCAL MODE
           ENTITY head
               UPDATE
                   FROM VALUE #( FOR head IN heads INDEX INTO i    (
                       %tky  = head-%tky
                       ticknum = lv_ticknum
                       range = max_ticknum
                        grossweight = ls_head-grossweight
                        netweight = ls_head-netweight
                       %control-ticknum = if_abap_behv=>mk-on
                       %control-range = if_abap_behv=>mk-on
                       %control-grossweight = if_abap_behv=>mk-on
                       %control-netweight = if_abap_behv=>mk-on
                   )  )
         REPORTED DATA(update_reported).
  ENDMETHOD.

  METHOD validateinward.
    READ ENTITIES OF zi_vehin_head IN LOCAL MODE
           ENTITY head
               FIELDS ( intype orderhead vehnum drivnum ) WITH CORRESPONDING #( keys )
                   RESULT DATA(head).
    TRY.
        DATA(ls_header) = head[ 1 ].
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
    IF ls_header-intype IS NOT INITIAL.
      SELECT SINGLE   ticknum,
                      intype
          FROM zi_vehicle_inward_data
              WHERE inwarduuid = @ls_header-inward_uuid
                  INTO @DATA(ls_data).
      IF ls_data IS NOT INITIAL.
        IF ls_header-intype <> ls_data-intype.
          APPEND VALUE #(
             %tky = ls_header-%tky
             %msg = new_message_with_text(
             severity = if_abap_behv_message=>severity-error
             text     = |{ TEXT-001 }|
          )

          ) TO reported-head.
          APPEND VALUE #( %tky = ls_header-%tky ) TO failed-head.

        ENDIF.
      ENDIF.
    ELSE.
      APPEND VALUE #(
         %tky = ls_header-%tky
         %msg = new_message_with_text(
         severity = if_abap_behv_message=>severity-error
         text     = |{ TEXT-005 }|
      )

      ) TO reported-head.
      APPEND VALUE #( %tky = ls_header-%tky ) TO failed-head.
    ENDIF.

    IF ls_header-vehnum IS INITIAL.
      APPEND VALUE #(
           %tky = ls_header-%tky
           %msg = new_message_with_text(
           severity = if_abap_behv_message=>severity-error
           text     = |{ TEXT-002 }|
        )

        ) TO reported-head.
      APPEND VALUE #( %tky = ls_header-%tky ) TO failed-head.
    ENDIF.

    IF ls_header-drivnum IS INITIAL.
      APPEND VALUE #(
           %tky = ls_header-%tky
           %msg = new_message_with_text(
           severity = if_abap_behv_message=>severity-error
           text     = |{ TEXT-003 }|
        )

        ) TO reported-head.
      APPEND VALUE #( %tky = ls_header-%tky ) TO failed-head.

      IF ls_header-orderhead IS INITIAL.
        APPEND VALUE #(
             %tky = ls_header-%tky
             %msg = new_message_with_text(
             severity = if_abap_behv_message=>severity-error
             text     = |{ TEXT-004 }|
          )

          ) TO reported-head.
        APPEND VALUE #( %tky = ls_header-%tky ) TO failed-head.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD defaultdata.
    CONSTANTS: lc_tzone TYPE cl_abap_context_info=>ty_time_zone VALUE 'INDIA'.

    GET TIME STAMP FIELD DATA(lv_timestamp).
    CONVERT TIME STAMP lv_timestamp TIME ZONE lc_tzone INTO DATE DATA(lv_date) TIME DATA(lv_time).
    DATA(lv_ctime) = lv_time.
    CLEAR lv_ctime.

    SELECT SINGLE fiscalyear
            FROM zi_fiscalcalendardate
                WHERE fiscalyearvariant = 'V3'
                AND   calendardate = @lv_date
                        INTO @DATA(lv_fyear).

    READ ENTITIES OF zi_vehin_head IN LOCAL MODE ENTITY
          head ALL FIELDS WITH CORRESPONDING #( keys )
              RESULT DATA(heads).

    DATA(ls_header) = heads[ 1 ].
    IF ls_header-indate IS INITIAL.
      MODIFY ENTITIES OF zi_vehin_head IN LOCAL MODE
        ENTITY head
            UPDATE SET FIELDS WITH VALUE #(
                          FOR head IN heads (
                              %key = head-%key
                              %is_draft = head-%is_draft
                             indate = lv_date
                             intime = lv_time
                             fiscal = lv_fyear
                             pwitime = lv_ctime
                     "        range = '0000000001'
                          )
                  ) REPORTED DATA(modifyreported).
      reported = CORRESPONDING #( DEEP modifyreported ).
    ENDIF.
  ENDMETHOD.

  METHOD print.
    DATA: lv_fname TYPE string,
          lv_tname TYPE string.

    READ ENTITIES OF zi_vehin_head IN LOCAL MODE ENTITY
       head ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(heads).
    TRY.
        DATA(ls_header) = heads[ 1 ].
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.


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
        lt_keys[ name = 'INWARD_UUID' ]-value = ls_header-inward_uuid.    "'9940E2EF70DD1EEE90B237547DF09ECC'.
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
            iv_name_of_main_doc = 'Inward Ticket'
    ).



      CATCH cx_fp_fdp_error INTO DATA(lo_fdp).
        DATA(message) =  lo_fdp->get_longtext(  ).
        "          out->write( message ).
        APPEND VALUE #(
             %tky = ls_header-%tky
             %msg = new_message_with_text(
             severity = if_abap_behv_message=>severity-error
             text     = |{ message }|
          )

          ) TO reported-head.
        APPEND VALUE #( %tky = ls_header-%tky ) TO failed-head.
      CATCH zcx_fp_tmpl_store_error INTO DATA(lo_error).
        message =  lo_error->get_longtext(  ).
        APPEND VALUE #(
             %tky = ls_header-%tky
             %msg = new_message_with_text(
             severity = if_abap_behv_message=>severity-error
             text     = |{ message }|
          )

          ) TO reported-head.
      CATCH cx_fp_ads_util INTO DATA(lo_util).
        message =  lo_util->get_longtext(  ).
        APPEND VALUE #(
             %tky = ls_header-%tky
             %msg = new_message_with_text(
             severity = if_abap_behv_message=>severity-error
             text     = |{ message }|
          )

          ) TO reported-head.
    ENDTRY.
  ENDMETHOD.

  METHOD get_instance_features.
    DATA: lv_test TYPE c.

    READ ENTITIES OF zi_vehin_head IN LOCAL MODE
        ENTITY head
            ALL FIELDS WITH CORRESPONDING #( keys )
                RESULT DATA(lt_context_data)
                    FAILED failed.

    LOOP AT lt_context_data INTO DATA(ls_data).
      SELECT SINGLE subsequentdocument
              FROM zi_salesdocitmsubsqntprocflow
                  WHERE subsqntdocitmprecdgdocument = @ls_data-orderhead
                  AND subsequentdocumentcategory = 'M'
                      INTO @DATA(lv_deldoc).
      IF sy-subrc = 0.
        DATA(lv_exist) = 'X'.
      ELSE.
        CLEAR lv_exist.
        IF ls_data-intype = 'P'.
          lv_exist = 'X'.
        ENDIF.
      ENDIF.

      APPEND VALUE #( %tky = ls_data-%tky

                      %update = COND #( WHEN "( ls_data-ticknum IS NOT INITIAL AND ( ls_data-type = 'BULK' ) ) or
                                                         ( ls_data-pwigetwg = 'C' OR ls_data-pwogetwg = 'C' OR ls_data-pwexit = 'C' )
                            THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )

                      %assoc-_item = COND #( WHEN "( ls_data-ticknum IS NOT INITIAL AND ( ls_data-type = 'BULK' ) ) or
                                                         ( ls_data-pwigetwg = 'C' OR ls_data-pwogetwg = 'C' OR ls_data-pwexit = 'C' )
                            THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )

                     %action-print = COND #( WHEN ( ls_data-ticknum IS INITIAL OR ls_data-pwexit = 'C' OR ls_data-pwigetwg = 'C' OR ls_data-pwogetwg = 'C'  )
                                                         THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )

                     %action-setoutward = COND #( WHEN ( ( ls_data-ticknum IS INITIAL OR ls_data-pwexit = 'C' OR ls_data-pwigetwg = ' ' OR ls_data-pwogetwg = ' ' OR lv_exist = ' ') )
                                                         THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )

*                     %delete = COND #( WHEN ( ls_data-pwigetwg = 'C' OR ls_data-pwogetwg = 'C' OR ls_data-pwexit = 'C' )
*                            THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )

      )
      TO result.

      CLEAR lv_exist.
    ENDLOOP.
  ENDMETHOD.

  METHOD getorderdata.
    READ ENTITIES OF zi_vehin_head IN LOCAL MODE ENTITY
          head ALL FIELDS WITH CORRESPONDING #( keys )
              RESULT DATA(heads).
    TRY.
        DATA(ls_header) = heads[ 1 ].
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
    IF ls_header-intype = 'S'.
      SELECT SINGLE sorder,
                    distributionchannel,
                    plant
              FROM zi_sorder_data
                  WHERE sorder = @ls_header-orderhead
                      INTO @DATA(ls_sorder).
      CHECK sy-subrc = 0.
*      IF ls_sorder-distributionchannel = '10'.
      IF ls_sorder-distributionchannel = '10' OR
*         ls_sorder-distributionchannel = '30'
           ls_sorder-distributionchannel = '35'.
        DATA(lv_type) = 'PACK'.
      ELSEIF ls_sorder-distributionchannel = '15'.
        lv_type = 'BULK'.
*        ELSEIF ls_sorder-distributionchannel = '30'.
*          lv_type = 'PO'.
      ENDIF.

      MODIFY ENTITIES OF zi_vehin_head IN LOCAL MODE
          ENTITY head
              UPDATE SET FIELDS WITH VALUE #(
                            FOR head IN heads (
                                %key = head-%key
                                %is_draft = head-%is_draft
                               plant = ls_sorder-plant
                               type = lv_type
                               dchannel = ls_sorder-distributionchannel
                               orderhead1 = ls_header-orderhead
                              )
                    ) REPORTED DATA(modifyreported).
      reported = CORRESPONDING #( DEEP modifyreported ).
    ELSEIF ls_header-intype = 'P'.
      SELECT SINGLE porder,
                  distributionchannel,
                  plant
            FROM zi_porder_data
                WHERE porder = @ls_header-orderhead
                    INTO @DATA(ls_porder).
*        lv_type = 'PO'.
      IF ls_porder-distributionchannel = '30'.
*        lv_type = 'PACK'.
*      ELSE.
        lv_type = 'PO'.
      ENDIF.

      MODIFY ENTITIES OF zi_vehin_head IN LOCAL MODE
       ENTITY head
           UPDATE SET FIELDS WITH VALUE #(
                         FOR head IN heads (
                             %key = head-%key
                             %is_draft = head-%is_draft
                            plant = ls_porder-plant
                            type = lv_type
                            dchannel = ls_porder-distributionchannel
                            orderhead1 = ls_header-orderhead
                         )
                 ) REPORTED DATA(modifyreported1).
      reported = CORRESPONDING #( DEEP modifyreported1 ).
    ENDIF.
  ENDMETHOD.

  METHOD setitem.
    READ ENTITIES OF zi_vehin_head IN LOCAL MODE
        ENTITY head
            ALL FIELDS WITH CORRESPONDING #( keys )
              RESULT DATA(heads).
    TRY.
        DATA(ls_header) = heads[ 1 ].
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    IF ls_header-intype = 'S'.
      SELECT deliverydocument,
             deliverydocumentitem,
             material
         FROM i_deliverydocumentitem
         WHERE deliverydocument = @ls_header-orderhead
         ORDER BY deliverydocument, deliverydocumentitem
         INTO TABLE @DATA(lt_deliveryitem).

      DATA(lv_item) = 1.
      TRY.
          DATA(ls_ditem) = lt_deliveryitem[ 1 ].
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.
      LOOP AT lt_deliveryitem INTO ls_ditem.
        TRY.
            MODIFY ENTITIES OF zi_vehin_head IN LOCAL MODE
                ENTITY head
                    CREATE BY \_item
                        FROM VALUE #( ( %key = ls_header-%key
                                    %target = VALUE #( ( %cid = 'CID'
                                                        inward_uuid = ls_header-inward_uuid
                                                        %control-inward_uuid = if_abap_behv=>mk-on
                                                        item_uuid = cl_system_uuid=>create_uuid_x16_static( )
                                                        %control-item_uuid = if_abap_behv=>mk-on
                                                        ordnum = ls_header-orderhead
                                                        %control-ordnum = if_abap_behv=>mk-on
                                                        ordnumitem = ls_ditem-deliverydocumentitem
                                                        %control-ordnumitem = if_abap_behv=>mk-on
                                                        matnr = ls_ditem-material
                                                        %control-matnr = if_abap_behv=>mk-on
                                                        intype = ls_header-intype
                                                        %control-intype = if_abap_behv=>mk-on
                                                        inwarditem = lv_item   "1
                                                        %control-inwarditem = if_abap_behv=>mk-on
                                                    ) )
                                                )
                                            )
                            MAPPED DATA(ls_mapped) FAILED DATA(ls_failed) REPORTED DATA(ls_reported).
          CATCH cx_uuid_error.
        ENDTRY.
        lv_item = lv_item + 1.

        IF ls_header-dchannel = '10'
        OR ls_header-dchannel = '35'.
          EXIT.
        ENDIF.
      ENDLOOP.

    ELSE.
      SELECT purchaseorder,
             purchaseorderitem,
             material
       FROM i_purchaseorderitemapi01
       WHERE purchaseorder = @ls_header-orderhead
       ORDER BY purchaseorder, purchaseorderitem
       INTO TABLE @DATA(lt_purchaseitem).

      "      LOOP AT lt_purchaseitem INTO DATA(ls_pitem).
      TRY.
          DATA(ls_pitem) = lt_purchaseitem[ 1 ].
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

      lv_item = 1.

      IF ls_header-dchannel = '30'.

        TRY.
            MODIFY ENTITIES OF zi_vehin_head IN LOCAL MODE
                ENTITY head
                    CREATE BY \_item
                        FROM VALUE #( ( %key = ls_header-%key
                                    %target = VALUE #( ( %cid = 'CID'
                                                        inward_uuid = ls_header-inward_uuid
                                                        %control-inward_uuid = if_abap_behv=>mk-on
                                                        item_uuid = cl_system_uuid=>create_uuid_x16_static( )
                                                        %control-item_uuid = if_abap_behv=>mk-on
                                                        ordnum = ls_header-orderhead
                                                        ordnumitem = ls_pitem-purchaseorderitem
                                                        %control-ordnumitem = if_abap_behv=>mk-on
                                                        matnr = ls_pitem-material
                                                        %control-matnr = if_abap_behv=>mk-on
                                                        %control-ordnum = if_abap_behv=>mk-on
                                                        intype = ls_header-intype
                                                        %control-intype = if_abap_behv=>mk-on
                                                        inwarditem = lv_item
                                                        %control-inwarditem = if_abap_behv=>mk-on
                                                    ) )
                                                )
                                            )
                            MAPPED DATA(ls_mapped1)
                            FAILED DATA(ls_failed1)
                            REPORTED DATA(ls_reported1).

          CATCH cx_uuid_error.
        ENDTRY.

      ELSE.


        LOOP AT lt_purchaseitem INTO ls_pitem.

          TRY.
              MODIFY ENTITIES OF zi_vehin_head IN LOCAL MODE
                  ENTITY head
                      CREATE BY \_item
                          FROM VALUE #( ( %key = ls_header-%key
                                      %target = VALUE #( ( %cid = 'CID'
                                                          inward_uuid = ls_header-inward_uuid
                                                          %control-inward_uuid = if_abap_behv=>mk-on
                                                          item_uuid = cl_system_uuid=>create_uuid_x16_static( )
                                                          %control-item_uuid = if_abap_behv=>mk-on
                                                          ordnum = ls_header-orderhead
                                                          %control-ordnum = if_abap_behv=>mk-on
                                                          ordnumitem = ls_pitem-purchaseorderitem
                                                          %control-ordnumitem = if_abap_behv=>mk-on
                                                          matnr = ls_pitem-material
                                                          %control-matnr = if_abap_behv=>mk-on
                                                          intype = ls_header-intype
                                                          %control-intype = if_abap_behv=>mk-on
                                                          inwarditem = lv_item
                                                          %control-inwarditem = if_abap_behv=>mk-on
                                                      ) )
                                                  )
                                              )
                              MAPPED ls_mapped1
                              FAILED ls_failed1
                              REPORTED ls_reported1.
            CATCH cx_uuid_error.
          ENDTRY.

          lv_item = lv_item + 1.

        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD calctotweight.
    DATA: lv_grwg TYPE p,
          lv_ntwg TYPE p.

    READ ENTITIES OF zi_vehin_head IN LOCAL MODE ENTITY
          head ALL FIELDS WITH CORRESPONDING #( keys )
              RESULT DATA(heads).

    TRY.
        DATA(ls_header) = heads[ 1 ].
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    READ ENTITIES OF zi_vehin_head IN LOCAL MODE
            ENTITY head BY \_item
                ALL FIELDS WITH VALUE #( ( %tky = ls_header-%tky  ) )
                    RESULT DATA(item).


    LOOP AT item INTO DATA(ls_item).
      lv_grwg = lv_grwg + ls_item-grossweight.
      lv_ntwg = lv_ntwg + ls_item-netweight.
    ENDLOOP.

    MODIFY ENTITIES OF zi_vehin_head IN LOCAL MODE
            ENTITY head
                UPDATE SET FIELDS WITH VALUE #(
                              FOR head IN heads (
                                  %key = head-%key
                                  %is_draft = head-%is_draft
                                 grossweight = lv_grwg
                                 netweight = lv_ntwg
                                )
                      ) REPORTED DATA(modifyreported).
    reported = CORRESPONDING #( DEEP modifyreported ).
  ENDMETHOD.

  METHOD setoutward.
    CONSTANTS: lc_tzone TYPE cl_abap_context_info=>ty_time_zone VALUE 'INDIA'.
    GET TIME STAMP FIELD DATA(lv_timestamp).
    CONVERT TIME STAMP lv_timestamp TIME ZONE lc_tzone INTO DATE DATA(lv_date) TIME DATA(lv_time).

    READ ENTITIES OF zi_vehin_head IN LOCAL MODE
           ENTITY head
               ALL FIELDS WITH CORRESPONDING #( keys )
                   RESULT DATA(heads).
    TRY.
        DATA(ls_head) = heads[ 1 ].
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        DATA(ls_key) = keys[ 1 ].
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    UPDATE zdt_vehin_head SET pwexit = 'C',
                              pwexitdt = @lv_date,
                              pwexittm = @lv_time
          WHERE inward_uuid = @ls_key-inward_uuid.

    MODIFY ENTITIES OF zi_vehin_head IN LOCAL MODE
           ENTITY head
               UPDATE
                   FROM VALUE #( FOR head IN heads INDEX INTO i    (
                       pwexit = 'C'
                       plant = ls_head-plant
                       %tky  = head-%tky
                       %control-pwexit = if_abap_behv=>mk-on
                       %control-plant = if_abap_behv=>mk-on
                   )  )
         REPORTED DATA(update_reported).

  ENDMETHOD.

ENDCLASS.
