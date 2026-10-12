@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inward Data Item Data'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_VEHIN_ITEM_A
  as select from    zdt_vehin_item         as Data
    left outer join I_DeliveryDocumentItem as DelvItem  on  DelvItem.DeliveryDocument     = Data.ordnum
                                                        and DelvItem.DeliveryDocumentItem = Data.ordnumitem
    left outer join I_SalesDocumentItem    as OrderItem on  OrderItem.SalesDocument     = DelvItem.ReferenceSDDocument
                                                        and OrderItem.SalesDocumentItem = DelvItem.ReferenceSDDocumentItem
    left outer join zdt_vehin_head         as Head      on Head.inward_uuid = Data.inward_uuid
{
  key Data.inward_uuid,
  key Data.item_uuid,
      Data.inwarditem,
      Data.ordnum,
      concat(
       concat(
         concat(substring(Data.orderdate, 7, 2), '/' ),
         concat(substring(Data.orderdate, 5, 2), '/' )
       ),
       substring(Data.orderdate, 1, 4)
      )                                                  as orderdate,
      Data.bpcode,
      Data.bpname,
      Data.brokername,
      cast(Data.quantity as abap.dec( 8, 3 ) ) as Quantity,
      // case
      //   when DelvItem.ActualDeliveryQuantity is not initial
      //      then cast(DelvItem.ActualDeliveryQuantity as abap.dec( 8, 3) )
      //   else cast(DelvItem.YY1_DeliveryQuantity_DLI as abap.dec( 8, 3) )
      //   end
      //     cast(DelvItem.YY1_DeliveryQuantity_DLI as abap.dec( 8, 3) )

      case
           when Data.dchannel = '10' or Data.dchannel = '30' or Data.dchannel = '35'  //35 Extended by Shubham on 30.06.202
               then cast(Data.quantity as abap.dec( 8, 3 ) )
               else  cast(Data.lweight as abap.dec( 8, 3 ) )
      end                                                as Lquantity

      /* Associations */
      //      _Head
}
