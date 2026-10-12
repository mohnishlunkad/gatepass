@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Delivery Order Data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_DELORD
  as select distinct from I_DeliveryDocumentItem as DeliveryItem
    inner join            I_DeliveryDocument     as DeliveryHeader on DeliveryItem.DeliveryDocument = DeliveryHeader.DeliveryDocument
{
  key DeliveryItem.DeliveryDocument    as OrdNum,
      //      'S'                              as InType,
      case DeliveryItem.DistributionChannel
        when '30' then 'P'           
        else 'S'
      end                              as INType,
      DeliveryItem.DistributionChannel as DChannel,
      DeliveryItem.Plant               as Plant,
      DeliveryItem.ReferenceSDDocument as Sorder
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
