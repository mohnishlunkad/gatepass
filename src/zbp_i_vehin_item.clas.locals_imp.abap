CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS setinwardtype FOR DETERMINE ON MODIFY
      IMPORTING keys FOR item~setinwardtype.
    METHODS validateorder FOR VALIDATE ON SAVE
      IMPORTING keys FOR item~validateorder.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR item RESULT result.
    METHODS calctotalweight FOR DETERMINE ON SAVE
      IMPORTING keys FOR item~calctotalweight.
ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD setinwardtype.
    DATA: lv_cnt TYPE i.
    READ ENTITIES OF zi_vehin_head IN LOCAL MODE
        ENTITY item
            ALL FIELDS WITH CORRESPONDING #( keys )
                RESULT DATA(items).

    READ ENTITIES OF zi_vehin_head IN LOCAL MODE
            ENTITY item BY \_head
                ALL FIELDS WITH CORRESPONDING #( keys )
                    RESULT DATA(heads)
                    LINK   DATA(link)
                    FAILED DATA(failed)
                    REPORTED DATA(reported1).

    TRY.
        DATA(ls_head) = heads[ 1 ].
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        DATA(ls_item) = items[ 1 ].
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    LOOP AT items INTO DATA(ls_itemtemp).
      lv_cnt = lv_cnt + 1.
      IF lv_cnt = 2.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF lv_cnt > 1.
      RETURN.
    ENDIF.

    IF ls_item-intype IS INITIAL.

      SELECT SINGLE
          FROM zi_vehicle_inward_item_data
              FIELDS MAX( inwarditem ) AS inwarditem
                  WHERE inwarduuid = @ls_item-inward_uuid
                    INTO @DATA(max_inwarditem).

      MODIFY ENTITIES OF zi_vehin_head IN LOCAL MODE
                ENTITY item
                    UPDATE SET FIELDS WITH VALUE #(
                            FOR it IN items (
                                %key = it-%key
                                %is_draft = it-%is_draft
                                intype = ls_head-intype
                                inwarditem = max_inwarditem + 1
                                dchannel = ls_head-dchannel
                                plant = ls_head-plant
                           "     %control = value (  )
                            )
                    ) REPORTED DATA(modifyreported).
      reported = CORRESPONDING #( DEEP modifyreported ).

    ELSEIF ls_item-ordnum IS NOT INITIAL.   " AND ls_item-ordnumitem IS NOT INITIAL.
      IF ls_item-intype = 'S'.
        IF ls_head-dchannel = '10'
        OR ls_head-dchannel = '35'.
          SELECT SINGLE SUM( quantity ) AS quantity,
                        SUM( grossweight ) AS grossweight,
                        SUM( netweight ) AS netweight,
                        ordnum
                        FROM zi_sorder_data
                             WHERE sorder = @ls_item-ordnum
*                             AND orderitem = @ls_item-ordnumitem
                        GROUP BY ordnum
                                 INTO @DATA(ls_data).
          SELECT material,
                  orderitem
               FROM zi_sorder_data
                 WHERE sorder = @ls_item-ordnum
              ORDER BY orderitem
                INTO TABLE @DATA(lt_itemdata).
          TRY.
              DATA(ls_itemdata) = lt_itemdata[ 1 ].
            CATCH cx_sy_itab_line_not_found.
          ENDTRY.
        ELSEIF ls_head-dchannel = '15'.
          SELECT SINGLE quantity,
                    grossweight,
                    netweight,
                    ordnum
                   FROM zi_sorder_data
                         WHERE sorder = @ls_item-ordnum
                         AND   orderitem = @ls_item-ordnumitem
                         INTO @ls_data.

          SELECT material,
                 orderitem
            FROM zi_sorder_data
              WHERE sorder = @ls_item-ordnum
              AND   orderitem = @ls_item-ordnumitem
           ORDER BY orderitem
             INTO TABLE @lt_itemdata.
          TRY.
              ls_itemdata = lt_itemdata[ 1 ].
            CATCH cx_sy_itab_line_not_found.
          ENDTRY.
        ENDIF.
        SELECT SINGLE
                salesorderdate,
                soldtoparty,
                organizationbpname1,
                partner~fullname,
                bpname~fullname AS bpname
                    FROM zi_salesorder AS order
                          LEFT OUTER JOIN zi_customer AS customer
                              ON customer~customer = order~soldtoparty
                                LEFT OUTER JOIN zi_salesorderpartner AS partner
                                    ON partner~salesorder = order~salesorder
                                    AND partner~partnerfunction = 'ZB'
                                        LEFT OUTER JOIN zi_salesorderpartner AS bpname
                                            ON bpname~salesorder = order~salesorder
                                            AND bpname~partnerfunction = 'RE'
                        WHERE order~salesorder = @ls_data-ordnum
                            INTO @DATA(ls_odata).

      ELSEIF ls_item-intype = 'P'.
        SELECT SINGLE
*              purchaseorderdate,
*              order~supplier,
      purchaseorderdate AS salesorderdate,
      order~supplier AS soldtoparty,
              organizationbpname1,
              supplierfullname AS fullname,
              suppliername AS bpname
                  FROM zi_purchaseorderapi01 AS order
                        INNER JOIN zi_supplier AS supplier
                                ON supplier~supplier = order~supplier
                      WHERE purchaseorder = @ls_item-ordnum
                          INTO @ls_odata.

        SELECT SINGLE SUM( quantity ) AS quantity,
                      SUM( grossweight * quantity ) AS grossweight,
                      SUM( netweight * quantity ) AS netweight,
                      porder AS ordnum
                    FROM zi_porder_data
                          WHERE porder = @ls_item-ordnum
*                          AND orderitem = @ls_item-ordnumitem

                                                GROUP BY porder
                              INTO @ls_data.


        IF ls_item-matnr IS INITIAL.
          SELECT material,
                   orderitem
                FROM zi_porder_data
                  WHERE porder = @ls_item-ordnum
               ORDER BY orderitem
                 INTO TABLE @lt_itemdata.
          TRY.
              ls_itemdata = lt_itemdata[ 1 ].
            CATCH cx_sy_itab_line_not_found.
          ENDTRY.
        ENDIF.
      ENDIF.



      IF ls_itemtemp-ordnumitem IS NOT INITIAL.
        MODIFY ENTITIES OF zi_vehin_head IN LOCAL MODE
               ENTITY item
                   UPDATE SET FIELDS WITH VALUE #(
                           FOR it IN items (
                               %key = it-%key
                               %is_draft = it-%is_draft
                               orderdate = ls_odata-salesorderdate
                               bpcode    = ls_odata-soldtoparty
                               bpname    = ls_odata-bpname  "ls_odata-organizationbpname1
                               brokername = ls_odata-fullname
                               quantity =  ls_data-quantity
  "                             uom      = ls_data-uom
                               grossweight = ls_data-grossweight
                               netweight = ls_data-netweight
                               dchannel = ls_head-dchannel
                               plant = ls_head-plant
                               matnr = ls_itemdata-material
            "                   ordnumitem = ls_itemdata-orderitem
                          "     %control = value (  )
                           )
                   ) REPORTED modifyreported.
        reported = CORRESPONDING #( DEEP modifyreported ).
      ELSE.
        MODIFY ENTITIES OF zi_vehin_head IN LOCAL MODE
               ENTITY item
                   UPDATE SET FIELDS WITH VALUE #(
                           FOR it IN items (
                               %key = it-%key
                               %is_draft = it-%is_draft
                               orderdate = ls_odata-salesorderdate
                               bpcode    = ls_odata-soldtoparty
                               bpname    = ls_odata-bpname  "ls_odata-organizationbpname1
                               brokername = ls_odata-fullname                               quantity =  ls_data-quantity
  "                             uom      = ls_data-uom
                               grossweight = ls_data-grossweight
                               netweight = ls_data-netweight
                               dchannel = ls_head-dchannel
                               plant = ls_head-plant
                               matnr = ls_itemdata-material
                               ordnumitem = ls_itemdata-orderitem
                          "     %control = value (  )
                           )
                   ) REPORTED modifyreported.
        reported = CORRESPONDING #( DEEP modifyreported ).

      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD validateorder.
    READ ENTITIES OF zi_vehin_head IN LOCAL MODE
        ENTITY item
            ALL FIELDS WITH CORRESPONDING #( keys )
                RESULT DATA(items).

    TRY.
        DATA(ls_item) = items[ 1 ].
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    IF ls_item-ordnum IS INITIAL.
      APPEND VALUE #(
               %tky = ls_item-%tky
               %msg = new_message_with_text(
               severity = if_abap_behv_message=>severity-error
               text     = |{ TEXT-001 }|
            )

            ) TO reported-item.
      APPEND VALUE #( %tky = ls_item-%tky ) TO failed-item.
    ENDIF.

    IF ls_item-intype = 'S'.
      LOOP AT items INTO DATA(ls_itemall).
        SELECT SINGLE ordnum
                     FROM zi_sorder_data
                           WHERE sorder = @ls_itemall-ordnum
                           AND   orderitem = @ls_itemall-ordnumitem
                               INTO @DATA(lv_ordnum).
        IF sy-subrc <> 0.
          APPEND VALUE #(
             %tky = ls_itemall-%tky
             %msg = new_message_with_text(
             severity = if_abap_behv_message=>severity-error
             text     = |{ TEXT-003 } { ls_itemall-ordnum } { ls_itemall-ordnumitem }|
          )

          ) TO reported-item.
          APPEND VALUE #( %tky = ls_item-%tky ) TO failed-item.

        ELSE.

        ENDIF.


        CHECK ls_item-dchannel = '15'.
        IF ls_item-bpcode <> ls_itemall-bpcode.
          APPEND VALUE #(
             %tky = ls_itemall-%tky
             %msg = new_message_with_text(
             severity = if_abap_behv_message=>severity-error
             text     = |{ TEXT-004 } { ls_item-bpcode },{ ls_itemall-bpcode }|
          )
          ) TO reported-item.
          APPEND VALUE #( %tky = ls_item-%tky ) TO failed-item.
        ENDIF.

        IF ls_item-matnr <> ls_itemall-matnr.
          APPEND VALUE #(
             %tky = ls_itemall-%tky
             %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
             text     = |{ TEXT-005 } { ls_item-matnr },{ ls_itemall-matnr }|
          )
          ) TO reported-item.
          APPEND VALUE #( %tky = ls_item-%tky ) TO failed-item.
        ENDIF.
      ENDLOOP.

      CHECK ls_item-dchannel = '15'.
      SELECT SINGLE bpcode
          FROM zi_vehicle_inward_item_data
      WHERE inwarduuid = @ls_item-inward_uuid
      AND   bpcode <> @ls_item-bpcode
      INTO @DATA(lv_bpcode).
      IF lv_bpcode IS NOT INITIAL.
        APPEND VALUE #(
         %tky = ls_itemall-%tky
         %msg = new_message_with_text(
         severity = if_abap_behv_message=>severity-error
         text     = |{ TEXT-004 } { ls_item-bpcode },{ ls_itemall-bpcode }|
      )
      ) TO reported-item.
        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-item.
      ENDIF.

      SELECT SINGLE matnr
          FROM zi_vehicle_inward_data
      WHERE inwarduuid = @ls_item-inward_uuid
      AND   matnr <> @ls_item-matnr
      INTO @DATA(lv_matnr).
      IF lv_matnr IS NOT INITIAL.
        APPEND VALUE #(
         %tky = ls_itemall-%tky
         %msg = new_message_with_text(
         severity = if_abap_behv_message=>severity-error
         text     = |{ TEXT-005 } { lv_matnr },{ ls_itemall-matnr }|
      )
      ) TO reported-item.
        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-item.
      ENDIF.
    ELSEIF ls_item-intype = 'P'.

    ENDIF.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zi_vehin_head IN LOCAL MODE ENTITY
          head ALL FIELDS WITH CORRESPONDING #( keys )
              RESULT DATA(heads).

    TRY.
        DATA(ls_head) = heads[ 1 ].
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    READ ENTITIES OF zi_vehin_head IN LOCAL MODE
        ENTITY head BY \_item
            ALL FIELDS WITH VALUE #( ( %tky = ls_head-%tky ) )
                RESULT DATA(items).

    LOOP AT items INTO DATA(ls_item).
      APPEND VALUE #(

                     %tky = ls_item-%tky

                     %field-ordnumitem = COND #( WHEN ( ls_item-dchannel = '10'
                     OR ls_item-dchannel = '30'
                     OR ls_item-dchannel = '35'
                     OR ls_item-ordnumitem IS NOT INITIAL )
                      THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-mandatory )

                    %field-ordnum = COND #( WHEN ls_item-ordnum IS NOT INITIAL
                      THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-mandatory )

    ) TO result.

    ENDLOOP.

*    result =   VALUE #(
*                      FOR ls_item IN items
*                      ( %tky = ls_item-%tky
*
*                      %field-ordnumitem = COND #( WHEN ( ls_item-dchannel = '10' OR ls_item-ordnumitem IS NOT INITIAL )
*                      THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-mandatory ) )
*
*                      %field-ordnum = COND #( WHEN ls_item-ordnum IS NOT INITIAL
*                      THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-mandatory )
*
*
*                       ( %update = if_abap_behv=>fc-o-disabled )
*
*                      ).


  ENDMETHOD.

  METHOD calctotalweight.
    DATA: lv_grwg TYPE p DECIMALS 3,
          lv_ntwg TYPE p DECIMALS 3.

    READ ENTITIES OF zi_vehin_head IN LOCAL MODE ENTITY
          head ALL FIELDS WITH CORRESPONDING #( keys )
              RESULT DATA(heads).

    TRY.
        DATA(ls_head) = heads[ 1 ].
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    READ ENTITIES OF zi_vehin_head IN LOCAL MODE
        ENTITY head BY \_item
            ALL FIELDS WITH VALUE #( ( %tky = ls_head-%tky ) )
                RESULT DATA(allitems).

    LOOP AT allitems INTO DATA(ls_allitem).
      lv_grwg = lv_grwg + ls_allitem-grossweight.
      lv_ntwg = lv_ntwg + ls_allitem-netweight.
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
ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
