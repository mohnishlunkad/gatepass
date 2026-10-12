@AbapCatalog.sqlViewName: 'ZDDLSPODATA'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Order Data'
define view ZI_PORDER_DATA
  as select from    I_PurchaseOrderAPI01     as Header
    left outer join I_PurchaseOrderItemAPI01 as Item on Header.PurchaseOrder = Item.PurchaseOrder
{
  key Header.PurchaseOrder      as POrder,
      Item.PurchaseOrderItem    as OrderItem,
      '30'                      as distributionchannel,
      Item.Plant,
      Item.Material                as Material,
      //      Item.PurchaseOrderQuantityUnit as Uom,
      sum(Item.OrderQuantity)   as Quantity,
      sum(Item.ItemGrossWeight) as GrossWeight,
      sum(Item.ItemNetWeight)   as NetWeight
}
group by
  Header.PurchaseOrder,
  Item.PurchaseOrderItem,
  Item.Plant,
  Item.Material
//  Item.PurchaseOrderQuantityUnit
