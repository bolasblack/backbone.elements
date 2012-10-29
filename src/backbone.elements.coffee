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
    elementsPrefix: "$"

    _configure: (options) ->
      super
      _.extend this, _.pick options, ["elements", "elementsPrefix"]
      @initElements()

    initElements: ->
      return unless @elements
      @_refreshVarible()

      for selector, varName of @elements
        selector = @_parseSymbolSelector selector
        do (selector, varName) =>
          this[@elementsPrefix + varName] = (subSelector, refresh) =>
            if subSelector in [true, false]
              [subSelector, refresh] = [undefined, subSelector]
            $elem = if refresh
              @$ selector
            else
              @_elementsCache[varName] or @$ selector
            return $elem unless $elem.length
            @_elementsCache[varName] = $elem
            return $elem unless subSelector
            $elem.find subSelector

    refreshElements: ->
      @undelegateEvents()
      for selector, varName of @elements
        delete this[@elementsPrefix + varName]
      @_refreshVarible()
      @initElements()

    $: (selector) ->
      super @_parseSymbolSelector selector

    _refreshVarible: ->
      @_reverseElements = _.object ([v, k] for k, v of @elements)
      @_regPrefix = reEscape @elementsPrefix
      @_elementsCache = {}

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
