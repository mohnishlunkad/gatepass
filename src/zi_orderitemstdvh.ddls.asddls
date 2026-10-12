@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Order Item Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_ORDERITEMSTDVH
  as select distinct from ZI_DORDERITEM_OPEN
{
  key OrdNumItem,
  key Ordnum    
}
//where Status = 'O' 
