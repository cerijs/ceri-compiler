chai = require "chai"
should = chai.should()


describe "ceri-compiler", ->
  describe "compile1", ->
    compile = require "../src/compile1.coffee"
    it "should work simple", ->
      compile("<div></div>").should.equal "function(){return [this.el(\"div\",null,[])]}"
    it "should work with attr", ->
      compile("<div class=test></div>").should.equal "function(){return [this.el(\"div\",{\"class\":{\"\":\"test\"}},[])]}"
    it "should work with bind", ->
      compile("<div :class=test></div>").should.equal "function(){return [this.el(\"div\",{\"class\":{\":\":\"test\"}},[])]}"
    it "should work with event", ->
      compile("<div @class=test></div>").should.equal "function(){return [this.el(\"div\",{\"class\":{\"@\":\"test\"}},[])]}"
    it "should work with slot", ->
      compile("<div><slot></slot></div>").should.equal "function(){return [this.el(\"div\",null,[\"default\"])]}"
    it "should work with child", ->
      compile("<div><div></div></div>").should.equal "function(){return [this.el(\"div\",null,[this.el(\"div\",null,[])])]}"
    it "should work with children", ->
      compile("<div><div></div><div></div></div>").should.equal "function(){return [this.el(\"div\",null,[this.el(\"div\",null,[]),this.el(\"div\",null,[])])]}"
    it "should work with deep child", ->
      compile("<div><div><div></div></div></div>").should.equal "function(){return [this.el(\"div\",null,[this.el(\"div\",null,[this.el(\"div\",null,[])])])]}"
    it "should work with multiple types of attributes", ->
      compile("<div :class=test1 class=test2></div>").should.equal "function(){return [this.el(\"div\",{\"class\":{\":\":\"test1\",\"\":\"test2\"}},[])]}"
    it "should work with multiple different attributes", ->
      compile("<div class1=test1 class2=test2></div>").should.equal "function(){return [this.el(\"div\",{\"class1\":{\"\":\"test1\"},\"class2\":{\"\":\"test2\"}},[])]}"
    it "should work with multiple ground level elements", ->
      compile("<div></div><div></div>").should.equal "function(){return [this.el(\"div\",null,[]),this.el(\"div\",null,[])]}"
    it "should work with text", ->
      compile("<div>someText</div>").should.equal "function(){return [this.el(\"div\",{\"text\":{\"#\":\"someText\"}},[])]}"
    it "should work with expressions", ->
      compile("<div :text.expr=test></div>").should.equal "function(){return [this.el(\"div\",{\"text\":{\":\":function(){return test;}}},[])]}"
    it "should work with text expressions", ->
      compile("<div>{{test}}</div>").should.equal "function(){return [this.el(\"div\",{\"text\":{\":\":function(){return (test);}}},[])]}"
      compile("<div>something {{test}} morething</div>").should.equal "function(){return [this.el(\"div\",{\"text\":{\":\":function(){return \"something \"+(test)+\" morething\";}}},[])]}"
    it "should work with multiple expressions", ->
      compile("<div :text.expr=test :test.expr=text></div>").should.equal "function(){return [this.el(\"div\",{\"text\":{\":\":function(){return test;}},\"test\":{\":\":function(){return text;}}},[])]}"
    it "should work with multiple returns", ->
      compile("<div :text.expr=\"test;return test2\"></div>").should.equal "function(){return [this.el(\"div\",{\"text\":{\":\":function(){test;return test2;}}},[])]}"
    it "should work with @ in expression", ->
      compile("<div :text.expr=\"@test='\@'\"></div>").should.equal "function(){return [this.el(\"div\",{\"text\":{\":\":function(){return this.test='@';}}},[])]}"
  describe "index", ->
    main = require "../src/index.coffee"
    it "should work with simple html", ->
      main v:1, html: "<div></div>"
      .should.equal "function(){return [this.el(\"div\",null,[])]}"
    it "should work with js", ->
      main v:1, js: "module.exports = {
        structure: template('<div></div>')
      }"
      .should.equal "module.exports = { structure: function(){return [this.el(\"div\",null,[])]} }"
    it "should work with version specified in js", ->
      main js: "module.exports = {
        structure: template(1,'<div></div>')
      }"
      .should.equal "module.exports = { structure: function(){return [this.el(\"div\",null,[])]} }"
    it "should make warnings", ->
      main js: "cwarn(true === false, 'true should be false')"
      .should.equal "if(process.env.NODE_ENV!=='production' && true === false){console.warn('true should be false')}"
    it "should make errors", ->
      main js: "cerror(true === false, 'true should be false')"
      .should.equal "if(process.env.NODE_ENV!=='production' && true === false){throw new Error('true should be false')}"