@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Delivery Item Data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_deliveryItem_data
  as select from I_DeliveryDocumentItem         as DeliveryItem
    inner join   I_SalesOrderItemPricingElement as Price on  Price.SalesOrder     = DeliveryItem.ReferenceSDDocument
                                                         and Price.SalesOrderItem = DeliveryItem.ReferenceSDDocumentItem
                                                         and Price.ConditionType  = 'ZPPR'


{
  key DeliveryItem.DeliveryDocument,
  key DeliveryItem.DeliveryDocumentItem,
      DeliveryItem.ReferenceSDDocument,
      DeliveryItem.ReferenceSDDocumentItem,
      DeliveryItem.Material,
      cast(Price.ConditionRateValue as abap.dec( 13, 2 ) ) as Rate

}
