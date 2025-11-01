@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Header Root View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity YSAN_I_PO_H_UNMGD
  as select from ysan_order_h
  composition[0..*] of YSAN_I_PO_I_UNMGD as _item
{
  key po_num                as PurchaseOrder,
      vendor                as Vendor,
      @Semantics.amount.currencyCode : 'currency'
      grossamount           as Grossamount,
      currency              as Currency,
      status                as Status,
      status_text  as StatusText,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
          _item
}
