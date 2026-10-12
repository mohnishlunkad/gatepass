@AbapCatalog.sqlViewName: 'ZDDLSODATA'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order Data'
define view ZI_SORDER_DATA
  as select from ZI_DELORD              as Header
    inner join   I_DeliveryDocumentItem as Item on Header.OrdNum = Item.DeliveryDocument
{
  key Header.OrdNum                    as SOrder,
      Header.DChannel                  as DistributionChannel,
      Header.Plant                     as Plant,
      Header.Sorder                    as OrdNum,
      Item.DeliveryDocumentItem        as OrderItem,
      Item.Material                    as Material,
//      Item.DeliveryQuantityUnit        as uom,
      sum(Item.ActualDeliveryQuantity) as Quantity,
      sum(Item.ItemGrossWeight)        as GrossWeight,
      sum(Item.ItemNetWeight)          as Netweight
}
group by
  Header.OrdNum,
  Header.DChannel,
  Header.Plant,
  Header.Sorder,
  Item.DeliveryDocumentItem,
  Item.Material
//  Item.DeliveryQuantityUnit
