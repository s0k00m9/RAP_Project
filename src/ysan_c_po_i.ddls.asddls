@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Item Consumption View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity YSAN_C_PO_I
  as projection on YSAN_I_PO_I
{
  key PurchaseOrder,
  key ItemNum,
      Matnr,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      Quantity,
      Uom,
      @Semantics.amount.currencyCode : 'currency'
      NetPrice,
      Currency,
      @Semantics.amount.currencyCode : 'currency'
      subtotal,
      @Semantics.user.createdBy: true
      LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt1,
      /* Associations */
      _order : redirected to parent YSAN_C_PO_H
}
