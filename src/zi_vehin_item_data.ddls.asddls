@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inward Data Item Data'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_VEHIN_ITEM_DATA
  as select from ZI_VEHIN_ITEM_A
  //  association [1..1] to ZI_VEHIN_HEAD_DATA as _Head
  //    on _Head.inward_uuid = $projection.inward_uuid
{
  key inward_uuid,
  key item_uuid,
      inwarditem,
      ordnum,
      orderdate,
      bpcode,
      bpname,
      brokername,
      Quantity,
      Lquantity
      /* Associations */
      //      _Head
}
