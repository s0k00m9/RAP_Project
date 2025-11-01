CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR item RESULT result.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE item.

    METHODS determine_header_totals FOR DETERMINE ON MODIFY
      IMPORTING keys FOR item~determine_header_totals.

    METHODS determine_sub_totals FOR DETERMINE ON MODIFY
      IMPORTING keys FOR item~determine_sub_totals.

    METHODS test.
ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF ysan_i_po_h IN LOCAL MODE
         ENTITY item
         BY \_order
         FIELDS ( PurchaseOrder Status )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_orders)
         REPORTED DATA(lt_reported)
         FAILED DATA(lt_failed).
    READ ENTITIES OF ysan_i_po_h IN LOCAL MODE
      ENTITY item
      FIELDS ( PurchaseOrder ItemNum )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items)
      REPORTED lt_reported
      FAILED lt_failed.
    IF lt_failed IS INITIAL.
      result = VALUE #( FOR <lfs_items> IN lt_items
                       LET ls_orders = VALUE #( lt_orders[ %key = <lfs_items>-%key ] OPTIONAL )
                         lv_flag = COND #( WHEN  ls_orders-status EQ 'C' THEN if_abap_behv=>fc-o-disabled
                                              ELSE if_abap_behv=>fc-o-enabled ) IN
                        ( %key = <lfs_items>-%key "Here we are looping header hence we need to pass corresponding Item key
                          %features-%delete = lv_flag
                         ) ).
    ENDIF.
  ENDMETHOD.

  METHOD precheck_update.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entities>).
      IF <lfs_entities>-Matnr CA 'ABCabc'.
        failed-item = VALUE #( BASE failed-item
                                        ( %tky = <lfs_entities>-%tky ) ).
        reported-item = VALUE #( BASE reported-item
                                ( %msg = new_message(
                                           id       = '00'
                                           number   = '001'
                                           severity = if_abap_behv_message=>severity-error
                                            v1       = 'Article Cannot contain aplhabets'
                                         )
                                   %tky =  <lfs_entities>-%tky
                                   %element-matnr = if_abap_behv=>mk-on     ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD determine_header_totals.
*  Way  1: Directly updating the associated entity from original entity(Updating header with item keys)
    READ ENTITIES OF ysan_i_po_h IN LOCAL MODE
          ENTITY item
          ALL FIELDS
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_items)
          REPORTED DATA(lt_reported)
          FAILED DATA(lt_failed).


    IF lt_failed IS INITIAL.

      DATA(lv_amount) = REDUCE currencysap( INIT lv_amt = 0
                                           FOR <lfs_items> IN lt_items
                                           NEXT
                                           lv_amt = <lfs_items>-Quantity * <lfs_items>-NetPrice + lv_amt

                                           ).
      MODIFY ENTITIES OF ysan_i_po_h IN LOCAL MODE
              ENTITY order
              UPDATE FIELDS ( Grossamount Currency )
              WITH VALUE #( FOR <lfs_keys> IN keys
                            ( %tky = CORRESPONDING #(  <lfs_keys>-%tky ) "Here instead of header, we are using item keys to map the corresponding header. This works from item to header
                                                                         "Because PO=1000000001 Item-0001 can move to header key PO NUM but not viceversa., there we need to follow way 2
                              Grossamount =  lv_amount
                              Currency = lt_items[ 1 ]-Currency
                              %control-Grossamount = if_abap_behv=>mk-on
                              %control-Currency =  if_abap_behv=>mk-on  ) ).



    ENDIF.
*  Way  2: Using Associated Entity loop and updating in Two step process
*    READ ENTITIES OF ysan_i_po_h IN LOCAL MODE
*          ENTITY item
*          ALL FIELDS
*          WITH CORRESPONDING #( keys )
*          RESULT DATA(lt_items)
*          REPORTED DATA(lt_reported)
*          FAILED DATA(lt_failed).
*
*    READ ENTITIES OF ysan_i_po_h IN LOCAL MODE
*         ENTITY item
*         BY \_order
*         FIELDS ( PurchaseOrder Grossamount )
*         WITH CORRESPONDING #( keys )
*         RESULT DATA(lt_orders)
*         REPORTED lt_reported
*         FAILED lt_failed.
*    IF lt_failed IS INITIAL.
*
*      DATA(lv_amount) = REDUCE currencysap( INIT lv_amt = 0
*                                           FOR <lfs_items> IN lt_items
*                                           NEXT
*                                           lv_amt = <lfs_items>-Quantity * <lfs_items>-NetPrice + lv_amt
*
*                                           ).
*      MODIFY ENTITIES OF ysan_i_po_h IN LOCAL MODE
*              ENTITY order
*              UPDATE FIELDS ( Grossamount Currency )
*              WITH VALUE #( FOR <lfs_keys> IN lt_orders
*                            ( %tky = <lfs_keys>-%tky
*                              Grossamount =  lv_amount
*                              Currency = lt_items[ 1 ]-Currency
*                              %control-Grossamount = if_abap_behv=>mk-on
*                              %control-Currency =  if_abap_behv=>mk-on  ) ).
*
*
*
*    ENDIF.
  ENDMETHOD.

  METHOD determine_sub_totals.
    READ ENTITIES OF ysan_i_po_h IN LOCAL MODE
       ENTITY item
       FIELDS ( Quantity NetPrice )
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_items)
       REPORTED DATA(lt_reported)
       FAILED DATA(lt_failed).
    IF lt_failed IS INITIAL.
      MODIFY ENTITIES OF ysan_i_po_h IN LOCAL MODE
              ENTITY item
              UPDATE FIELDS ( subtotal )
              WITH VALUE #( FOR <lfs_items> IN lt_items
                            ( %tky = <lfs_items>-%tky
                              subtotal =  <lfs_items>-Quantity * <lfs_items>-NetPrice
                              %control-subtotal = if_abap_behv=>mk-on
                               ) ).
    ENDIF.
  ENDMETHOD.

  METHOD test.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_order DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR order RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR order RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR order RESULT result.

    METHODS confirm_order FOR MODIFY
      IMPORTING keys FOR ACTION order~confirm_order RESULT result.

    METHODS validate_vendor FOR VALIDATE ON SAVE
      IMPORTING keys FOR order~validate_vendor.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE order.

    METHODS earlynumbering_cba_Item FOR NUMBERING
      IMPORTING entities FOR CREATE order\_Item.

ENDCLASS.

CLASS lhc_order IMPLEMENTATION.

  METHOD get_instance_authorizations.

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    SELECT  MAX( po_num ) AS po_snro
           FROM ysan_order_h
           UNION
           SELECT MAX( purchaseorder ) AS po_snro
           FROM ysan_order_h_d
           ORDER BY po_snro DESCENDING
           INTO TABLE @DATA(lt_snro).
    IF sy-subrc EQ 0.
      SELECT MAX( po_snro )
              FROM @lt_snro AS posnro
       INTO @DATA(lv_po_num_next).
    ENDIF.
    IF lv_po_num_next IS INITIAL.
      lv_po_num_next = '100000000'.
    ENDIF.

    "Mapped doesn't have %tky this applies to draft related data for validation, determination etc.,
    mapped-order = VALUE #( BASE mapped-order
                            FOR <lfs_order> IN entities
                            ( %cid =  <lfs_order>-%cid
                              %key-PurchaseOrder =  lv_po_num_next + 1
                              %is_draft =  <lfs_order>-%is_draft
                               ) ).
  ENDMETHOD.
  METHOD earlynumbering_cba_Item.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entity_item>).
      SELECT  MAX( item_num ) AS po_item_num
                FROM ysan_order_i WHERE po_num = @<lfs_entity_item>-PurchaseOrder
                UNION
                SELECT MAX( itemnum ) AS po_item_num
                FROM ysan_order_i_d
                WHERE purchaseorder = @<lfs_entity_item>-PurchaseOrder
                ORDER BY po_item_num DESCENDING
                INTO TABLE @DATA(lt_snro).
      IF sy-subrc EQ 0.
        SELECT MAX( po_item_num )
                FROM @lt_snro AS posnro_item
         INTO @DATA(lv_po_itemnum_next).

      ENDIF.
      IF lv_po_itemnum_next IS INITIAL.
        lv_po_itemnum_next = 0.
      ENDIF.
      mapped-item = VALUE #( BASE mapped-item
                            FOR <lfs_item> IN <lfs_entity_item>-%target
                            ( %cid =    <lfs_item>-%cid "Here from parent we can use CID_REF <lfs_entity_item>-%cid_ref or we can directly use the child entity
                              %key-PurchaseOrder =  <lfs_item>-PurchaseOrder
                              %key-ItemNum = lv_po_itemnum_next + 1
                              %is_draft =  <lfs_item>-%is_draft
                               ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF ysan_i_po_h IN LOCAL MODE
       ENTITY order
       FIELDS ( PurchaseOrder Status )
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_orders)
       REPORTED DATA(lt_reported)
       FAILED DATA(lt_failed).
    IF lt_failed IS INITIAL.
      result = VALUE #( FOR <lfs_orders> IN lt_orders
                        LET lv_flag = COND #( WHEN  <lfs_orders>-status EQ 'C' THEN if_abap_behv=>fc-o-disabled
                                              ELSE if_abap_behv=>fc-o-enabled ) IN
                        ( %key =  <lfs_orders>-%key
                          %features-%action-confirm_order = lv_flag
                          %delete = lv_flag
                         ) ).
    ENDIF.
  ENDMETHOD.

    METHOD confirm_order.
  SELECT * from YSAN_I_PO_STATUS into table @data(lt_status).
    READ ENTITIES OF ysan_i_po_h IN LOCAL MODE
          ENTITY order
          FIELDS ( PurchaseOrder Status )
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_orders)
          REPORTED DATA(lt_reported)
          FAILED DATA(lt_failed).
    IF lt_failed IS INITIAL.
      MODIFY ENTITIES OF ysan_i_po_h IN LOCAL MODE
      ENTITY order
      UPDATE FIELDS ( Status StatusText )
      WITH VALUE #( FOR <lfs_orders> IN lt_orders
                    ( %key = <lfs_orders>-%key
                      %tky = <lfs_orders>-%tky
                      Status = 'C'
                      StatusText =  lt_status[ StatusCode = 'C' ]-Text
                      %control = VALUE #( Status = if_abap_behv=>mk-on
                                           StatusText = if_abap_behv=>mk-on ) ) ).
      result = VALUE #( FOR <lfs_orders> IN lt_orders
                        (
                        %key = <lfs_orders>-%key
                     %tky = <lfs_orders>-%tky
                     %param = <lfs_orders> ) ).
      reported-order = VALUE #( BASE reported-order
                                (  %msg = new_message( id = '00' number = '001' v1 = 'Purchase Order Confirmed' severity = if_abap_behv_message=>severity-success ) ) ).
    ENDIF.
  ENDMETHOD.


  METHOD validate_vendor.
    READ ENTITIES OF ysan_i_po_h IN LOCAL MODE
           ENTITY order
           FIELDS ( PurchaseOrder Vendor )
           WITH CORRESPONDING #( keys )
           RESULT DATA(lt_orders)
           REPORTED DATA(lt_reported)
           FAILED DATA(lt_failed).
    IF lt_failed IS INITIAL.
      LOOP AT lt_orders ASSIGNING FIELD-SYMBOL(<lfs_orders>).
        IF <lfs_orders>-Vendor CA '1234567890'.
          failed-order = VALUE #( BASE failed-order
                                  ( %tky = <lfs_orders>-%tky ) ).
          reported-order = VALUE #( BASE reported-order
                                  ( %msg = new_message(
                                             id       = '00'
                                             number   = '001'
                                             severity = if_abap_behv_message=>severity-error
                                              v1       = 'Vendor cannot be numeric'
                                           )
                                     %tky =  <lfs_orders>-%tky
                                     %element-vendor = if_abap_behv=>mk-on     ) ).
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
