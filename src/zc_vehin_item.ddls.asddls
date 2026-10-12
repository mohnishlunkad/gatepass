@EndUserText.label: 'Vehicle Inward Item Projection View'
@AccessControl.authorizationCheck: #CHECK
@Search.searchable: true
@Metadata.allowExtensions: true
define view entity ZC_VEHIN_ITEM
  as projection on ZI_VEHIN_ITEM
{
  key Item_Uuid,
  key inward_uuid,
      @Search.defaultSearchElement: true
      Inwarditem,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_OrderStdVH',
                       element: 'OrdNum'},
                       additionalBinding: [{
          localElement: 'intype',
          element: 'InType',
          usage: #FILTER
      },
      {
          localElement: 'Dchannel',
          element: 'Dchannel',
          usage: #FILTER
      },
      {
          localElement: 'Plant',
          element: 'Plant',
          usage: #FILTER
      }
      ]
      }]
      Ordnum,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_ORDERITEMSTDVH',
                       element: 'OrdNumItem'},
                       additionalBinding: [{
          localElement: 'Ordnum',
          element: 'Ordnum',
          usage: #FILTER
      }]
      }]
      Ordnumitem,
      Orderdate,
      @Search.defaultSearchElement: true
      Bpcode,
      Bpname,
      Brokername,
      Quantity,
      uom,
      GrossWeight,
      NetWeight,
      intype,
      Dchannel,
      Plant,
      Matnr,
      CreatedBy,
      LastChangedBy,
      LocalLastChangedAt,
      /* Associations */
      _Head : redirected to parent ZC_VEHIN_HEAD
}
