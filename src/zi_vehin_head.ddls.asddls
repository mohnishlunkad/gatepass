@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Vehicle Inward Header BO View'
define root view entity ZI_VEHIN_HEAD
  as select from zdt_vehin_head as _Head
  composition [0..*] of ZI_VEHIN_ITEM as _Item
{
  key inward_uuid           as Inward_Uuid,
      ticknum               as Ticknum,
      fiscal                as Fiscal,
      intype                as Intype,
      indate                as Indate,
      intime                as Intime,
      vehnum                as Vehnum,
      drivnum               as Drivnum,
      orderhead             as Orderhead,
      orderhead             as Orderhead1,
      plant                 as Plant,
      type                  as Type,
      dchannel              as Dchannel,
      range                 as Range,
      printform             as printform,
      pwidate               as pwidate,
      pwiempwg              as pwiempwg,
      pwigetwg              as pwigetwg,
      pwitime               as pwitime,
      pwiuom                as pwiuom,
      grossweight           as grossweight,
      netweight             as netweight,
      pwogetwg              as pwogetwg,
      pwexit                as pwexit,
      pwexitdt              as pwexitdt,
      pwexittm              as pwexittm,
      lweight               as lweight,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _Item
}
