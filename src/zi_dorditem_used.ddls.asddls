@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Used Delivery Data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_DORDITEM_USED as select distinct from ZI_VEHICLE_INWARD_ITEM_DATA
{
    key Ordnum,   
    key OrdNumItem,
    'U' as Status
}
