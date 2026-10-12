@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Document Flow'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Zi_salesdocitmsubsqntprocflow as select from I_SalesDocItmSubsqntProcFlow
{
    key SalesDocument,
    key SalesDocumentItem,
    key DocRelationshipUUID,
    SDDocumentCategory,
    SubsequentDocument,
    SubsequentDocumentItem,
    SubsequentDocumentCategory,
    ProcessFlowLevel,
    SubsqntDocItmPrecdgDocument,
    SubsqntDocItmPrecdgDocItem,
    SubsqntDocItmPrecdgDocCategory,
    CreationDate,
    CreationTime,
    LastChangeDate,
    SalesDocumentType,
    SalesOrganization,
    DistributionChannel,
    OrganizationDivision,
    /* Associations */
    _SalesDocument,
    _SalesDocumentItem
}
