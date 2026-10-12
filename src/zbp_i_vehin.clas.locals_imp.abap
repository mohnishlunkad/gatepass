CLASS lsc_zi_vehin_head DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_vehin_head IMPLEMENTATION.

  METHOD save_modified.
    CONSTANTS: lc_tzone TYPE cl_abap_context_info=>ty_time_zone VALUE 'UTC'.

    DATA: header       TYPE STANDARD TABLE OF zdt_vehin_head,
          header_u     TYPE STANDARD TABLE OF zdt_vehin_head,
          header_uexit TYPE STANDARD TABLE OF zdt_vehin_head,

          item         TYPE STANDARD TABLE OF zdt_vehin_item,
          item_u       TYPE STANDARD TABLE OF zdt_vehin_item,

          inward_id    TYPE RANGE OF zdt_vehin_head-inward_uuid,
          item_id      TYPE RANGE OF zdt_vehin_item-item_uuid.

    DATA background_process TYPE REF TO if_bgmc_process_single_op.


    IF create IS NOT INITIAL.
      header = CORRESPONDING #( create-head MAPPING FROM ENTITY ).
      item = CORRESPONDING #( create-item MAPPING FROM ENTITY ).

      GET TIME STAMP FIELD DATA(lv_timestamp).

      LOOP AT header ASSIGNING FIELD-SYMBOL(<fs_header>).
        <fs_header>-created_at = lv_timestamp.
      ENDLOOP.

      INSERT zdt_vehin_head FROM TABLE @header.
      INSERT zdt_vehin_item FROM TABLE @item.

      IF <fs_header> IS ASSIGNED.
        IF <fs_header>-plant = '1100'.
          DATA(new_1100) = NEW zcl_background_process_1100( ).
          TRY.
              background_process = cl_bgmc_process_factory=>get_default( )->create( ).
              background_process->set_operation_tx_uncontrolled( new_1100 ).
              background_process->save_for_execution( ).
            CATCH cx_bgmc INTO DATA(exception).
              "handle exception
          ENDTRY.

        ELSEIF <fs_header>-plant = '1200'.
          DATA(new_1200) = NEW zcl_background_process_1200( ).
          TRY.
              background_process = cl_bgmc_process_factory=>get_default( )->create( ).
              background_process->set_operation_tx_uncontrolled( new_1200 ).
              background_process->save_for_execution( ).
            CATCH cx_bgmc INTO exception.
              "handle exception
          ENDTRY.
        ELSEIF <fs_header>-plant = '2100'.
          DATA(new_2100) = NEW zcl_background_process_2100( ).
          TRY.
              background_process = cl_bgmc_process_factory=>get_default( )->create( ).
              background_process->set_operation_tx_uncontrolled( new_2100 ).
              background_process->save_for_execution( ).
            CATCH cx_bgmc INTO exception.
              "handle exception
          ENDTRY.
        ENDIF.
      ENDIF.
    ENDIF.


    IF update IS NOT INITIAL.
      header_u = CORRESPONDING #( update-head MAPPING FROM ENTITY  ).
      header_u = CORRESPONDING #( update-head mapping pwexit = pwexit ).

      item_u = CORRESPONDING #( update-item MAPPING FROM ENTITY ).

      GET TIME STAMP FIELD lv_timestamp.

      LOOP AT header_u ASSIGNING FIELD-SYMBOL(<fs_header_u>).
        <fs_header_u>-last_changed_at = lv_timestamp.
      ENDLOOP.
      LOOP AT item_u ASSIGNING FIELD-SYMBOL(<fs_item_u>).
        <fs_item_u>-local_last_changed_at = lv_timestamp.
      ENDLOOP.

      CHECK <fs_header_u> IS ASSIGNED.
      header_uexit = CORRESPONDING #( update-head MAPPING pwexit = pwexit ).
      LOOP AT header_uexit INTO DATA(ls_header_uexit).
        EXIT.
      ENDLOOP.

      IF ls_header_uexit-pwexit = ''.  "<fs_header_u>-pwexit = ''.
        IF header_u IS NOT INITIAL.
          UPDATE zdt_vehin_head FROM TABLE @header_u.
        ENDIF.
        IF item_u IS NOT INITIAL.
          UPDATE zdt_vehin_item FROM TABLE @item_u.
        ENDIF.

        IF <fs_header_u>-plant = '1100'.
          DATA(new1_1100) = NEW zcl_background_process_md_1100( ).
          TRY.
              background_process = cl_bgmc_process_factory=>get_default( )->create( ).
              background_process->set_operation_tx_uncontrolled( new1_1100 ).
              background_process->save_for_execution( ).
            CATCH cx_bgmc INTO exception.
              "handle exception
          ENDTRY.

        ELSEIF <fs_header_u>-plant = '1200'.
          DATA(new1_1200) = NEW zcl_background_process_md_1200( ).
          TRY.
              background_process = cl_bgmc_process_factory=>get_default( )->create( ).
              background_process->set_operation_tx_uncontrolled( new1_1200 ).
              background_process->save_for_execution( ).
            CATCH cx_bgmc INTO exception.
              "handle exception
          ENDTRY.

        ELSEIF <fs_header_u>-plant = '2100'.
          DATA(new1_2100) = NEW zcl_background_process_md_2100( ).
          TRY.
              background_process = cl_bgmc_process_factory=>get_default( )->create( ).
              background_process->set_operation_tx_uncontrolled( new1_2100 ).
              background_process->save_for_execution( ).
            CATCH cx_bgmc INTO exception.
              "handle exception
          ENDTRY.
        ENDIF.


      ELSEIF ls_header_uexit-pwexit = 'C'.  "<fs_header_u>-pwexit = 'C'.
        IF <fs_header_u>-plant = '1100'.
          DATA(new2_1100) = NEW zcl_background_process_ot_1100( ).
          TRY.
              background_process = cl_bgmc_process_factory=>get_default( )->create( ).
              background_process->set_operation_tx_uncontrolled( new2_1100 ).
              background_process->save_for_execution( ).
            CATCH cx_bgmc INTO exception.
              "handle exception
          ENDTRY.

        ELSEIF <fs_header_u>-plant = '1200'.
          DATA(new2_1200) = NEW zcl_background_process_ot_1200( ).
          TRY.
              background_process = cl_bgmc_process_factory=>get_default( )->create( ).
              background_process->set_operation_tx_uncontrolled( new2_1200 ).
              background_process->save_for_execution( ).
            CATCH cx_bgmc INTO exception.
              "handle exception
          ENDTRY.

        ELSEIF <fs_header_u>-plant = '2100'.
          DATA(new2_2100) = NEW zcl_background_process_ot_2100( ).
          TRY.
              background_process = cl_bgmc_process_factory=>get_default( )->create( ).
              background_process->set_operation_tx_uncontrolled( new2_2100 ).
              background_process->save_for_execution( ).
            CATCH cx_bgmc INTO exception.
              "handle exception
          ENDTRY.
        ENDIF.
      ENDIF.
    ENDIF.

    IF delete IS NOT INITIAL.
      inward_id = VALUE #( FOR ls_inward_id IN delete-head
                             ( sign = 'I' option ='EQ' low = ls_inward_id-inward_uuid )
                       ).
      item_id = VALUE #( FOR ls_item_id IN delete-item
                              ( sign = 'I' option ='EQ' low = ls_item_id-item_uuid )
                        ).

      GET TIME STAMP FIELD lv_timestamp.
      IF inward_id IS NOT INITIAL.
        DELETE FROM zdt_vehin_head WHERE inward_uuid IN @inward_id.
        DELETE FROM zdt_vehin_item WHERE inward_uuid IN @inward_id.
      ENDIF.
      IF item_id IS NOT INITIAL.

        SELECT SINGLE inward_uuid
        FROM zdt_vehin_item
        WHERE item_uuid IN @item_id
        INTO @DATA(lv_inward_uuid).

        DELETE FROM zdt_vehin_item WHERE item_uuid IN @item_id.
        UPDATE zdt_vehin_head SET last_changed_at = @lv_timestamp
                WHERE inward_uuid = @lv_inward_uuid.
      ENDIF.
    ENDIF.

    IF create IS INITIAL AND update IS INITIAL AND delete IS INITIAL.
      CHECK <fs_header_u> IS ASSIGNED.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
