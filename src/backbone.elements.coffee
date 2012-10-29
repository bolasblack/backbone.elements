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
    elements: false
    elementsPrefix: "$"
    _reverseElements: false
    _regPrefix: false

    _configure: (options) ->
      super
      _.extend this, _.pick options, ["elements", "elementsPrefix"]
      @initElements()

    initElements: ->
      return unless @elements
      @_refreshVarible()

      cache = {}
      for selector, varName of @elements
        do (selector, varName) =>
          debugger if !!~_(selector).indexOf "$child"
          selector = @_parseSymbolSelector selector
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
        @_refreshVarible()
        @initElements()

    refreshElements: ->

    $: (selector) ->
      super @_parseSymbolSelector selector

    _refreshVarible: ->
      @_reverseElements = _.object ([v, k] for k, v of @elements)
      @_regPrefix = reEscape @elementsPrefix

    _parseSymbol: (elementSymbol) ->
      elementNameRE = ///#{@_regPrefix}([^\s#{@_regPrefix}]*)///
      elementName = elementSymbol.match(elementNameRE)[1]
      @_reverseElements[elementName] or elementSymbol

    _parseSymbolSelector: (selector) ->
      elementsSelectorRE = ///#{@_regPrefix}([^\s#{@_regPrefix}]*)(\s|$)///g
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
