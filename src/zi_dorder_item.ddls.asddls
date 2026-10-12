@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Delivery Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_DORDER_ITEM
  as select distinct from I_DeliveryDocumentItem as DeliveryItem
    inner join            I_DeliveryDocument     as DeliveryHeader on DeliveryItem.DeliveryDocument = DeliveryHeader.DeliveryDocument
{
  key DeliveryItem.DeliveryDocument                            as Ordnum,
  key cast(DeliveryItem.DeliveryDocumentItem as abap.numc(6) ) as OrdNumItem
}
where
  (
       DeliveryHeader.OverallSDProcessStatus = 'B'
    or DeliveryHeader.OverallSDProcessStatus = 'A'
    or DeliveryHeader.OverallSDProcessStatus = ''
  )

  and(
       DeliveryItem.DistributionChannel      = '10'
    or DeliveryItem.DistributionChannel      = '15'
    or DeliveryItem.DistributionChannel      = '30'
    or DeliveryItem.DistributionChannel      = '35'
  )
  and  DeliveryItem.HigherLvlItmOfBatSpltItm = '000000'
union

select distinct from I_PurchaseOrderItemAPI01 as PurchaseOrder
{
  key PurchaseOrder.PurchaseOrder                            as OrdNum,
  key cast(PurchaseOrder.PurchaseOrderItem as abap.char(6) ) as OrdNumItem

}
