@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Order Data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_POORD
  as select distinct from I_PurchaseOrderItemAPI01 as PurchaseOrder
{
  key PurchaseOrder.PurchaseOrder as OrdNum,
      'P'                         as InType,
      '30'                        as Dchannel,
      PurchaseOrder.Plant         as Plant,
      'P'                         as Status
}
where
      PurchasingDocumentDeletionCode = ''
  and IsCompletelyDelivered          = ''
