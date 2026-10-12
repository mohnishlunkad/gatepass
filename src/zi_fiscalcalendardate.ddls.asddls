@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Fiscal Calendar'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Zi_fiscalcalendardate as select from I_FiscalCalendarDate
{
    key FiscalYearVariant,
    key CalendarDate,
    FiscalYear,
    FiscalYearStartDate,
    FiscalYearEndDate,
    FiscalPeriod,
    FiscalPeriodStartDate,
    FiscalPeriodEndDate,
    FiscalQuarter,
    FiscalQuarterStartDate,
    FiscalQuarterEndDate,
    FiscalWeek,
    FiscalWeekStartDate,
    FiscalWeekEndDate,
    FiscalYearPeriod,
    FiscalYearQuarter,
    FiscalYearWeek,
    FiscalYearConsecutiveNumber,
    FiscalPeriodConsecutiveNumber,
    FiscalQuarterConsecutiveNumber,
    FiscalWeekConsecutiveNumber,
    /* Associations */
    _CalendarDate,
    _FiscalPeriod,
    _FiscalQuarter,
    _FiscalWeek,
    _FiscalYear,
    _FiscalYearPeriod,
    _FiscalYearQuarter,
    _FiscalYearVariant,
    _FiscalYearWeek,
    _Text
}
