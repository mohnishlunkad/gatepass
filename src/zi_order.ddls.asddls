@AbapCatalog.sqlViewName: 'ZIORDER'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order Data'
define view ZI_ORDER
  as select from ZI_DELORD        //I_SalesOrder
{
      OrdNum,
      'S'        as InType
}
union select from I_PurchaseOrderAPI01
{
  key cast(PurchaseOrder as abap.char(10)) as OrdNum,
      'P'           as InType

}
