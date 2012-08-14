request = require("request")
jsdom   = require("jsdom")
fs      = require("fs")
jquery  = fs.readFileSync("./static/js/jquery-1.7.2.min.js").toString()

jsdom.env(
  html: "http://www.craigslist.org/about/sites"
  src: [jquery]
  done: (err, win) ->
    return if win is undefined

    $     = win.$
    lists = {}

    $("div.colmask").each(
      (i, col) ->
        $col = $(col)
        continent = $col.find("h1.continent_header").text()
        aCont = lists[continent] = {}

        $col.find("div.state_delimiter").each(
          (i, state) ->
            $state = $(state)
            stateName = $state.text()
            aState = aCont[stateName] = {}
            $state.nextUntil("div.state_delimiter", "ul").find("li a").each(
              (i, city) ->
                $city = $(city)
                name  = $city.text()
                url   = $city.attr("href")
                aState[name] = url
            )
        )
    )

    fs.writeFileSync("./static/data/lists.json", JSON.stringify(lists, null, 2))
)