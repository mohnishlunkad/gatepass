@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inward Data Header Data'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_VEHIN_HEAD_DATA
  as select from ZI_VEHIN_HEAD_A as _Head
  association [1..*] to ZI_VEHIN_ITEM_DATA as _Item on _Item.inward_uuid = $projection.inward_uuid

{
  key inward_uuid,
      ticknum,
      plant,
      PlantAdd,
      Name,
      Idate,
      Itime,
      vehnum,
      drivnum,
      orderhead,
      Tdate,
      Ttime,
      Gdate,
      Gtime,
      Edate,
      Etime,
      UoM,
      @Semantics.quantity.unitOfMeasure : 'UoM'
      TareWeight,
      @Semantics.quantity.unitOfMeasure : 'UoM'
      GrossWeight,
      @Semantics.quantity.unitOfMeasure : 'UoM'
      LoadedWeight,
      duration,
      Invoice,
      Division,
      Remark,
      dchannel,
      Product,
      RemarkLabel,

      /* Associations */
      _Item
}
