@AbapCatalog.sqlViewName: 'ZVEHINW'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vehicle Inward Data'
define view ZI_VEHICLE_INWARD_DATA
  as select from zdt_vehin_head as Head
    inner join   zdt_vehin_item as Item on Head.inward_uuid = Item.inward_uuid
{
  key Head.inward_uuid as InwardUuid,
  key Item.item_uuid   as ItemUuid,
      Head.ticknum     as Ticknum,
      Head.intype      as Intype,
      Head.indate      as Indate,
      Head.intime      as Intime,
      Head.vehnum      as Vehnum,
      Head.drivnum     as Drivnum,
      Item.ordnum      as Ordnum,
      Item.ordnumitem  as Ordnumitem,
      Item.orderdate   as Orderdate,
      Item.bpcode      as Bpcode,
      Item.bpname      as Bpname,
      Item.brokername  as Brokername,
      Item.matnr       as Matnr
}
