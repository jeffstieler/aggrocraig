request  = require("request")
jsdom    = require("jsdom")
fs       = require("fs")
jquery   = fs.readFileSync("./static/js/jquery-1.7.2.min.js").toString()
_        = require("underscore")
_.str    = require("underscore.string")
socketio = require("socket.io")
http     = require("http")
express  = require("express")
stylus   = require("stylus")

app = express()
server = http.createServer(app)

app.configure(() ->
  app.use(express.logger())
  app.use(express.static("#{__dirname}/static"))
  app.use(express.errorHandler(
    dumpExceptions : true
    showStack      : true
  ))
)

app.set("views", "#{__dirname}/views")
app.set("view engine", "jade")

app.get(
  "/",
  (req, res) ->
    res.render("root")
)

io = socketio.listen(server)

io.sockets.on(
  "connection",
  (socket) ->
    console.log("client connected!")
    socket.on(
      "search",
      (data) ->
        query = _.str.trim(data).replace(/(\s+)/g, "+")
        #_.each(lists["US"], (state) -> _.each(state, (url) -> search(socket, url, query)))
        #_.each(lists["US"]["Florida"], (url) -> search(socket, url, query))
        search(socket, lists["US"]["Florida"]["orlando"], query)
    )
    socket.on(
      "view",
      (data) ->
        getDetail(socket, data)
    )
)

server.listen(8080)

console.log("listening at http://localhost:8080")

lists = require("./static/data/lists")

jQueriedRequest = (url, callback) ->
  jsdom.env(
    html: url
    headers:
      "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.75 Safari/537.1"
    src: [jquery]
    done: (err, win) ->
      return if undefined == win
      callback(win.$)
  )

search = (socket, url, search) ->
  jQueriedRequest(
    "#{url}/search/?catAbb=sss&query=#{search}",
    ($) ->
      $results = $("p.row")
      _.each(
        $results,
        (result) ->
          $result = $(result)
          $link = $result.find("> a")
          json =
            date     : $result.find("span.itemdate").text()
            title    : $link.text()
            url      : $link.attr("href")
            location : $result.find("span.itempn").text()
          socket.emit("result", json)
      )
  )

getDetail = (socket, url) ->
  jQueriedRequest(
    url,
    ($) ->
      detail =
        title : $("h2").text()
        date  : $("span.postingdate").text()
        body  : $("#userbody").clone().find("ul, img, script, div").remove().end().html()
        blurbs: []
        images: []

      replyToSpan = $("span.returnemail")
      email = replyToSpan.find("a").text()

      if email.length
        detail.email = email
      else
        detail.replyTo = replyToSpan.text()

      $("ul.blurbs li").each((i, blurb) ->
        detail.blurbs.push($(blurb).text())
      )

      $("div.tn").each((i, div) ->
        $div = $(div)
        detail.images.push(
          url   : $div.find("a").attr("href")
          thumb : $div.find("img").attr("src")
        )
      )

      socket.emit("detail", detail)
  )
