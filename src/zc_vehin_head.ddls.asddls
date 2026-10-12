@EndUserText.label: 'Vehicle Inward Header Projection View'
@AccessControl.authorizationCheck: #CHECK
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity ZC_VEHIN_HEAD
  provider contract transactional_query
  as projection on ZI_VEHIN_HEAD
{
  key Inward_Uuid,
      @Search.defaultSearchElement: true
      Ticknum,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_InwardTypeSTDVH',
                         element: 'value_low'} ,
                         distinctValues: true
                       }]
      Intype,
      Fiscal,
      Indate,
      Intime,
      Vehnum,
      Drivnum,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_ORDERHEADERSTDVH',
                       element: 'OrdNum'},
                       additionalBinding: [{
          localElement: 'Intype',
          element: 'InType',
          usage: #FILTER
      }]
      }]
      Orderhead,
      @Consumption.valueHelpDefinition: [{ entity: {
          name: 'ZI_ORDERHEADER1',
          element: 'Orderhead'
      } }]
      Orderhead1,
      Plant,
      Type,
      Dchannel,
      Range,
      printform,
      pwidate,
      pwiempwg,
      pwigetwg,
      pwitime,
      pwiuom,
      grossweight,
      netweight,
      pwogetwg,
      pwexit,
      pwexitdt,
      pwexittm,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _Item : redirected to composition child ZC_VEHIN_ITEM
}
