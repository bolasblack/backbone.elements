do (jQuery, _, Backbone) ->
  reEscape = (str, skipChar=[]) ->
    reSpecialChar = [
      "\\", "/", ",", "."
      "|", "^", "$", "?"
      "+", "*", "[", "]"
      "{", "}", "(", ")"
    ]
    for char in reSpecialChar when char not in skipChar
      re = RegExp "\\" + char, "g"
      str = str.replace re, "\\#{char}"
    str

  {$, _configure, delegateEvents} = Backbone.View.prototype
  _.extend Backbone.View.prototype,
    elementsPrefix: "$"
    _elementsSymbolSpliter: [
      # normal selector
      "\\#", "\\."
      # combo selector
      "\\,", "\\s", "\\>", "\\+", "\\~"
      # attribute selector
      "\\["
      # special selector
      "\\:"
    ]

    $: (selector) ->
      $.call this, @_parseSymbolSelector selector

    refreshElements: ->
      @undelegateEvents()
      for selector, varName of @elements
        delete this[@elementsPrefix + varName]
      @_initElements()
      @delegateEvents()

    clearElements: ->
      for property in ["_reverseElements", "_elementsCache", "_regPrefix"]
        delete this[property]

    _configure: (options) ->
      _configure.apply this, arguments
      _.extend this, _.pick options, ["elements", "elementsPrefix"]
      @_initElements()

    _initElements: ->
      return unless @elements
      @_refreshVarible()

      for selector, varName of @elements
        do (selector, varName) =>
          selector = @_parseSymbolSelector selector
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

    _refreshVarible: ->
      @_reverseElements = _.object ([v, k] for k, v of @elements)
      @_regPrefix = reEscape @elementsPrefix
      @_elementsCache = {}

    _negativeReStr: ->
      (@_elementsSymbolSpliter.join "") + @_regPrefix

    _parseSymbol: (elementSymbol) ->
      elementNameRE = ///#{@_regPrefix}([^#{@_negativeReStr()}]*)///
      elementName = elementSymbol.match(elementNameRE)[1]
      @_reverseElements[elementName] or elementSymbol

    _parseSymbolSelector: (selector) ->
      endReStr = @_elementsSymbolSpliter.join "|"
      elementsSelectorRE = ///#{@_regPrefix}([^#{@_negativeReStr()}]*)(?=#{endReStr}|$)///g
      while matchs = selector.match elementsSelectorRE
        elementSymbol = jQuery.trim matchs[0]
        eventSelector = @_parseSymbol elementSymbol
        selector = selector.replace elementSymbol, eventSelector
      selector

    delegateEvents: (events) ->
      unless (events or= _.result this, "events")
        return delegateEvents.apply this, arguments
      finalEvents = {}
      for selector, handerName of events
        newSelector = @_parseSymbolSelector selector
        finalEvents[newSelector] = handerName
      delegateEvents.call this, finalEvents
