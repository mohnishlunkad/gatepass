@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Vehicle Inward Item BO View'
define view entity ZI_VEHIN_ITEM
  as select from zdt_vehin_item as _Item
  association to parent ZI_VEHIN_HEAD as _Head on $projection.inward_uuid = _Head.Inward_Uuid
{
  key item_uuid             as Item_Uuid,
  key inward_uuid           as inward_uuid,
      inwarditem            as Inwarditem,
      ordnum                as Ordnum,
      ordnumitem            as Ordnumitem,
      orderdate             as Orderdate,
      bpcode                as Bpcode,
      bpname                as Bpname,
      brokername            as Brokername,
      quantity              as Quantity,
      uom                   as uom,
      grossweight           as GrossWeight,
      netweight             as NetWeight,
      intype                as intype,
      dchannel              as Dchannel,
      plant                 as Plant,
      matnr                 as Matnr,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _Head
}
