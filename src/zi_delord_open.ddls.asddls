@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Unused Delivery Data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_DELORD_OPEN
  as select from    ZI_DELORD      as OpenDelivery
    left outer join ZI_DELORD_USED as UsedDelivery on OpenDelivery.OrdNum = UsedDelivery.Ordnum

{
  key OpenDelivery.OrdNum,
      OpenDelivery.InType,
      OpenDelivery.DChannel,
      OpenDelivery.Plant,
      OpenDelivery.Sorder,
      case
        when UsedDelivery.Status = 'U'
            then UsedDelivery.Status
            else 'O'
      end as Status
}
