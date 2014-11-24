window.Application.controller 'BalanceController', ($scope, balanceFactory) ->

#============ Sorting Table ============#
  $scope.sort = { column: '', descending: false  }

  $scope.changeSorting = (column)->
    sort = $scope.sort
    if sort.column == column
      sort.descending = !sort.descending
    else
      sort.column = column
      sort.descending = false

#============ Loading data ============#
  balanceFactory.getBalances (data) ->
    processData data

  $scope.regenerateBalances =->
    balanceFactory.regenerateBalances (results) ->
      processData(results)

  processData = (results)->
    $scope.balances = results
    initializeBarChartSeries(results)
    initializePieChartSeries(results)

  initializePieChartSeries = (results)->
    buy = results.filter (balance) -> balance.buy_sell   #TODO check why i need parseInt there
                  .map (balance) -> balance.price
                  .reduce (x, y) -> parseInt(x) + parseInt(y)

    sell = results.filter (balance) -> !balance.buy_sell
                    .map (balance) -> balance.price
                    .reduce (x, y) -> parseInt(x) + parseInt(y)
    console.log buy, sell
    $scope.charts.pieChart.series[0].data = [buy, sell]



  initializeBarChartSeries = (results) ->
    buyData = splitByGroups results.filter (balance) -> balance.buy_sell
    sellData = splitByGroups results.filter (balance) -> !balance.buy_sell

    console.log  buyData, sellData

    $scope.charts.barChart.series = [
      { name: 'Buy', data: buyData}
      { name: 'Sell', data: sellData}]


  splitByGroups =(balances)->
    result = [0,0,0,0,0,0,0,0]
    sign = if balances[0].buy_sell then -1 else 1
    for balance in balances
      price = balance.price
      index = if price > 50
            7
          else if price > 20
            6
          else if price > 10
            5
          else if price > 6
            4
          else if price > 4
            3
          else if price > 2
            2
          else if price > 1
            1
          else
            0
      result[index] += (price * sign)
    result[5] /=10
    result[6] /=50
    result[7] /=100
    result
#============ Chart Section ============#
  $scope.charts =  barChart: {},  pieChart: {}

  $scope.charts.barChart =
    options:
      chart:
        type: 'column'
      title:
        text: 'Balh Blah Chart'
    xAxis:
      categories: [
        '0-1',
        '1-2',
        '2-4',
        '4-6',
        '6-10',
        '(10-20) *10',
        '(20-50) *50',
        '(50-100) *100',
      ]

  $scope.charts.pieChart =
      chart:
        plotBackgroundColor: null,
        plotBorderWidth: 1,#null,
        plotShadow: true
      title:
        text: 'Need sleep Chart'
      series: [
        type: 'pie',
        name: 'Balance amount',
        data:data = [ ['Buy', 45.0], ['Sell', 0] ]
      ]

  $scope.saveAsBinary =->
    saveOneChart 'bar-Chart', '#bar-chart-binary'
    saveOneChart 'pie-Chart', '#pie-chart-binary'
    return true

  saveOneChart = (chart_id, img_id)->
    svg = document.getElementById(chart_id).children[0].innerHTML
    base_image = new Image()
    svg = "data:image/svg+xml,"+svg
    base_image.src = svg
    $(img_id).attr('src', svg)
