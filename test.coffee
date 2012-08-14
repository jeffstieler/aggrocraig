request = require("request")
jsdom   = require("jsdom")
fs      = require("fs")
jquery  = fs.readFileSync("./static/js/jquery-1.7.2.min.js").toString()
hhh     = fs.readFileSync("./hhh.html").toString()

jsdom.env(
  html: hhh
  src: [jquery]
  done: (err, win) ->
    $ = win.$

    inputs =
      text: []
      radio: {}
      checkbox: []
      select: []

    form = $("#searchform")

    form.find(":checkbox").each((i, cb) ->
      $cb = $(cb)
      inputs.checkbox.push(
        name  : $cb.attr("name")
        value : $cb.val()
        label : $cb.parent().text()
      )
    )

    form.find(":radio").each((i, r) ->
      $r = $(r)
      name = $r.attr("name")
      inputs.radio[name] = [] if inputs.radio[name] is undefined
      inputs.radio[name].push(
        label: $r.parent().text()
        value: $r.val()
      )
    )

    form.find("select").each((i, select) ->
      $s = $(select)
      options = []
      $s.find("option:enabled").each((i, option) ->
        $o = $(option)
        console.log($o.text())
        options.push(
          value: $o.val()
          label: $o.text()
        )
      )
      #console.log(options)
      inputs.select.push(
        name: $s.attr("name")
        options: options
      )
    )

    form.find(":text,input[type='']").each((i, text) -> inputs.text.push($(text).attr("name")))

    #console.log(inputs)

)