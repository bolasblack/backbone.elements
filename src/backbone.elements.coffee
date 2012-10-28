do ($, _, Backbone) ->
  reEscape = (str) ->
    str.replace(/\\/g, "\\\\")
      .replace(/\//g, "\\/").replace(/\,/g, "\\,").replace(/\./g, "\\.")
      .replace(/\^/g, "\\^").replace(/\$/g, "\\$").replace(/\|/g, "\\|")
      .replace(/\?/g, "\\?").replace(/\+/g, "\\+").replace(/\*/g, "\\*")
      .replace(/\[/g, "\\[").replace(/\]/g, "\\]")
      .replace(/\{/g, "\\{").replace(/\}/g, "\\}")
      .replace(/\(/g, "\\(").replace(/\)/g, "\\)")

  View = Backbone.View
  class Backbone.View extends View
    constructor: (options) ->
      super
      @initElements()

    _configure: (options) ->
      super
      _.extend this, _.pick options, ["elements", "elementsPrefix"]

    elements: false
    elementsPrefix: "$"

    initElements: ->
      return unless @elements
      cache = {}
      for selector, varName of @elements
        do (selector, varName) =>
          this[@elementsPrefix + varName] = (subSelector, refresh) =>
            if subSelector in [true, false]
              [subSelector, refresh] = [undefined, subSelector]
            $elem = if refresh then @$(selector) else cache[varName] or @$ selector
            return $elem unless $elem.length
            cache[varName] = $elem
            return $elem unless subSelector
            $elem.find subSelector

      @refreshElements = ->
        @undelegateEvents()
        cache = {}
        for selector, varName of @elements
          delete this[@elementsPrefix + varName]
        @initElements()

    refreshElements: ->

    $: (selector) ->
      super @_parseSymbolSelector selector

    _parseSymbol: (elementSymbol) ->
      regPrefix = reEscape @elementsPrefix
      elementNameRE = ///#{regPrefix}([^\s#{regPrefix}]*)///
      reverseElements = _.object ([v, k] for k, v of @elements)

      elementName = elementSymbol.match(elementNameRE)[1]
      reverseElements[elementName] or elementSymbol

    _parseSymbolSelector: (selector) ->
      regPrefix = reEscape @elementsPrefix
      elementsSelectorRE = ///#{regPrefix}([^\s#{regPrefix}]*)(\s|$)///g

      while matchs = selector.match elementsSelectorRE
        elementSymbol = $.trim matchs[0]
        eventSelector = @_parseSymbol elementSymbol
        selector = selector.replace elementSymbol, eventSelector
      selector

    delegateEvents: (events) ->
      return super unless (events or= _.result this, "events")
      finalEvents = {}
      for selector, handerName of events
        newSelector = @_parseSymbolSelector selector
        finalEvents[newSelector] = handerName
      super finalEvents
