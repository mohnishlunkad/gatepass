@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inward Data Header Data'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_VEHIN_HEAD_A
  as select from zdt_vehin_head as Head
  association [0..*] to I_BillingDocumentItemBasic as Billing      on  Billing.ReferenceSDDocument     = Head.orderhead
                                                                   and Billing.ReferenceSDDocumentItem = '000010'
  association [0..1] to ZI_VEHIN_HEAD_TIME_A       as TimeData     on  TimeData.inward_uuid = Head.inward_uuid
  association [0..1] to I_DeliveryDocumentItem     as DeliveryItem on  DeliveryItem.DeliveryDocument     = Head.orderhead
                                                                   and DeliveryItem.DeliveryDocumentItem = '000010'

{
  key Head.inward_uuid,
      Head.ticknum,
      Head.plant,
      case Head.plant
        when '1100'
            then 'Plot NO 39B, INDUSTRIAL PARK, VAKALAPUDI, KAKINADA-533005'
        when '1200'
              then 'PLOT NO.B1,OPP.R.C.H.W.QUARTERS, BAIKAMPADY,INDUSTRIAL ESTATE ROAD,NEAR IPL GODOWN, MANGALURU - 575010'
        when '2100'
                then 'SY.NO.252,EPURU BIT-1B,PANTAPALEM VILLAGE, MUTHUKUR MANDAL, SPSR NELLORE-524344'
        else 'Plot NO 39B, INDUSTRIAL PARK, VAKALAPUDI, KAKINADA-533005'

      end                                           as PlantAdd,

      case Head.plant
        when '1100'
            then 'SANTHOSHIMATHAA EDIBLE OILS REFINERY PRIVATE LIMITED'
        when '1200'
              then 'SANTHOSHIMATHAA EDIBLE OILS REFINERY PRIVATE LIMITED'
        when '2100'
                then 'SANTHOSHIMATHAA OILS AND FATS PRIVATE LIMITED'
        else 'SANTHOSHIMATHAA EDIBLE OILS REFINERY PRIVATE LIMITED'
      end                                           as Name,

      concat(
        concat(
          concat(substring(Head.indate, 7, 2), '/' ),
          concat(substring(Head.indate, 5, 2), '/' )
        ),
        substring(Head.indate, 1, 4)
      )                                             as Idate,

      concat(
        concat(
          concat(substring(Head.intime, 1, 2), ':' ),
          concat(substring(Head.intime, 3, 2), ':' )
        ),
        substring(Head.intime, 5, 2)
      )                                             as Itime,
      Head.vehnum,
      Head.drivnum,
      Head.orderhead,

      concat(
       concat(
         concat(substring(Head.pwidate, 7, 2), '/' ),
         concat(substring(Head.pwidate, 5, 2), '/' )
       ),
       substring(Head.pwidate, 1, 4)
      )                                             as Tdate,

      concat(
        concat(
          concat(substring(Head.pwitime, 1, 2), ':' ),
          concat(substring(Head.pwitime, 3, 2), ':' )
        ),
        substring(Head.pwitime, 5, 2)
      )                                             as Ttime,

      concat(
        concat(
          concat(substring(Head.pwodate, 7, 2), '/' ),
          concat(substring(Head.pwodate, 5, 2), '/' )
        ),
        substring(Head.pwodate, 1, 4)
      )                                             as Gdate,

      concat(
        concat(
          concat(substring(Head.pwotime, 1, 2), ':' ),
          concat(substring(Head.pwotime, 3, 2), ':' )
        ),
        substring(Head.pwotime, 5, 2)
      )                                             as Gtime,

      concat(
       concat(
         concat(substring(Head.pwexitdt, 7, 2), '/' ),
         concat(substring(Head.pwexitdt, 5, 2), '/' )
       ),
       substring(Head.pwexitdt, 1, 4)
      )                                             as Edate,

      concat(
        concat(
          concat(substring(Head.pwexittm, 1, 2), ':' ),
          concat(substring(Head.pwexittm, 3, 2), ':' )
        ),
        substring(Head.pwexittm, 5, 2)
      )                                             as Etime,

      Head.pwiuom                                   as UoM,

      @Semantics.quantity.unitOfMeasure : 'UoM'
      Head.pwiempwg                                 as TareWeight,

      @Semantics.quantity.unitOfMeasure : 'UoM'
      Head.pwoempwg                                 as GrossWeight,

      @Semantics.quantity.unitOfMeasure : 'UoM'
      case when Head.pwoempwg is not initial and Head.pwiempwg is not initial
            then abs( Head.pwoempwg - Head.pwiempwg )
            else cast(0 as abap.quan( 10, 2 ) ) end as LoadedWeight,

      division(TimeData.Duration, 60, 2 )           as duration,

      Billing.BillingDocument                       as Invoice,


      case when dchannel = '10'
           then 'Pack Division'
           when dchannel = '15'
           then 'Bulk Division'
           else ''
        end                                         as Division,

      case when dchannel = '15'
        then DeliveryItem._Product._Text[ Language = $session.system_language ].ProductName
          when dchannel = '10'
        then 'Packed Sales'
        when dchannel = '35'                //Added by Shubham on 30.06.2026
        then 'Packed Sales'
        else ''
        end                                         as Remark,
      dchannel,
      Billing.Product,
      case when dchannel = '10'
           then 'Distribution Channel:'
           when dchannel = '15'
           then 'Material:'
           else 'Remarks:'
        end                                         as RemarkLabel
      /* Associations */
      //      _Item
}
