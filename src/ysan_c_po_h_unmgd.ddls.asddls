@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Header Consumption View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity YSAN_C_PO_H_UNMGD 
provider contract transactional_query
as projection on YSAN_I_PO_H_UNMGD
{
    key PurchaseOrder,
    Vendor,
   @Semantics.amount.currencyCode : 'currency'
    Grossamount,
    Currency,
    Status,
    StatusText,
      @Semantics.user.createdBy: true
     LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
     LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
       LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
    /* Associations */
    _item: redirected to composition child YSAN_C_PO_I_UNMGD
}
