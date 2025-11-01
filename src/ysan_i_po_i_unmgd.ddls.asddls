@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Item View'
@Metadata.ignorePropagatedAnnotations: true
define view entity YSAN_I_PO_I_UNMGD as select from ysan_order_i
association to parent YSAN_I_PO_H_UNMGD as _order on $projection.PurchaseOrder = _order.PurchaseOrder
{
    key po_num as PurchaseOrder,
    key item_num as ItemNum,
    matnr as Matnr,
     @Semantics.quantity.unitOfMeasure: 'Uom'
    quantity as Quantity,
    uom as Uom,
     @Semantics.amount.currencyCode : 'currency'
    net_price as NetPrice,
         @Semantics.amount.currencyCode : 'currency'
    cast(0.00 as abap.curr( 10, 2 )) as subtotal,
    currency as Currency,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at1       as LastChangedAt1,
    _order 
    }
