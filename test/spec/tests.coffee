describe "the backbone elements plugin", ->
  should = chai.should()
  View = Backbone.View

  beforeEach ->
    @clickChildSpy = sinon.spy()
    @theView = new (View.extend
      el: $ "#test"
      elements:
        ".test-child": "child"
        "$child .test-child-element": "childElement"
        ".test-empty-element": "emptyElement"
        "$notExistElement li": "it_may_call_stack_overflow"
      events:
        "click $child": @clickChildSpy
    )
    @$child = @theView.$child()

  describe "the elements attribute", ->
    it "should be work", ->
      @theView.elements.should.exist

    it "should extend elements attribute of view options", ->
      newView = new View el: $("#test"), elements: {".test-child": "child"}
      newView.elements.should.exist

  describe "the element prefix attribute", ->
    it "should be work", ->
      @theView.should.have.property @theView.elementsPrefix + "child"

    it "should be a function", ->
      @theView[@theView.elementsPrefix + "child"].should.be.a "function"

  describe "the select method", ->
    it "should be work", ->
      @$child[0].should.equal @theView.$(".test-child")[0]

    it "should return child element when input selector string", ->
      @theView.$child(".test-child-element")[0]
        .should.equal @theView.$(".test-child .test-child-element")[0]

  describe "the select symbol", ->
    it "should work in elements selector", ->
      @theView.$childElement()[0].should.equal @theView.$child(".test-child-element")[0]

    it "should be parsed in all select case", ->
      specialCases = [
        "#aaa", ".aaa", ",aaa"
        " aaa", ">aaa", "+aaa"
        "~aaa", "[attr='aaa']", ":after"
      ]
      unableCase = specialCases.join ""

      for specialCase in specialCases
        @theView._parseSymbolSelector("$child#{specialCase}")
          .should.equal ".test-child#{specialCase}"

      @theView._parseSymbolSelector("$child#{unableCase}")
        .should.equal ".test-child#{unableCase}"

      @theView._parseSymbolSelector(specialCases.join "$child")
        .should.equal specialCases.join ".test-child"

    it "should work in events selector", ->
      @$child.trigger "click"
      @clickChildSpy.called.should.be.true

    it "should work in `this.$` selector", ->
      @theView.$("$child")[0].should.equal @theView.$(".test-child")[0]

  describe "the elementsPrefix attribute", ->
    it "should could be changed", ->
      newView = new View
        el: $("#test")
        elementsPrefix: "sym_"
        elements: {".test-child": "child"}

      newView.should.have.property("sym_child")
        .and.that.should.not.have.property "$child"

  describe "the elements cache", ->
    it "should be work", ->
      @theView.$("$child").should.not.equal @theView.$("$child")
      @$child.should.equal @theView.$child()

    it "should not cache when element not exist", ->
      @theView.$emptyElement().should.not.equal @theView.$emptyElement()

  describe "the refreshElements method", ->
    it "should be work", ->
      @theView.refreshElements()
      @$child.should.not.equal @theView.$child()

    it "should refresh element cache when input true", ->
      @$child.should.not.equal @theView.$child true
      @theView.$child(true).should.not.equal @theView.$child true
      @theView.$child(true).should.equal @theView.$child()

    it "should refresh events bind when refresh elements cache", ->
      $oldChild = @theView.$child()
      @theView.elements = ".other-element": "child"
      @theView.refreshElements()
      $oldChild.trigger "click"
      @clickChildSpy.called.should.be.false
      @theView.$child().trigger "click"
      @clickChildSpy.called.should.be.true

  describe "the clearElements method", ->
    it "should be work", ->
      @theView.clearElements()
      for property in ["_reverseElements", "_elementsCache", "_regPrefix"]
        @theView.should.not.have.property property
