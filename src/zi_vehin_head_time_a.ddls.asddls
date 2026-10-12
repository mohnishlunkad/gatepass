@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Header Data Time'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_VEHIN_HEAD_TIME_A
  as select from ZI_VEHIN_HEAD_TIME
{
  key inward_uuid,
      indate,
      intime,
      pwexitdt,
      pwexittm,
      Intimestamp,
      Outtimestamp,
      tstmp_seconds_between(Intimestamp,Outtimestamp,'NULL') as Duration
}
