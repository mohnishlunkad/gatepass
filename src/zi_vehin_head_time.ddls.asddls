@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inward Data Header Data'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_VEHIN_HEAD_TIME
  as select from zdt_vehin_head as Head
{
  key Head.inward_uuid,
      indate,
      intime,
      pwexitdt,
      pwexittm,
      dats_tims_to_tstmp( indate, intime, abap_system_timezone( $session.client,'NULL' ), $session.client, 'NULL' )     as Intimestamp,
      dats_tims_to_tstmp( pwexitdt, pwexittm, abap_system_timezone( $session.client,'NULL' ), $session.client, 'NULL' ) as Outtimestamp
}
