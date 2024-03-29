// Generated by CoffeeScript 1.3.3
(function() {
  var fs, hhh, jquery, jsdom, request;

  request = require("request");

  jsdom = require("jsdom");

  fs = require("fs");

  jquery = fs.readFileSync("./static/js/jquery-1.7.2.min.js").toString();

  hhh = fs.readFileSync("./hhh.html").toString();

  jsdom.env({
    html: hhh,
    src: [jquery],
    done: function(err, win) {
      var $, form, inputs;
      $ = win.$;
      inputs = {
        text: [],
        radio: {},
        checkbox: [],
        select: []
      };
      form = $("#searchform");
      form.find(":checkbox").each(function(i, cb) {
        var $cb;
        $cb = $(cb);
        return inputs.checkbox.push({
          name: $cb.attr("name"),
          value: $cb.val(),
          label: $cb.parent().text()
        });
      });
      form.find(":radio").each(function(i, r) {
        var $r, name;
        $r = $(r);
        name = $r.attr("name");
        if (inputs.radio[name] === void 0) {
          inputs.radio[name] = [];
        }
        return inputs.radio[name].push({
          label: $r.parent().text(),
          value: $r.val()
        });
      });
      form.find("select").each(function(i, select) {
        var $s, options;
        $s = $(select);
        options = [];
        $s.find("option:enabled").each(function(i, option) {
          var $o;
          $o = $(option);
          console.log($o.text());
          return options.push({
            value: $o.val(),
            label: $o.text()
          });
        });
        return inputs.select.push({
          name: $s.attr("name"),
          options: options
        });
      });
      return form.find(":text,input[type='']").each(function(i, text) {
        return inputs.text.push($(text).attr("name"));
      });
    }
  });

}).call(this);
