@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Unused Delivery Data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_DORDERITEM_OPEN
  as select from    ZI_DORDER_ITEM      as OpenDelivery
    left outer join ZI_DORDITEM_USED as UsedDelivery on OpenDelivery.Ordnum = UsedDelivery.Ordnum
                                                        and ( UsedDelivery.OrdNumItem = OpenDelivery.OrdNumItem  
                                                              or UsedDelivery.OrdNumItem = '000000' )  
{
  key OpenDelivery.Ordnum,
      OpenDelivery.OrdNumItem,
      case
        when UsedDelivery.Status = 'U'
            then UsedDelivery.Status
            else 'O'
      end as Status
}
