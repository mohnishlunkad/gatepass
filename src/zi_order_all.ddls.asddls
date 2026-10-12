@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales and Purchase Order Data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_ORDER_ALL
  as select from ZI_DELORD_OPEN
{
  key OrdNum,
      'S'      as InType,
      DChannel as Dchannel,
      Plant    as Plant,
      Status
}
where
Status = 'O'

union select distinct from ZI_POORD
{
  key OrdNum,
      InType,
      Dchannel,
      Plant,
      Status
}
