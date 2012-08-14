jQuery(document).ready(($)->

  templates =
    "list-item" : _.template($("#list-item-template").html())
    "detail"    : _.template($("#detail-template").html())

  resultCount = $("#result-count")

  socket = io.connect("http://localhost:8080")
  resultList = $("ul#results")
  detailView = $("div#detail")
  $("form#search").submit((e) ->
    resultList.html("")
    detailView.html("")
    socket.emit("search", $("input#query").val())
    false
  )
  socket.on(
    "result",
    (data) ->
      resultCount.text(parseInt(resultCount.text(), 10) + 1)
      resultList.append(
        templates["list-item"](data)
      )
  )
  socket.on(
    "detail",
    (data) ->
      detailView.html(templates["detail"](data))
      detailView.append(JSON.stringify(data.images))
  )

  $("li", resultList).live(
    "click",
    () ->
      socket.emit("view", $(@).data("url"))
      false
  )
)