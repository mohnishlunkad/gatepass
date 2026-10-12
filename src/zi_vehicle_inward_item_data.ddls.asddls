@AbapCatalog.sqlViewName: 'ZVEHINITEM'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vehicle Inward Item Data'
define view ZI_VEHICLE_INWARD_ITEM_DATA
  as select from zdt_vehin_item as Item
        inner join zdt_vehin_head as Head on Head.inward_uuid = Item.inward_uuid
{
  key Item.item_uuid   as ItemUuid,
  key Item.inward_uuid as InwardUuid,
      Head.ticknum     as Ticknum,
      Item.inwarditem  as Inwarditem,
      Item.ordnum      as Ordnum,
      Item.ordnumitem  as OrdNumItem,
      Item.orderdate   as Orderdate,
      Item.bpcode      as Bpcode,
      Item.bpname      as Bpname,
      Item.brokername  as Brokername,
      Item.intype      as Intype
}
union select from zdt_vehin_item_d as Item
        inner join zdt_vehin_head_d as Head on Head.inward_uuid = Item.inward_uuid
{
  key Item.item_uuid   as ItemUuid,
  key Item.inward_uuid as InwardUuid,
      Head.ticknum     as Ticknum,
      Item.inwarditem  as Inwarditem,
      Item.ordnum      as Ordnum,
      Item.ordnumitem  as OrdNumItem,
      Item.orderdate   as Orderdate,
      Item.bpcode      as Bpcode,
      Item.bpname      as Bpname,
      Item.brokername  as Brokername,
      Item.intype      as Intype
}
